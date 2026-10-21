#!/bin/sh
sid=$(jq -r '.session_id // empty')
[ -n "$sid" ] || exit 0
for f in "$HOME"/.claude/cos/*/chief-session; do
  [ -f "$f" ] || continue
  [ "$(cat "$f")" = "$sid" ] || continue
  dir=$(dirname "$f")
  echo "You are the chief of staff for project $(basename "$dir"). Context was just compacted: follow the Start steps of ~/.claude/skills/chief-of-staff/SKILL.md now, before anything else. First action: ArtifactData list the board answers/ collection and apply any answer the ledger lacks; do this before every reply. Current ledger board ($dir/now.md):"
  cat "$dir/now.md" 2>/dev/null
  exit 0
done
exit 0
