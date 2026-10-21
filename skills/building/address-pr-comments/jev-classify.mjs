#!/usr/bin/env node
// Pre-screens unaddressed review threads with TypeSafe's Jev model.
//
// stdin:  {"pr": {"number", "title"}, "threads": [{"id", "path"?, "line"?, "diffHunk"?,
//          "comments": [{"author", "body"}]}]}
// stdout: [{"id", "route", "choice", "probabilities", "confidence"} | {"id", "error"}]
//
// "route" is "mechanical" only when Jev picks mechanical with at least
// MECHANICAL_MIN probability; everything else routes to "judgment".
// Exits 2 when TYPESAFE_API_KEY is unset, so callers fall back to their own gate.

const MECHANICAL_MIN = 0.9;
const TIMEOUT_MS = 10_000;
const API_URL = process.env.TYPESAFE_API_URL ?? "https://api.typesafe.ai/v1/systemone";

const QUESTION = {
  type: "choice",
  instructions: {
    task: "Decide how the pull request author's agent should handle this unaddressed review thread. The agent may change code on its own only when the thread asks for a clear, self-contained change it can make and verify without further input.",
    evidence: "Read `thread.comments` in order; the last comment is the one awaiting a response. `thread.diff_hunk`, when present, is the code the thread is anchored to.",
    tie_break: "When unsure whether the wanted change is clear, prefer an option that leaves the code untouched.",
  },
  criteria: {
    mechanical: {
      what: "Asks for a clear, self-contained change that can be made and verified without further input: a rename, an extraction, a fix for a bug the reviewer pinpointed, applying a suggested edit, adding a test, adjusting types. Size or number of files touched does not matter.",
      not_for: "Requests where the wanted change is unclear, or that challenge the approach itself.",
    },
    ambiguous: {
      what: "Seems to want a change, but exactly what change is wanted cannot be told with confidence.",
    },
    design_disagreement: {
      what: "Challenges the approach or architecture, or wants a redesign that is not a mechanical edit.",
    },
    product_decision: {
      what: "Needs a product, domain or compliance decision the author's agent cannot make.",
    },
    reply_only: {
      what: "Asks a question, makes a remark or acknowledges something, without requesting a code change.",
      examples: ["Why did you pick this approach?", "Nice, thanks!"],
    },
  },
};

async function classify(apiKey, pr, thread) {
  const state = {
    pull_request: { number: pr.number, title: pr.title },
    thread: {
      path: thread.path ?? null,
      line: thread.line ?? null,
      diff_hunk: thread.diffHunk ?? null,
      comments: thread.comments.map(({ author, body }) => ({ author, body })),
    },
  };
  const request = {
    method: "POST",
    headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
    body: JSON.stringify({ model: "jev-latest", state, questions: { handling: QUESTION } }),
  };

  for (let attempt = 0; ; attempt++) {
    const response = await fetch(API_URL, { ...request, signal: AbortSignal.timeout(TIMEOUT_MS) });
    if ((response.status === 429 || response.status === 529) && attempt < 2) {
      await new Promise((resolve) => setTimeout(resolve, 500 * 2 ** attempt));
      continue;
    }
    if (!response.ok) throw new Error(`HTTP ${response.status}: ${(await response.text()).slice(0, 200)}`);

    const { choice, probabilities, confidence } = (await response.json()).answers.handling;
    const route = choice === "mechanical" && probabilities.mechanical >= MECHANICAL_MIN ? "mechanical" : "judgment";
    return { id: thread.id, route, choice, probabilities, confidence };
  }
}

const apiKey = process.env.TYPESAFE_API_KEY;
if (!apiKey) {
  console.error("TYPESAFE_API_KEY is not set");
  process.exit(2);
}

const chunks = [];
for await (const chunk of process.stdin) chunks.push(chunk);
const { pr, threads } = JSON.parse(Buffer.concat(chunks).toString());

const results = await Promise.all(
  threads.map((thread) => classify(apiKey, pr, thread).catch((error) => ({ id: thread.id, error: error.message }))),
);
console.log(JSON.stringify(results, null, 2));
