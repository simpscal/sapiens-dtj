---
name: feature:technical-design
description: Technical Design navigator — pick mode (create / regenerate), infer the active sprint, run resume check, then dispatch to the mode file.
tools: Read, AskUserQuestion, Bash
---

# Feature Technical Design — Navigator

## Workflow
1. Pick Mode
2. Infer Active Sprint
3. Resume Check
4. Dispatch

## Pick Mode

Ask via `AskUserQuestion` → `$MODE`:

- **Create** — author a new TDD for the sprint.
- **Regenerate** — regenerate the TDD sourced from changed story ACs or from the user's input.

## Infer Active Sprint

Via the `github` skill, resolve the active sprint → `$SPRINT_N`. Halt if none: `⛔ No sprint on the board — run /feature:requirement:create first.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = technical-design-<$MODE>-<$SPRINT_N>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from the first step of the mode file.
- **Cancel** — abort; leave state untouched.

## Dispatch

Read `feature/technical-design/<$MODE>.md` and follow it from its first step. `$SPRINT_N` is already in scope.
