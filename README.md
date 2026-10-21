# Skills

Zamith's personal collection of Claude Code skills, published as a plugin marketplace.

## Usage

Register the marketplace in Claude Code:

```
/plugin marketplace add zamith/skills
```

Install a plugin:

```
/plugin install building@zamith
```

## Structure

```
skills/
  building/      # software-building workflow skills
template/        # scaffold for creating new skills
.claude-plugin/  # marketplace registry (copy the skill folder into `~/.claude/skills/`)
```

See `CLAUDE.md` for repo conventions.

## Plugins

| Plugin     | Description                                                                              |
| ---------- | ---------------------------------------------------------------------------------------- |
| `building` | Idea-to-implementation workflow: grill, write a PRD, slice into issues, implement autonomously, understand the code, and review the PRs. |

## Skills

### Building

- **[address-pr-comments](./skills/building/address-pr-comments/SKILL.md)** — Reply to every unaddressed review thread on your open PRs, apply and push the mechanical fixes, escalate judgment calls.
- **[adversarial-pr-review](./skills/building/adversarial-pr-review/SKILL.md)** — Presume every change is broken, demand positive proof against the PR's intent docs, and post the verdicts as PR comments.
- **[afk-loop](./skills/building/afk-loop/SKILL.md)** — Run the RALPH autonomous issue loop in a sandbox.
- **[chief-of-staff](./skills/building/chief-of-staff/SKILL.md)** — Turn a session into a project's long-lived chief of staff that dispatches workers, keeps a private ledger and queues decisions.
- **[compound](./skills/building/compound/SKILL.md)** — Capture a just-solved problem into `docs/solutions/` and promote cross-product patterns to auto-memory.
- **[explain](./skills/building/explain/SKILL.md)** — Explain a PR, commit, code or concept ELI5, with a concrete example, escalating to an HTML artifact when a picture helps.
- **[grill-me](./skills/building/grill-me/SKILL.md)** — Stress-test a plan or design through relentless interviewing.
- **[grill-with-docs](./skills/building/grill-with-docs/SKILL.md)** — Grilling session that cross-references `CONTEXT.md` and ADRs and updates them inline.
- **[handoff](./skills/building/handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[improve-codebase-architecture](./skills/building/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities, present them as an HTML report, then grill through the one you pick.
- **[issue-swarm](./skills/building/issue-swarm/SKILL.md)** — Fan out up to N issues in parallel, each in its own worktree, gated by a reviewer subagent.
- **[issue-worker](./skills/building/issue-worker/SKILL.md)** — Pick up the next uncompleted issue, implement it using TDD, and commit.
- **[prd-to-issues](./skills/building/prd-to-issues/SKILL.md)** — Break a PRD into independently-grabbable issues using tracer-bullet vertical slices.
- **[prototype](./skills/building/prototype/SKILL.md)** — Build a throwaway prototype: a runnable terminal app for logic questions, or several toggleable UI variations.
- **[setup-for-builders](./skills/building/setup-for-builders/SKILL.md)** — Scaffold per-repo configuration (domain-doc layout, PRD location) for the building skills. Run once per repo.
- **[trace-flow](./skills/building/trace-flow/SKILL.md)** — Trace how data moves across several repos with `file:line` evidence and a critic pass before answering.
- **[walkthrough](./skills/building/walkthrough/SKILL.md)** — Walk through a branch, PR or feature one piece at a time, pausing for "next".
- **[write-a-prd](./skills/building/write-a-prd/SKILL.md)** — Create a product requirements document through user interview and codebase exploration.
- **[zoom-out](./skills/building/zoom-out/SKILL.md)** — Zoom out and give broader context or a higher-level view of an unfamiliar section of code.

## Recommended third-party skills

These skills are not in this repo; install them from their upstream sources:

- `tdd`, `teach`, `wayfinder`, `writing-great-skills`, `ubiquitous-language` — [mattpocock/skills](https://github.com/mattpocock/skills) (`/plugin marketplace add mattpocock/skills`)
- `make-interfaces-feel-better` — [jakubkrehel/make-interfaces-feel-better](https://github.com/jakubkrehel/make-interfaces-feel-better) (copy `skills/make-interfaces-feel-better` into `~/.claude/skills/`)
- `improve` — by shadcn, published in the [ibelick/ui-skills](https://github.com/ibelick/ui-skills) registry

## Creating a new skill

See `CLAUDE.md` for the full convention. Short version:

1. Copy `template/SKILL.md` into `skills/<bucket>/<skill-name>/SKILL.md`.
2. Folder name must match the `name` field in the frontmatter.
3. Add the skill path to the relevant plugin in `.claude-plugin/marketplace.json`.
4. Add a one-line entry in the bucket's `README.md` and in the list above.

## Credits

`improve-codebase-architecture` is adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, see its `LICENSE`).
