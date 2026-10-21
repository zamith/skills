# Building

Skills for implementing and shipping: working issues, understanding code, reviewing and answering PRs, handing off and capturing what was learned.

## Skills

- **[address-pr-comments](./address-pr-comments/SKILL.md)** — Reply to every unaddressed review thread on your open PRs, apply and push the mechanical fixes, escalate judgment calls. Idempotent, so it is safe on a loop.
- **[adversarial-pr-review](./adversarial-pr-review/SKILL.md)** — Presume every change is broken, demand positive proof against the PR's intent docs, and post the verdicts as PR comments.
- **[afk-loop](./afk-loop/SKILL.md)** — Run the RALPH autonomous issue loop in a sandbox.
- **[chief-of-staff](./chief-of-staff/SKILL.md)** — Turn a session into a project's long-lived chief of staff that dispatches workers, keeps a private ledger and queues decisions. The plugin ships a `SessionStart` (compact) hook that re-injects the Start steps after a compaction.
- **[compound](./compound/SKILL.md)** — Capture a just-solved problem into `docs/solutions/` and promote cross-product patterns to auto-memory.
- **[explain](./explain/SKILL.md)** — Explain a PR, commit, code or concept ELI5, with a concrete example, escalating to an HTML artifact when a picture helps.
- **[handoff](./handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[humanizer](./humanizer/SKILL.md)** — Remove signs of AI-generated writing from text (PR descriptions, docs, messages). Based on Wikipedia's "Signs of AI writing" guide.
- **[issue-swarm](./issue-swarm/SKILL.md)** — Fan out up to N issues in parallel, each in its own worktree, gated by a reviewer subagent.
- **[issue-worker](./issue-worker/SKILL.md)** — Pick up the next uncompleted issue, implement it using TDD, and commit.
- **[trace-flow](./trace-flow/SKILL.md)** — Trace how data moves across several repos with `file:line` evidence and a critic pass before answering.
- **[walkthrough](./walkthrough/SKILL.md)** — Walk through a branch, PR or feature one piece at a time, pausing for "next".

`address-pr-comments` and `adversarial-pr-review` can use an optional second opinion from TypeSafe's Jev model when `TYPESAFE_API_KEY` is set. Without the key, nothing leaves the machine.

The workflow starts in the [planning](../planning/README.md) plugin.
