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
- **Regenerate** — regenerate the TDD from changed story ACs or user input.

## Infer Active Sprint

Via `github` skill, resolve active sprint → `$SPRINT_N`. None → halt `⛔ No sprint on the board — run /feature:requirement:create first.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = technical-design-<$MODE>-<$SPRINT_N>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from mode file's first step.
- **Cancel** → abort; leave state untouched.

## Dispatch

Read `feature/technical-design/<$MODE>.md` → follow from first step. `$SPRINT_N` in scope.
