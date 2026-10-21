#!/usr/bin/env bash
# One-time exe.dev server bootstrap for git push-to-deploy.
# Run locally from the repo root AFTER the VM exists (ssh exe.dev new --name <vm>).
#
# Usage: ./setup-server.sh <vm-name>
#
# Creates the bare deploy repo, installs the post-receive hook, makes the env +
# uploads dirs, installs Docker if missing, and adds a local `deploy` git remote.
# It does NOT write secrets — you fill in /home/exedev/env/.env afterwards.
set -euo pipefail

VM="${1:?usage: setup-server.sh <vm-name>}"
HOST="${VM}.exe.xyz"
HOOK_SRC="$(cd "$(dirname "$0")" && pwd)/post-receive"

[ -f "$HOOK_SRC" ] || { echo "ERROR: post-receive not found next to this script"; exit 1; }

echo "==> Installing Docker on ${HOST} if missing"
ssh "${HOST}" 'command -v docker >/dev/null 2>&1 || (curl -fsSL https://get.docker.com | sudo sh)'

echo "==> Creating dirs + bare repo on ${HOST}"
ssh "${HOST}" '
  set -e
  mkdir -p /home/exedev/app /home/exedev/env /home/exedev/uploads
  if [ ! -d /home/exedev/deploy.git ]; then
    git init --bare /home/exedev/deploy.git
  fi
  touch /home/exedev/env/.env
'

echo "==> Installing post-receive hook"
scp "$HOOK_SRC" "${HOST}:/home/exedev/deploy.git/hooks/post-receive"
ssh "${HOST}" 'chmod +x /home/exedev/deploy.git/hooks/post-receive'

echo "==> Adding local git remote 'deploy'"
git remote remove deploy 2>/dev/null || true
git remote add deploy "ssh://exedev@${HOST}/home/exedev/deploy.git"

cat <<EOF

==> Server ready. Next steps:
  1. Fill in production secrets:
       ssh ${HOST} 'nano /home/exedev/env/.env'      # use .env.example as the key list
       SECRET_KEY_BASE -> mix phx.gen.secret ; PHX_HOST=${HOST}
  2. Deploy:
       git push deploy main
  3. (Once, if the proxy doesn't auto-pick 4000) point it explicitly:
       ssh exe.dev share port ${VM} 4000
  4. Serve publicly:
       ssh exe.dev share set-public ${VM}
  App: https://${HOST}/
EOF
