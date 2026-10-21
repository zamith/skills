---
name: setup-for-builders
description: Sets up an `## Agent skills` block in CLAUDE.md/AGENTS.md and `docs/agents/` so the building skills know this repo's domain-doc layout and where PRDs and issue files live. Run before first use of `write-a-prd`, `prd-to-issues`, `issue-worker`, or `grill-with-docs` — or if those skills appear to be missing context about where to read or write files.
disable-model-invocation: true
---

# Setup for Builders

Scaffold the per-repo configuration that the building skills assume:

- **Domain docs** — where `CONTEXT.md` and ADRs live, and how the skills should consume them
- **PRDs and issues** — where `write-a-prd` writes PRDs, where `prd-to-issues` writes issue files, where `issue-worker` reads them from

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Process

### 1. Explore

Look at the current repo to understand its starting state. Read whatever exists; don't assume:

- `git remote -v` and `.git/config`
- `CLAUDE.md` and `AGENTS.md` at the repo root — does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — has this skill already run?
- `prds/`, `docs/prds/`, `.scratch/prds/` — existing PRD location convention?

### 2. Present findings and ask

Summarise what's present and what's missing. Then walk the user through the two decisions **one at a time** — present a section, get the user's answer, then move to the next. Don't dump both at once.

Each section starts with a short explainer (what it is, why the skills need it). Then show the choices and the default.

**Section A — Domain docs.**

> Explainer: `grill-with-docs` reads `CONTEXT.md` for this project's ubiquitous language and `docs/adr/` for past architectural decisions. It needs to know whether the repo has one global context or several (e.g. a monorepo with separate frontend/backend contexts) so it looks in the right place.

Choices:

- **Single-context** (default) — one `CONTEXT.md` + `docs/adr/` at the repo root. Most repos are this.
- **Multi-context** — `CONTEXT-MAP.md` at the root pointing to per-context `CONTEXT.md` files (typically a monorepo).

**Section B — PRD location.**

> Explainer: `write-a-prd` writes a PRD to `<location>/<feature>.md`. `prd-to-issues` writes `<location>/<feature>-issues.md`. `issue-worker` reads from the same location. Pick where these files live.

Default posture: if a `prds/` directory already exists, propose that. Otherwise default to `prds/`. Choices:

- **`prds/`** (default) — top-level convention
- **`docs/prds/`** — alongside other docs
- **`.scratch/prds/`** — ephemeral / gitignored work
- **Custom path** — user-supplied

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/domain.md` and `docs/agents/prds.md`

Let them edit before writing.

### 4. Write

**Pick the file to edit:**

- If `CLAUDE.md` exists, edit it.
- Else if `AGENTS.md` exists, edit it.
- If neither exists, ask the user which one to create — don't pick for them.

Never create `AGENTS.md` when `CLAUDE.md` already exists (or vice versa) — always edit the one that's already there.

If an `## Agent skills` block already exists in the chosen file, update its contents in-place rather than appending a duplicate. Don't overwrite user edits to the surrounding sections.

The block:

```markdown
## Agent skills

### Domain docs

[single-context | multi-context]. See `docs/agents/domain.md`.

### PRDs and issues

PRDs live in `<location>/<feature>.md`; issue files in `<location>/<feature>-issues.md`. See `docs/agents/prds.md`.
```

Then write the two docs files using the seed templates in this skill folder as a starting point:

- [domain.md](./domain.md) — domain doc consumer rules + layout
- [prds.md](./prds.md) — PRD and issue file conventions

Substitute the chosen domain-docs layout and PRD location into the templates before writing.
### 5. Done

Tell the user the setup is complete and which building skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later — re-running this skill is only necessary if they want to switch the domain-doc layout or PRD location.
