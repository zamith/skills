---
name: afk-loop
description: Use when the user wants to run the autonomous RALPH issue loop in a sandbox, processing pending issues with the project prompt template.
---

# AFK Loop

Run the RALPH autonomous issue loop in a Docker sandbox.

## Usage

Execute this command:

```
/ralph-loop:ralph-loop "$(cat plans/prompt.md)" --max-iterations 2
```

This reads the prompt template from `plans/prompt.md` and runs it against pending issues, limited to 2 iterations.
