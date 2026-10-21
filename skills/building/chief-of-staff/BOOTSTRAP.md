# Bootstrapping a project

Run this once, when `projects/<slug>.md` does not exist yet.

1. **Setup.** Propose these defaults and confirm them with the user:
   - ledger directory: `~/.claude/cos/<slug>/` (it must be outside every repo; `compact-hook.sh` only looks under `~/.claude/cos/`, so a different path needs the hook edited too)
   - worker settings file: `~/.claude/skills/chief-of-staff/projects/<slug>.settings.json`
   - worker name pattern: `<slug>-<ticket>`
   - launcher: ask whether workers should open as [agent of empires](https://github.com/njbrake/agent-of-empires) sessions, so the user can watch them in its TUI, or as plain `claude --bg` sessions. Not everyone has aoe: offer it only if `which aoe` finds it, and default to `claude --bg` otherwise. For aoe, also confirm the group: default to the chief's own group, from `aoe session current` / `aoe list`.

   Write the settings file so workers cannot touch the ledger and compact at 200k tokens (quality drops as context grows, well before the 1M limit):
   ```json
   { "autoCompactWindow": 200000, "permissions": { "deny": ["Read(<ledger>/**)", "Edit(<ledger>/**)", "Bash(*<ledger>*)"] } }
   ```
   Write a chief settings file, `~/.claude/skills/chief-of-staff/projects/<slug>.chief.settings.json`, containing only `{ "autoCompactWindow": 400000 }`. Tell the user to start chiefs with `--settings` pointing at it (or run `/autocompact 200k`).
2. **Mine.** Dispatch a subagent to mine the user's past sessions for this project. They are in `~/.claude/projects/<cwd with / replaced by ->*` (worktree folders included). It reads only the human-typed prompts and returns, in under 600 words:
   - the most-pasted links (trackers, epics, specs, PRs, artifacts), with counts;
   - the instructions the user repeats (branching, PR, review and style rules);
   - the sibling repos and where they live;
   - the active work streams from the last 3 weeks.
3. **Write.** Create the brief with these sections: **Setup** (from step 1), **Links**, **Repos**, **Conventions**, **Streams**, **Product decisions**. Only include what workers need and cannot find themselves: no code structure, and nothing the project's CLAUDE.md already says.
4. Show the brief to the user and fold in their corrections. It is done when they confirm it.
