---
name: adversarial-pr-review
description: Adversarially review a GitHub PR and post the findings back as PR comments — presume every change is broken and demand positive proof it is correct, tried against intent docs (PRD, ADR, specs, tickets) and codebase conventions. Use when the user wants an adversarial or skeptical PR review, a "prove it's right" review, or asks to verify a PR against its stated intent.
---

Ordinary review presumes the code works and scans for bugs, so a change passes the moment no bug jumps out — and the bug you never thought to look for sails through. This skill flips the burden. Every change is **guilty until proven innocent**: you do not hunt for defects, you demand **positive evidence** that the change is correct. No evidence, it stays flagged. The default is failure, and the code has to earn its way out.

## 1. Assemble the intent

Pull the PR and everything that states what the code is *supposed* to do — the standard each change is tried against.

- `gh pr view <n>` and `gh pr diff <n>` — description, linked issues, commit messages.
- Intent docs the repo carries: PRDs, ADRs, feature docs, `CONTEXT.md`, and any API spec (OpenAPI, TypeSpec, GraphQL schema) the change touches.
- Referenced tickets (Jira/Linear) — fetch them if linked.
- Tests as executable intent — they assert what the author believes correct.

**Completion:** for every change you can state, in one sentence, the intent it serves. A change whose intent you cannot locate in any document is itself a finding — record it.

## 2. Prosecute each change

Take every hunk in the diff and try to convict it. The burden is on the code; your job is to prove it right or fail trying. Attack on three fronts:

- **Intent** — does it actually do what the doc says, fully? Or partially, or something adjacent (scope creep, silent behaviour change)?
- **Logic** — trace real inputs against every branch: boundaries, empty, null/undefined, concurrent access, error paths, the unexpected type. Find the input that breaks it. If you cannot, name the input classes you *proved* safe — that naming is the evidence.
- **Contract** — callers, exported types, API/schema shape, DB migrations forward *and* backward. Does the change hold at every seam it touches?

Return a verdict per change:

- **Acquitted** — positive evidence it is correct.
- **Convicted** — a concrete failing case. This is a bug; state the exact input and the wrong result.
- **Hung** — you could prove neither. Flag as unverified and say what proof (a test, an author answer) would settle it. Never wave a hung change through as if acquitted.

**Completion:** every changed hunk carries exactly one of the three verdicts. No hunk is skipped.

## 3. Convention sweep

Separately, hold the diff against codebase-wide conventions — the patterns the rest of the repo follows (naming, error classes, logging, layering, and any coding-standards docs that `CLAUDE.md` or `CONTRIBUTING.md` points to for the touched code). A break here is **not necessarily a bug** — flag it as *address, not block*, citing the convention and a file where the repo establishes it.

## 3½. Jev second opinion (when `TYPESAFE_API_KEY` is set)

If `TYPESAFE_API_KEY` is set, run the judgment calls from steps 2 and 3 past Jev, TypeSafe's System One model. If it is unset, skip this step and say so in the report to the user. Jev returns calibrated probabilities, not proof. Use it to decide where to look again and what is worth posting. **It never acquits, convicts, or hangs a change, and it is never cited in a PR comment.**

Send one request per PR through the helper, which retries 429/529 and exits 3 when the key is missing:

```bash
"${CLAUDE_SKILL_DIR}/jev.sh" < request.json
```

Put the intent, every hunk, and every candidate finding in `state`. Ask all questions together, since they are independent and run in parallel. Split the request if the diff is very large. Question ids are only for you; each question must reference its data by backticked path:

```json
{
  "model": "jev-latest",
  "state": {
    "intent": "<the one-sentence intent from step 1, plus the doc excerpt it came from>",
    "hunks": { "h1": "<file + diff hunk>", "h2": "..." },
    "findings": { "f1": { "verdict": "convention", "file": "...", "comment": "<draft comment>", "code": "<the lines it indicts>" } }
  },
  "questions": {
    "fit_h1": {
      "type": "choice",
      "instructions": "How does the change in `hunks.h1` relate to what `intent` says the PR is for?",
      "criteria": {
        "serves": "Does what the intent describes, and nothing beyond it",
        "partial": "Serves the intent but leaves part of it undone",
        "adjacent": "Also changes behaviour the intent never mentions: scope creep or a silent behaviour change",
        "unrelated": "No connection to the intent"
      }
    },
    "post_f1": {
      "type": "noul",
      "instructions": "Would a senior engineer on this repository want the review comment `findings.f1.comment` posted on this PR, given `findings.f1.code`?",
      "criteria": { "true": "Points at something the author should change or knowingly accept", "false": "Noise: restates the obvious, nitpicks style the linter already owns, or asks for no action" }
    }
  }
}
```

Apply this policy in code, and report the numbers to the user:

- **Intent fit:** if `serves` gets under 0.7 probability for a hunk you acquitted, go back and re-run step 2's Intent attack on that hunk. The verdict still comes from your evidence, not from Jev.
- **Convention findings:** drop one when `post_*` < 0.35, and list it to the user as dropped with its probability. Between 0.35 and 0.6, post it only if you can name the file where the repo sets the convention.
- **Convicted and hung findings:** always post them, whatever Jev says. Jev may only reorder them.

## 4. Post the verdict to the PR

Every conviction, hung change, and convention break becomes a comment on the PR — anchored to the line it indicts, not buried in a wall of text. Post them without asking: the review is the deliverable, so do not stop to request a go-ahead. Report the full set to the user after posting, with the review URL.

- **Inline comment per finding**, on the exact file and line, via a single pending review:
  - `gh api repos/{owner}/{repo}/pulls/{n}/comments -f commit_id=<head_sha> -f path=<file> -F line=<n> -f side=RIGHT -f body=<finding>`, or batch them under one `gh pr review`.
  - Head SHA: `gh pr view <n> --json headRefOid -q .headRefOid`.
- **Prefix each comment with its verdict** so the label carries: `🔴 Convicted —` (bug, blocking), `⚠️ Hung —` (unverified, name the proof that would close it), `📐 Convention —` (address, not block, cite where the repo sets it). Each states the change, the intent it was tried against, and the exact failing case or missing proof.
- **One summary review body** leading with the count in each bucket, so the author sees the shape at a glance. Submit convictions as `--request-changes`, an all-clear as `--approve`.

Acquittals are not posted — a proven-correct change earns silence, not noise. Report them only to the user, as a terse list.
