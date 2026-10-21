---
name: walkthrough
description: Walk the user through a body of work one piece at a time, pausing after each for them to say "next". Explains the change ELI5 — simple language, zero jargon inflation — while staying literally accurate and never renaming a symbol. Use when the user asks to be walked through a branch, PR, diff, commit range, feature, or unfamiliar area of the codebase, or says "explain this branch", "walk me through X", "show me the relevant pieces one at a time".
---

# Walkthrough

A guided, paced tour of a body of work. The user drives: you present one piece, then **stop and wait**. They say "next". They may interrupt with a question at any point — answer it fully, then offer "next" again.

## Scope

Default scope is the current branch versus the main branch. Other common scopes: a PR, a commit range, a single commit, a feature area, an unfamiliar subsystem. If the user's phrasing is ambiguous between two plausible scopes, pick the most likely one and say which you picked in the first sentence — don't open with a clarifying question.

## Establish scope first

Read before you narrate. Typical opening:

```bash
git log --oneline main..HEAD
git diff --stat main...HEAD
```

Then read the actual diff — `git diff main...HEAD -- <paths>` — in chunks, not all at once. Read enough surrounding source to understand *why*, not just *what*: a diff hunk rarely explains itself. If the change calls a helper you have not read, read the helper.

Never narrate a file you have not read. Never describe behaviour you inferred from a name.

## The opening message

One message, before any code. It contains:

1. **The scope**, named concretely — how many commits, what the subject line is.
2. **The problem in plain terms** — the domain situation that made this work necessary. Name the systems involved and what each one is for. If there is a user-visible symptom, state it.
3. **The fix in one sentence.**
4. **A map** — a small table of the layers or files touched and what each contributes. This is the table of contents for the rest of the walkthrough.
5. **A stop**: "Say **next** for X." Name what comes next so they can redirect.

Keep it to what fits on a screen. Detail belongs in the sections that follow.

## Each subsequent piece

One concept per message. Structure:

- **A heading naming the piece and its `path/to/file.ts:line`** — clickable.
- **The code**, pasted verbatim in a fenced block with the right language. Paste the real thing, including its doc comment if it has one; do not paraphrase code into prose and do not trim a comment that carries the reasoning.
- **The ELI5 explanation** — see below.
- **The subtlety** — the part a reader would get wrong. Most pieces have exactly one. Pull it out and give it its own space.
- **A stop**: "Say **next** for X."

Order pieces so each one only depends on what came before. Bottom-up usually works: data layer, then pure logic, then wiring. Follow the data, not the file tree.

## What ELI5 means here

Simple *language*, not simplified *content*. The reader is capable; they just lack this context.

- Short sentences. Concrete nouns. Active voice.
- Explain the domain concept before the code that implements it. "The CRM stores one row per pair; the signup form is a cross product" comes before the function that reconciles them.
- Use an analogy or a small ASCII table when a shape is hard to say in a sentence. A 4-line matrix beats a paragraph about rectangularity.
- Explain *why* a line exists, not what it does. `.trim().toLowerCase()` is obvious; that two writers spell the same email two different ways is not.

Hard constraints:

- **Never rename anything.** Variables, functions, types, DB fields, status values — use the exact identifier from the source, every time. Do not "simplify" `sourceUserId` to "the user id" in a way that implies that is its name. Backticks around real identifiers.
- **Never invent** a mechanism, a rationale, or a number. If the code's comment cites a date, a count, or an ADR, quote it. If you do not know why something is the way it is, say so — "the comment does not say" is a legitimate answer.
- **Never soften a known cost.** If the change has a stated tradeoff or a TODO-shaped compromise, surface it in the piece where it lives.

## Handling questions mid-walkthrough

The user will interrupt, often with "why not do it the other way instead?". Treat it as a real design question, not an objection to deflect.

- Go look. Read the entity, the index definition, the caller — whatever settles it factually.
- Answer with evidence from the code, citing `file:line`.
- Give a verdict. If their alternative is worse, say why in concrete terms (cost, cardinality, staleness, a semantic claim it would make falsely). If it is better, say that plainly.
- Then return: "Say **next** for X."

Do not restart the walkthrough or re-summarize what you already covered.

## Ending

After the last piece, one short closing line and an open offer to go deeper on anything. No recap — they just read it.
