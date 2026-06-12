---
name: feature:design
description: Per-surface design navigator — pick mode (create / regenerate), infer the active sprint, run resume check, then dispatch to the mode file.
tools: Read, AskUserQuestion, Bash
---

# Feature Design — Navigator

## Workflow
1. Pick Mode
2. Resolve Target
3. Resume Check
4. Dispatch

## Pick Mode

Ask via `AskUserQuestion` → `$MODE`:

- **Create** — author per-surface design for the sprint.
- **Regenerate** — regenerate per-surface design from changed story ACs or user input.

## Resolve Target

Via `github` skill:
1. Resolve active sprint → `$SPRINT_N`. None → halt `⛔ No sprint on the board — run /feature:requirement:create first.`
2. List sprint items → item labelled `requirement` → `$ISSUE_NUMBER`. Absent → halt `⛔ Sprint $SPRINT_N has no requirement issue.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = design-<$MODE>-<$SPRINT_N>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from mode file's first step.
- **Cancel** → abort; leave state untouched.

## Dispatch

Read `feature/design/<$MODE>.md` → follow from first step. `$SPRINT_N` + `$ISSUE_NUMBER` (requirement) in scope.
