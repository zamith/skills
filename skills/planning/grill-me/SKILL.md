---
name: grill-me
description: >
  Use when user wants to stress-test a plan or design through relentless
  interviewing, or mentions "grill me". Walks each branch of the decision tree
  to reach shared understanding.
metadata:
  version: 0.3.0
---

Interview me relentlessly about every aspect of this plan until we reach a
shared understanding. Walk down each branch of the design tree, resolving
dependencies between decisions one-by-one. For each question, provide your
recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase
instead.

## Before you start

**Name the destination.** State in one line what "done" looks like for this
plan, and confirm it with me. Every question should serve reaching it.

**Go breadth-first before depth-first.** First surface *every* open decision
across the whole plan — don't start resolving yet. Then walk them one at a
time. This stops you rabbit-holing down one branch while other branches sit
unexplored.

**Apply the fog test.** Only pose a question when you can state it *precisely*
now — not when you can answer it now. If a decision clearly matters but you
can't phrase it sharply yet, park it as "not yet sharp" and return to it once
the frontier advances. Don't pre-slice fog into fake questions.
