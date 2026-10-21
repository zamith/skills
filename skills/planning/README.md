# Planning

Skills for shaping work before code: validating the idea, writing the spec, slicing it into issues, prototyping and charting efforts too big for one session.

## Skills

- **[grill-me](./grill-me/SKILL.md)** — Stress-test a plan or design through relentless interviewing.
- **[grill-with-docs](./grill-with-docs/SKILL.md)** — Grilling session that cross-references `CONTEXT.md` and ADRs and updates them inline.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Find deepening opportunities, present them as an HTML report, then grill through the one you pick. Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT).
- **[prd-to-issues](./prd-to-issues/SKILL.md)** — Break a PRD into independently-grabbable issues using tracer-bullet vertical slices.
- **[prototype](./prototype/SKILL.md)** — Build a throwaway prototype: a runnable terminal app for logic questions, or several toggleable UI variations.
- **[setup-for-builders](./setup-for-builders/SKILL.md)** — Scaffold per-repo configuration (domain-doc layout, PRD location) for the planning and building skills. Run once per repo.
- **[wayfinder](./wayfinder/SKILL.md)** — Chart work too big for one session as a map of decision tickets on the issue tracker, then resolve them one at a time. From [mattpocock/skills](https://github.com/mattpocock/skills) (MIT).
- **[write-a-prd](./write-a-prd/SKILL.md)** — Create a product requirements document through user interview and codebase exploration.
- **[zoom-out](./zoom-out/SKILL.md)** — Zoom out and give broader context or a higher-level view of an unfamiliar section of code.

## Workflow

```
 0. Setup           /planning:setup-for-builders (once per repo)
       |
 1. Grill Me        /planning:grill-me        Validate the idea
       |
 2. Write a PRD     /planning:write-a-prd     Turn the idea into a spec
       |
 3. PRD to Issues   /planning:prd-to-issues   Break the spec into vertical slices
       |
 4. Issue Worker    /building:issue-worker    Implement one issue at a time
   /Issue Swarm     /building:issue-swarm     (or fan out several in parallel)
       |
 5. Compound        /building:compound        Capture what was learned
```

You can enter at any step. Already have a PRD? Skip to step 3. Have issues ready? Jump to step 4.
