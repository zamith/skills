---
name: trace-flow
description: Trace how data moves across several repos (who writes it, who reads it, which transport carries it, where it lands) with file:line evidence before answering or drafting anything. Use when a question or document depends on cross-repo data flow, source of truth, field mappings, or whether some data "has a home" in a downstream system.
---

Every claim in the answer is **traced**: backed by a `repo/path:line` (or PR link) someone can open. Anything not traced is marked **UNVERIFIED**. Nothing gets written for the user until the trace survives the critic.

## 1. Frame the trace

- Restate the question as the entities or fields that move, and the hops they might take (system → transport → system).
- List the repos on the path: the current one plus sibling repos named in the project's CLAUDE.md (for example a "Related repositories" table). Confirm each local path exists. Ask the user only about a hop that no known repo covers.
- For each repo, note its default branch and the user's open PRs (`gh pr list --author @me`), because in-flight work often changes the answer.

Done when: every hop has a named repo with a real local path, or is listed as an unknown hop.

## 2. Fan out, one agent per repo

Launch all repo agents in one message so they run in parallel (`Explore`, thoroughness "very thorough"). Give each one this brief, filled in:

```
Repo: <path>. Question: <framed question>. Entities/fields: <list>.
Report, each item with repo/path:line:
1. Producers: where these entities/fields are created or written (DB, stream, queue, API, file).
2. Consumers: where they are read, and what triggers the read.
3. Payload: the exact field names and types at each boundary (the event schema, API model, table columns).
4. Transport: the stream, topic, queue, endpoint or table name, and the IAM/infra that wires it if it lives here.
5. Open PRs by the user that touch any of this: PR number, branch, what changes.
6. Negative findings: for anything you conclude is absent ("X is never sent", "no table for Y"), list the searches you ran (terms, paths, file globs).
State only what you located. "Not found after searching <terms>" is a valid answer; guessing is not.
```

Done when: every repo agent has reported back.

## 3. Merge into an evidence table

One row per field per hop:

| Field | From | Via | To | Required? | Evidence |
|---|---|---|---|---|---|

- A row without evidence is tagged **UNVERIFIED** and also goes in an Unknowns list.
- Add **Gaps**: values that are produced but have nowhere to land, or are needed downstream but produced nowhere.
- Add **Contradictions**: places where two repos disagree (field names, types, ownership).

Done when: every field from step 1 appears in the table, gaps or unknowns.

## 4. Critic pass

Launch one fresh `general-purpose` agent with the table, the repo paths and none of your reasoning. Brief: "Try to disprove every row. Push hardest on source-of-truth claims, on 'has no home' or 'is never sent' claims, and on anything that relies on main while an open PR changes it. For each row, report confirmed, refuted (with evidence) or weak."

Fix refuted rows. Downgrade weak rows to UNVERIFIED. Re-run the critic only if a fix changes a source-of-truth or gap conclusion.

Done when: no row is refuted.

## 5. Deliver

- Answer the question from the table, citing the evidence inline. Don't state anything the table doesn't support.
- If the user wants a document or artifact, build it from the table (the global writing-style rules apply) and keep the Evidence column or footnotes.
- End with the three claims you are least confident about, and why.
