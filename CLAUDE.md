# Repo Conventions

This file tells Claude Code how this repo is organized.

## Skill organization

Skills are organized into bucket folders under `skills/`, one bucket per plugin:

- `building/` — daily software-building workflow (grilling, PRDs, issues, autonomous implementation, understanding code, PR review)

Every skill must have:

- A one-line reference in the top-level `README.md`
- An entry in the relevant plugin's `skills` array in `.claude-plugin/marketplace.json`
- A one-line entry in its bucket's `README.md`, with the skill name linked to its `SKILL.md`

Bundled scripts are referenced through `${CLAUDE_SKILL_DIR}` (in a skill) or `${CLAUDE_PLUGIN_ROOT}` (in a hook), never through an absolute or `~/.claude/skills` path.

## Privacy

This repo holds no client, employer or personal project data: no client or product names, account ids, internal URLs, people's names, or absolute home paths. Project-specific files that a skill writes at runtime (for example chief-of-staff briefs under `projects/`) stay out of the repo.

## Adding a new skill

1. Copy `template/SKILL.md` into a new folder under `skills/<bucket>/`.
2. The folder name must match the `name` field in the frontmatter.
3. Add the skill path to the relevant plugin in `.claude-plugin/marketplace.json`.
4. Add a one-line entry in the bucket's `README.md`.
5. Add a one-line reference in the top-level `README.md`.
