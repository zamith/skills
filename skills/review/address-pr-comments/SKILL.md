---
name: address-pr-comments
description: Address unaddressed review comments on your open GitHub PRs — reply to each thread, apply mechanical fixes and push, escalate judgment calls. Use when the user wants to process PR review feedback, handle reviewer comments on their PRs, or run a PR-comment loop.
---

# Address PR Comments

One pass over your open PRs: reply to every **unaddressed** thread, apply the **mechanical** fixes, and leave the **judgment calls** for the human. Designed to be **idempotent** — a re-run only touches threads you haven't replied to yet, so it is safe on a loop.

Reference command recipes (gh / GraphQL) live in [`github-api.md`](github-api.md) — open it when you need exact query syntax.

## Core distinctions

**unaddressed** — a thread whose *latest* comment author is not you. Your reply is what marks a thread handled; you never resolve threads, so "last comment is mine" is the only done-signal. This is what keeps the loop idempotent.

**mechanical vs judgment call** — the gate for every thread:
- **mechanical** — a clear, self-contained change you can make and verify: rename, extract, fix a bug the reviewer pinpointed, apply a suggested edit, add a test, adjust types. Sprawl across many files does *not* disqualify it — size alone is fine.
- **judgment call** — leave the code untouched, reply only. A thread is a judgment call when *any* of:
  - the ask is **ambiguous** — you can't tell confidently what change is wanted;
  - it's a **design/architecture disagreement** — challenges an approach or wants a non-mechanical redesign;
  - it needs a **product/domain decision** you can't make.

  When unsure which side a thread is on, it's a judgment call.

**green** — a mechanical fix must leave the touched package's checks green before it is pushed. If you can't get it green, revert the change and downgrade the thread to a judgment call.

## Steps

1. **Scope the PRs.** Target repo = the `--repo` arg if given, else the current repo. List your open, non-draft PRs (see `github-api.md`). If a run finds none, report that and stop.
   - Record the current branch and confirm the working tree is clean. If it's dirty, stop and tell the user — do not stash or discard their work.

2. **Collect unaddressed threads** for each PR: inline review threads, review summaries, and general PR comments where the latest comment isn't yours. Completion for this step is *exhaustive* — every open thread on the PR is classified as either already-yours (skip) or unaddressed (queue). Don't sample.

3. **Classify** each unaddressed thread as **mechanical** or **judgment call** using the gate above.
   - **Jev pre-screen (only when `TYPESAFE_API_KEY` is set).** Check with `[ -n "$TYPESAFE_API_KEY" ]`; when unset, skip this bullet entirely and classify as before. When set, pipe each PR's unaddressed threads to `node "${CLAUDE_SKILL_DIR}/jev-classify.mjs"` (input/output shape in the script header; include `diffHunk` for inline threads). Then:
     - A thread is **mechanical** only when Jev's `route` is `mechanical` **and** your own gate agrees. Any other combination is a judgment call — Jev can veto a fix, never force one.
     - Jev's `choice` (`ambiguous`, `design_disagreement`, `product_decision`, `reply_only`) is a hint for phrasing the judgment-call reply, not a verdict.
     - A thread whose result has `error`, or a script that exits non-zero, falls back to your own gate for those threads. Mention the failure in the final summary.
   - Sending comments and diff hunks to TypeSafe is the point of setting the key; without it, nothing leaves the machine.

4. **Apply mechanical fixes.** Check out the PR branch (`gh pr checkout <n>`). For each mechanical thread: make the change, run the touched package's checks (type-check / lint / unit test — see the project's commands), and confirm **green**. Commit per thread following the **commit-conventions** skill so each reply can cite its own sha. If a fix won't go **green**, `git checkout -- .` that change and move the thread to judgment-call.

5. **Push** once per PR, after its mechanical commits land. Only ever add commits — never force-push, rebase, or amend a pushed commit. If checkout, push, or a merge conflict fails, escalate the whole PR (reply on the blocking thread explaining) and leave its branch alone.

6. **Reply to each thread individually** (leave every thread open — never resolve):
   - mechanical → what you changed and the sha.
   - judgment call → why it needs them, or the specific question you need answered.

7. **Watch CI event-driven, never on a timer.** For each PR you pushed to, arm one background watcher — `gh pr checks <n> --watch` with `run_in_background: true` — and move on; the watcher re-invokes you when checks reach a terminal state. Never sleep-and-poll.
   - **Stall guard**: if no check has even *started* within ~3 minutes of the push, surface that to the user instead of waiting silently — the pipeline may be stuck or unconfigured.
   - On failure caused by your mechanical commits: treat it as a new mechanical fix (steps 4–6) if the cause is clear, otherwise reply on the relevant thread and escalate.

8. **Finish.** Return to the original branch. Report a per-PR summary: threads fixed+pushed, threads escalated, threads skipped as already-yours, CI status per pushed PR. When the Jev pre-screen ran, add each thread's Jev `choice` and `probabilities.mechanical`, and flag every thread where Jev and your own gate disagreed.

## Loop mode (re-entry)

When run repeatedly (e.g. via `/loop`), take a **baseline once** at the start of the first run: snapshot the IDs of all comments already present. Later runs process only threads that are unaddressed *and* contain a comment newer than the baseline — this prevents reprocessing threads that predate the loop and keeps re-entry cheap. The "latest comment author is not you" rule still decides what's unaddressed; the baseline only bounds how far back a run looks.

## Guardrails

- Only ever touch PRs authored by you (the scope query enforces this) — never push to anyone else's branch.
- Never push red code; never force-push, rebase, or amend.
- A dirty working tree, a checkout failure, or a merge conflict stops that PR — surface it, don't work around it.
