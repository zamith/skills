---
name: explain
description: Explain anything ELI5 — a PR, a commit, a chunk of code, a topic across the codebase, or any concept — with concrete examples, escalating to an HTML artifact when a picture beats prose.
disable-model-invocation: true
argument-hint: "What should I explain? (PR/commit/file/topic)"
---

The user wants to *understand* something, not receive a summary of it. Explain it **ELI5**: plain words first, jargon only after it's earned, and a **toy** example wherever one fits.

## 1. Get ground truth

Never explain from names, titles, or memory. Read the actual thing first.

| Target | Ground truth |
|---|---|
| PR | `gh pr view <n> --json title,body,comments` + `gh pr diff <n>`; then read the touched files around the diff for context the diff hides |
| Commit / range | `git show <sha>` / `git log -p <range>`; `git show <sha>^:<file>` when the before-state matters |
| Working changes | `git diff` (+ `--staged`) |
| Chunk of code | Read the file, then the callers and the callees — one hop each way |
| Codebase topic | Search wide (grep/glob or an Explore agent), read the 3–6 files that actually carry the topic, follow one real path end to end |
| Non-code topic | Your own knowledge; web search when it's current-events or version-specific |

Done when you can state what the thing *does* without reading it again. If ground truth contradicts the PR description or a comment, say so — that's usually the most valuable sentence in the explanation.

## 2. Find the spine

One sentence, no jargon, that a smart person outside the project would understand. It answers *what changed / what this is* and *why anyone cares*.

> "Logins were failing on the last day of a token's life, because the expiry check used `<` where it needed `<=`."

Everything else in the explanation hangs off the spine. If you can't write it, you don't have ground truth yet — go back to step 1.

## 3. Explain, gist first

In order, dropping anything the target doesn't need:

1. **Spine** — the sentence from step 2.
2. **Stakes** — who is affected, what breaks or improves. Skip for pure-concept questions with no stakes.
3. **Mechanism** — how it actually works, in plain words. Explain the *behaviour*, never a paraphrase of the code: "it retries three times, doubling the wait each time" beats "it calls `retry` with `backoff: 'exponential'`".
4. **Toy** — the smallest concrete instance: real input → real output, a two-line before/after, a walked-through scenario with actual values. For a diff, the toy is the case that behaves differently now. Reach for an analogy when the domain is unfamiliar, but land it back on the real thing — an analogy that isn't cashed out is decoration.
5. **Real names** — now bind the plain words to the actual identifiers and `file:line` refs, so the user can verify you and go deeper. Code targets end here; a concept doesn't need it.
6. **Loose ends** — what you're unsure of, what the change doesn't cover, the follow-up question worth asking.

Pay off **jargon debt**: every term you introduce is either avoided or defined in the sentence that introduces it. Domain terms the user's own repo uses are free — they already know those.

Match depth to the target: a one-line commit gets a paragraph. A 40-file PR gets sections, one per coherent piece of the change, each with its own mini-spine.

## 4. Prose or artifact

Terminal prose is the default. Build an HTML artifact only when the content is genuinely visual:

- More than ~4 moving parts whose *relationships* are the point (architecture, data flow, module graph)
- A sequence or state machine worth drawing
- A big PR where a per-area map orients better than linear text
- A before/after that reads better side by side
- The user says they want to share it, or asks for a diagram/page

Load the `artifact-design` skill before writing it, and `artifact-diagramming` for the diagrams. The artifact carries the *same* structure as step 3 — it is not an excuse to skip the spine or the toy. When you publish one, say the spine in the terminal too; don't make the user open a page to learn the headline.

## Failure modes

- **Paraphrase** — narrating the code in English ("this function loops over the users and calls save"). The user can read code. Explain what it *means* and why it's shaped that way.
- **Summary drift** — listing what changed instead of explaining it. A bulleted file-by-file inventory is a changelog, not an explanation.
- **Unearned jargon** — the first sentence containing three project-internal nouns. ELI5 means the gist survives with all of them removed.
- **Assumed intent** — stating *why* a change was made when the diff doesn't say. Look for it in the PR body, commit message, linked issue, or ADR; if it isn't there, mark it as your inference.
