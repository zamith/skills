---
name: deploy-to-exe-dev
description: Use when deploying or hosting an app on exe.dev — provisioning an exe.dev VM, adding a Dockerfile + docker-compose.yml so the project builds and runs there, wiring the HTTPS proxy, or setting up a Phoenix/Elixir (or any) web app for production on exe.dev VMs.
---

# Deploy to exe.dev

## Overview

exe.dev gives you persistent Linux VMs over SSH with an automatic HTTPS proxy.
This skill scaffolds the Docker artifacts a project needs to build there, then
provisions a VM and sets up **git push-to-deploy**: pushing the repo to a bare
repo on the VM triggers a `post-receive` hook that checks out the code and
rebuilds the Docker Compose stack. Defaults target Elixir/Phoenix + Postgres but
the procedure is generic — any stack with a Dockerfile + `docker-compose.yml`.

Templates live in `templates/` next to this file. Read them, copy into the repo,
and replace the `{{...}}` placeholders. This pattern is verified against a live
exe.dev production deployment.

Server layout the hook expects (do not change without editing the hook):

| Path | Role |
|------|------|
| `/home/exedev/deploy.git` | bare repo; push target |
| `/home/exedev/app` | work tree; code checked out here, compose runs here |
| `/home/exedev/env/.env` | secrets; symlinked into the work tree (outside it so `checkout -f` never wipes it) |
| `/home/exedev/uploads` | optional host volume for writable state |
| `/home/exedev/deploy.log` | deploy output |

## exe.dev mental model

| Fact | Detail |
|------|--------|
| Create VM | `ssh exe.dev new --name <vm>` |
| List / inspect | `ssh exe.dev ls` (add `--json`) |
| SSH into VM | `ssh <vm>.exe.xyz` (user `exedev`, `sudo` available) |
| Public URL | `https://<vm>.exe.xyz/` (TLS terminated by proxy) |
| Proxy port pick | Auto from Dockerfile `EXPOSE` — prefers 80, else smallest TCP port ≥1024 |
| Override proxy port | `ssh exe.dev share port <vm> <port>` |
| Make public | `ssh exe.dev share set-public <vm>` (default is private/login-gated) |
| Extra ports | Ports 3000–9999 reachable at `https://<vm>.exe.xyz:<port>/` (VM-access only) |
| Forwarded headers | `X-Forwarded-Proto/Host/For` are set — the app sits behind a proxy |
| Deploy mechanism | git push to bare repo + `post-receive` hook (see `setup-server.sh`) |
| Docker | May be preinstalled; `setup-server.sh` installs it if missing |

## Procedure

### Phase 1 — Scaffold artifacts into the repo

1. Detect the stack. If `mix.exs` exists → Elixir/Phoenix (default path). Otherwise
   adapt (see "Non-Elixir stacks").
2. Read the OTP app name and module from `mix.exs` (`app: :my_app` → `{{APP}}`=`my_app`,
   `{{MODULE}}`=`MyApp`).
3. Copy from `templates/elixir/`: `Dockerfile`, `docker-compose.yml`, `.dockerignore`,
   `.env.example`, `rel/overlays/bin/migrate`, `rel/overlays/bin/server`.
   Replace every `{{APP}}` / `{{MODULE}}` / `{{VM}}` placeholder. `chmod +x rel/overlays/bin/*`.
4. Match `ELIXIR_VERSION` / `OTP_VERSION` in the Dockerfile to `mise.toml` /
   `.tool-versions`.
5. Phoenix release plumbing:
   - Ensure a `MyApp.Release` module with `migrate/0` exists. If not, run
     `mix phx.gen.release` (do NOT pass `--docker`; this skill owns the Dockerfile).
   - In `config/runtime.exs`, confirm the production block reads `PHX_HOST`,
     `SECRET_KEY_BASE`, `DATABASE_URL`, `PORT`, and sets the endpoint
     `url: [host: host, port: 443, scheme: "https"]` with `server: true` when
     `PHX_SERVER=true`. This is the stock `mix phx.gen.release` output — keep it.
   - Behind a TLS-terminating proxy, do NOT set `force_ssl: [hsts: true]` to redirect;
     the proxy already serves HTTPS. Trust the forwarded proto instead.
