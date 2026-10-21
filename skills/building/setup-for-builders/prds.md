# PRDs and Issues

How the building skills should find and write PRDs and issue files.

**Location:** `prds/`

Override this when the skill writes `docs/agents/prds.md` for a specific repo.

## How each skill uses this

- **`/write-a-prd`** writes its output to `<location>/<feature-name>.md`. Feature name comes from the user; slugify if needed.
- **`/prd-to-issues`** writes its output to `<location>/<feature-name>-issues.md`. If multiple PRDs exist, ask the user which one.
- **`/issue-worker`** reads the issues file from `<location>/*-issues.md`. If multiple issues files exist, ask the user which one. Determines the next issue by checking git log for commits referencing previous issue titles — the next issue is the first one in dependency order whose title doesn't appear in a commit message.

## Conventions

- One PRD per feature
- The issues file lives alongside its parent PRD, with the suffix `-issues.md`
- Issues are committed one at a time by `/issue-worker`; the commit message must reference the issue title so subsequent runs know where to pick up
