# Building

Skills for going from a vague idea to implemented, tested and reviewed code.

## Skills

- **[address-pr-comments](./address-pr-comments/SKILL.md)** — Reply to every unaddressed review thread on your open PRs, apply and push the mechanical fixes, escalate judgment calls. Idempotent, so it is safe on a loop.
- **[adversarial-pr-review](./adversarial-pr-review/SKILL.md)** — Presume every change is broken, demand positive proof against the PR's intent docs, and post the verdicts as PR comments.
- **[afk-loop](./afk-loop/SKILL.md)** — Run the RALPH autonomous issue loop in a sandbox.
- **[chief-of-staff](./chief-of-staff/SKILL.md)** — Turn a session into a project's long-lived chief of staff that dispatches workers, keeps a private ledger and queues decisions. The plugin ships a `SessionStart` (compact) hook that re-injects the Start steps after a compaction.
- **[compound](./compound/SKILL.md)** — Capture a just-solved problem into `docs/solutions/` and promote cross-product patterns to auto-memory.
- **[explain](./explain/SKILL.md)** — Explain a PR, commit, code or concept ELI5, with a concrete example, escalating to an HTML artifact when a picture helps.
- **[grill-me](./grill-me/SKILL.md)** — Stress-test a plan or design through relentless interviewing.
- **[grill-with-docs](./grill-with-docs/SKILL.md)** — Grilling session that cross-references `CONTEXT.md` and ADRs and updates them inline.
- **[handoff](./handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Find deepening opportunities, present them as an HTML report, then grill through the one you pick. Adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT).
- **[issue-swarm](./issue-swarm/SKILL.md)** — Fan out up to N issues in parallel, each in its own worktree, gated by a reviewer subagent.
- **[issue-worker](./issue-worker/SKILL.md)** — Pick up the next uncompleted issue, implement it using TDD, and commit.
- **[prd-to-issues](./prd-to-issues/SKILL.md)** — Break a PRD into independently-grabbable issues using tracer-bullet vertical slices.
- **[prototype](./prototype/SKILL.md)** — Build a throwaway prototype: a runnable terminal app for logic questions, or several toggleable UI variations.
- **[setup-for-builders](./setup-for-builders/SKILL.md)** — Scaffold per-repo configuration (domain-doc layout, PRD location) for the building skills. Run once per repo.
- **[trace-flow](./trace-flow/SKILL.md)** — Trace how data moves across several repos with `file:line` evidence and a critic pass before answering.
- **[walkthrough](./walkthrough/SKILL.md)** — Walk through a branch, PR or feature one piece at a time, pausing for "next".
- **[write-a-prd](./write-a-prd/SKILL.md)** — Create a product requirements document through user interview and codebase exploration.
- **[zoom-out](./zoom-out/SKILL.md)** — Zoom out and give broader context or a higher-level view of an unfamiliar section of code.

`address-pr-comments` and `adversarial-pr-review` can use an optional second opinion from TypeSafe's Jev model when `TYPESAFE_API_KEY` is set. Without the key, nothing leaves the machine.

## Workflow

```
 0. Setup           (once per repo: setup-for-builders)
       |
 1. Grill Me        Validate the idea
       |
 2. Write a PRD     Turn the validated idea into a spec
       |
 3. PRD to Issues   Break the spec into vertical slices
       |
 4. Issue Worker    Implement one issue at a time (repeat)
   /Issue Swarm     (or fan out several in parallel)
       |
 5. Compound        Capture what was learned (after a fix or swarm)
```

You can enter at any step. Already have a PRD? Skip to step 3. Have issues ready? Jump to step 4.
