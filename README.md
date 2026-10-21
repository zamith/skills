# Skills

Zamith's personal collection of Claude Code skills, published as a plugin marketplace.

## Usage

Register the marketplace in Claude Code:

```
/plugin marketplace add zamith/skills
```

Install a plugin:

```
/plugin install review@zamith
/plugin install understand@zamith
/plugin install orchestrate@zamith
/plugin install deploy@zamith
```

Some skills call skills from the [Subvisual harness](https://github.com/subvisual/harness) (`building@subvisual`): `chief-of-staff` workers use `/building:handoff`, and `improve-codebase-architecture` uses `grill-with-docs`.

## Structure

```
skills/
  review/        # PR review skills
  understand/    # explaining and mapping code
  orchestrate/   # long-running, multi-session work
  deploy/        # hosting and deployment
template/        # scaffold for creating new skills
.claude-plugin/  # marketplace registry
```

See `CLAUDE.md` for repo conventions.

## Plugins

| Plugin        | Description                                                                                                    |
| ------------- | -------------------------------------------------------------------------------------------------------------- |
| `review`      | Work through PR review feedback and review PRs adversarially, posting findings back to GitHub.                 |
| `understand`  | Explain code and changes, walk through a branch piece by piece, trace data across repos, find deepening refactors. |
| `orchestrate` | Run long-lived work through a chief-of-staff session that dispatches workers, or an autonomous issue loop.     |
| `deploy`      | Deploy and host apps on exe.dev VMs with Docker Compose and push-to-deploy.                                    |

## Skills

### Review

- **[address-pr-comments](./skills/review/address-pr-comments/SKILL.md)** — Reply to every unaddressed review thread on your open PRs, apply and push the mechanical fixes, escalate judgment calls.
- **[adversarial-pr-review](./skills/review/adversarial-pr-review/SKILL.md)** — Presume every change is broken, demand positive proof against the PR's intent docs, and post the verdicts as PR comments.

### Understand

- **[explain](./skills/understand/explain/SKILL.md)** — Explain a PR, commit, code or concept ELI5, with a concrete example, escalating to an HTML artifact when a picture helps.
- **[walkthrough](./skills/understand/walkthrough/SKILL.md)** — Walk through a branch, PR or feature one piece at a time, pausing for "next".
- **[trace-flow](./skills/understand/trace-flow/SKILL.md)** — Trace how data moves across several repos with `file:line` evidence and a critic pass before answering.
- **[improve-codebase-architecture](./skills/understand/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities, present them as an HTML report, then grill through the one you pick.

### Orchestrate

- **[chief-of-staff](./skills/orchestrate/chief-of-staff/SKILL.md)** — Turn a session into a project's long-lived chief of staff that dispatches workers, keeps a private ledger and queues decisions.
- **[afk-loop](./skills/orchestrate/afk-loop/SKILL.md)** — Run the RALPH autonomous issue loop in a sandbox.

### Deploy

- **[deploy-to-exe-dev](./skills/deploy/deploy-to-exe-dev/SKILL.md)** — Provision an exe.dev VM and set up Docker Compose plus push-to-deploy for a Phoenix (or any) web app.

## Creating a new skill

See `CLAUDE.md` for the full convention. Short version:

1. Copy `template/SKILL.md` into `skills/<bucket>/<skill-name>/SKILL.md`.
2. Folder name must match the `name` field in the frontmatter.
3. Add the skill path to the relevant plugin in `.claude-plugin/marketplace.json`.
4. Add a one-line entry in the bucket's `README.md` and in the list above.

## Credits

`improve-codebase-architecture` is adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, see its `LICENSE`).
