---
name: issue-worker
description: >
  Pick up the next uncompleted issue from a PRD issues file, implement it using
  TDD, and commit. Use when the user wants to work on the next issue, mentions
  "work the issues", or wants to implement a specific issue from a PRD.
metadata:
  version: 0.4.0
---

# Issue Worker

Implement the next uncompleted issue from a PRD issues file. One issue, one
commit. Test-driven.

## Before you start

1. **Determine PRD location.** Check `docs/agents/prds.md`. If it exists, read
   the line starting with `**Location:**` and use that path. If not, default to
   `prds/`. Call this `<prd-location>`.
2. **Find the issues file.** Look for `<prd-location>/*-issues.md`. If multiple
   exist, ask the user which one.
3. **Find the parent PRD.** Look for the corresponding `<prd-location>/<feature>.md` for
   context. You may reference it but do NOT implement beyond the current issue.
4. **Determine the next issue.** Check git log for commits that reference
   previous issue titles. The next issue is the first one in dependency order
   whose title doesn't appear in a commit message.
5. **Check dependencies.** If the next issue depends on issues that haven't
   been committed yet, stop and tell the user.
6. **Read the issue carefully** — understand what files to create or modify.
7. **Read existing related code** to understand patterns, conventions, and
   abstractions already in place. Follow them.
8. Plan your approach, then execute.

## Implementation

1. **Follow TDD.** Write failing tests first, then implement, then verify tests
   pass.
2. **Only implement what the issue asks for.** Do not touch code outside the
   issue scope.
3. **Follow existing patterns.** Read similar code in the codebase before
   writing new code.
4. **Use specialized agents** (via the Agent tool) when a subtask matches an
   agent's expertise. Parallelise independent agent work where possible.
5. **If blocked or unsure, do NOT guess.** Stop and report what you're stuck on.

## Adversarial review (before committing)

Before you commit, dispatch a reviewer subagent (via the Agent tool) to attack your own change. Do NOT skip this and do NOT review your own work inline — a fresh agent catches what the author misses.

The reviewer's job is to catch defects, not to bless the work. Its default stance: **the diff is broken until proven otherwise.** Approving is the exception — only approve after actively trying to break the change and failing.

Give the reviewer a self-contained prompt: the issue title + body, the `git diff` of your uncommitted changes, the project test command, and these instructions:

- Run the test suite. Paste actual output. Never take "tests pass" on faith.
- Read the full diff line by line. Assume each change is wrong and hunt for the reason:
  - **Correctness**: logic bugs, off-by-one, wrong operators, inverted conditions, bad defaults.
  - **Edge cases**: empty/null/undefined, zero, negative, large inputs, concurrent access, partial failure, error paths. Construct a concrete failing input and state it.
  - **Test quality**: do tests assert real behavior or pass vacuously? Is each acceptance criterion covered? Weak tests = request-changes.
  - **Scope creep**: anything outside the issue → request-changes.
  - **Pattern violations**: follows existing conventions/abstractions? Read neighbouring code to confirm.
  - **Design smells (over-abstraction)**: judge modules on depth, not size.
    - *Deletion test* — mentally remove the new module/wrapper. If its complexity just vanishes and callers get simpler, it's a pass-through adding interface for no behaviour → request-changes.
    - *One adapter, no seam* — a new interface/abstraction introduced with a single implementation and no real, present variation is premature. Don't bless a seam until there are genuinely two things behind it.
    - Flag shallow modules (large interface, little behaviour) and leaked internals (callers must know implementation details to use it correctly).
  - **Security / data integrity**: injection, unvalidated input, leaked secrets, unguarded destructive ops.
- Return `{"verdict":"approve"|"request-changes","tests_passed":true|false,"notes":"..."}` with specific file/line-level notes. When uncertain whether something is a defect, lean `request-changes`. Reviewer never edits code.

If the reviewer returns `request-changes`, fix the issues and re-review. Repeat up to 3 cycles. If still failing after 3 cycles, stop and report to the user — do not commit.

## When done

Once the reviewer returns `approve` with `tests_passed: true`, follow these steps in order:

1. Run the project's test suite and confirm all tests pass.
2. **Remove the implemented issue** from the issues file. The feature itself becomes the documentation now; the issue is no longer needed.
3. **If this was the last issue**, also delete the parent PRD file and the issues file. Do NOT touch ADRs — they live in `docs/adr/` and are managed by the grilling session, not by this skill.
4. Stage all changed files with `git add` (code + issues file removal + PRD deletion if applicable).
5. Create exactly ONE commit using this template:

```
<50-char present-tense subject describing the change>

Why:

* <one-line bullet on the need this change addresses>

This change addresses the need by:

* <one-line bullet on how the change addresses it>
* <side effects, if any>

Implements issue: <issue title>
```

Wrap the body at 72 columns. The `Implements issue:` trailer is required — it is what keeps next-issue detection working via `git log --grep`. Keep it even though the issue has been removed from the file.

6. Verify the commit exists with `git log -1`.
7. Report what was done and what the next issue in the queue is (or "PRD complete" if this was the last).

## If you cannot complete the work

Stop and report:
- What you attempted
- What specifically is blocking you
- Whether the issue needs to be revised

Do NOT commit incomplete work silently. Do NOT guess your way past blockers.

## Guidelines

- One invocation = one issue = one commit.
- Never force-push or amend previous issue commits.
- Run the full test suite before committing — don't break previous work.