6. Drop the npm lines from the Dockerfile if `assets/` has no `package.json` deps.
7. Verify locally before touching a VM: `docker compose build` (or full
   `docker compose up`). Fix build errors here, not on the VM.

### Phase 2 — Provision the VM and set up push-to-deploy

1. Create the VM (name becomes the public hostname):
   `ssh exe.dev new --name <vm>`
2. Bootstrap the server: `templates/setup-server.sh <vm>`. It installs Docker if
   missing, creates `/home/exedev/{app,env,uploads}`, inits the bare repo
   `/home/exedev/deploy.git`, installs `templates/post-receive` as the hook, and
   adds a local git remote named `deploy`.
3. Write production secrets into `/home/exedev/env/.env` on the VM (NOT in git —
   the hook symlinks this file in). Use `.env.example` as the key list:
   - `SECRET_KEY_BASE` = output of `mix phx.gen.secret`
   - `POSTGRES_PASSWORD` = a strong secret
   - `PHX_HOST=<vm>.exe.xyz`
   ```
   ssh <vm>.exe.xyz 'nano /home/exedev/env/.env'
   ```
4. Deploy by pushing — the hook builds and (re)starts the stack:
   `git push deploy main`   (use your default branch)
5. Proxy: with `EXPOSE 4000` in the Dockerfile and `4000:4000` published, the proxy
   auto-selects 4000. If it doesn't: `ssh exe.dev share port <vm> 4000`.
6. Serve at the bare URL with no login gate: `ssh exe.dev share set-public <vm>`.
7. Verify: open `https://<vm>.exe.xyz/`; check `ssh <vm>.exe.xyz 'tail -f /home/exedev/deploy.log'`
   and `ssh <vm>.exe.xyz 'cd /home/exedev/app && docker compose logs -f app'`.

Redeploys are just `git push deploy main`. The hook runs `docker compose down`
then `up -d --build` each time. The work tree is overwritten on every push, so any
writable state (uploads) MUST be on a host volume (see compose template).

## Non-Elixir stacks

Keep `docker-compose.yml`'s `db` service and `.env` wiring; swap the `app` service.
The git-push deploy mechanism (Phase 2) is identical — it only needs a compose file.

- Provide a working Dockerfile with an `EXPOSE <port>` line so the proxy auto-detects
  it. Publish that port to the host in compose (`"PORT:PORT"`).
- If the app's port isn't auto-picked: `ssh exe.dev share port <vm> <port>`.
- Drop DB env vars / the `db` service entirely for a stateless app.
- The app must honor `X-Forwarded-Proto`/`-Host` to build correct absolute URLs
  (most frameworks need "trust proxy" enabled).

## Common mistakes

- **App binds to 127.0.0.1.** It must listen on `0.0.0.0` inside the container or the
  published port — and thus the proxy — gets nothing. Phoenix needs `ip: {0,0,0,0}`
  (stock release config does this).
- **Forgot to publish the port in compose.** The proxy targets a VM-host port; without
  `ports: ["4000:4000"]` the container port is unreachable.
- **`force_ssl` redirect loop.** Proxy already terminates TLS; an HTTPS-redirect on the
  app loops or 502s. Leave `force_ssl` commented out and trust `X-Forwarded-Proto`.
- **Secrets in git.** Never commit `.env`. It lives only at `/home/exedev/env/.env`.
- **Writable state in the work tree.** `git checkout -f` overwrites `/home/exedev/app`
  every deploy. Persist uploads/DB on host volumes.
- **Wrong `PHX_HOST`.** Must equal `<vm>.exe.xyz` or Phoenix rejects host / builds bad URLs.
- **VM private by default.** Browsers hit a login wall until `share set-public`.

## Quick reference

```bash
ssh exe.dev new --name myapp                 # create VM -> myapp.exe.xyz
./templates/setup-server.sh myapp            # one-time: docker, dirs, bare repo, hook, remote
ssh myapp.exe.xyz 'nano /home/exedev/env/.env'   # write secrets
git push deploy main                          # deploy (and every redeploy)
ssh exe.dev share set-public myapp            # serve publicly
ssh myapp.exe.xyz 'tail -f /home/exedev/deploy.log'
ssh myapp.exe.xyz 'cd /home/exedev/app && docker compose logs -f app'
```
