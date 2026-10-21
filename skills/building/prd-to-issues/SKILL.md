---
name: prd-to-issues
description: >
  Break a PRD into independently-grabbable issues using tracer-bullet vertical
  slices. Use when the user wants to convert a PRD to issues, create
  implementation tickets, or break down a spec into work items.
metadata:
  version: 0.2.0
---

# PRD to Issues

Break a product requirements document into independently-grabbable issues that
can be worked on in sequence or parallel.

## Process

0. **Determine PRD location.** Check `docs/agents/prds.md`. If it exists, read the line starting with `**Location:**` and use that path. If not, default to `prds/`. Call this `<prd-location>`.
1. Read the PRD. If multiple PRDs exist in `<prd-location>`, ask the user which one.
2. Identify the **tracer bullet** — the thinnest vertical slice that touches
   every layer (UI, API, database, etc.) and proves the architecture works.
3. Break the remaining work into issues that:
   - Are independently implementable (no circular dependencies).
   - Have clear acceptance criteria.
   - Are small enough to be completed in a single session.
   - Follow a logical dependency order.

## Issue format

Each issue should contain:

```markdown
## [Issue title]

**Depends on:** [list of issue titles this depends on, or "none"]

### Description
What needs to be built and why.

### Acceptance criteria
- [ ] Concrete, testable criteria
- [ ] Another criterion

### Technical notes
Relevant files, modules, patterns to follow, edge cases.
```

## Refactor-shaped work

Some work isn't a vertical slice — it's a wide mechanical change (rename,
schema migration, API version bump, library swap) that touches many call sites.
Don't force it into a tracer bullet. Sequence it as **expand → contract**,
keeping CI green at every step:

1. **Expand** — add the new form alongside the old one, without removing the old.
   One issue.
2. **Migrate** — move call sites over in blast-radius batches. One issue per
   batch, each independently mergeable.
3. **Contract** — delete the old form once nothing references it. One issue,
   depends on all migrate batches.

Use this only for genuinely wide, mechanical changes. Feature work stays a
tracer-bullet vertical slice.

## Output

Save the issues to `<prd-location>/<feature-name>-issues.md` as a single document with
all issues in dependency order. The first issue should always be the tracer
bullet.

## Guidelines

- Prefer vertical slices (feature through all layers) over horizontal slices
  (one layer at a time).
- Each issue should deliver visible, testable progress.
- Include a dependency graph summary at the top of the document.
- Flag any issues that could be worked in parallel.
- Keep issues small — if an issue has more than 5 acceptance criteria, consider
  splitting it.
