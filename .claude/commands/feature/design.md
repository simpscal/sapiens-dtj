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
- **Regenerate** — regenerate per-surface design sourced from changed story ACs or from the user's input.

## Resolve Target

Via the `github` skill, resolve the active sprint → `$SPRINT_N`. Halt if none: `⛔ No sprint on the board — run /feature:requirement:create first.`

List sprint items; find the item labelled `requirement` → `$ISSUE_NUMBER`. Halt if absent: `⛔ Sprint $SPRINT_N has no requirement issue.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = design-<$MODE>-<$SPRINT_N>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from the first step of the mode file.
- **Cancel** — abort; leave state untouched.

## Dispatch

Read `feature/design/<$MODE>.md` and follow it from its first step. `$SPRINT_N` and `$ISSUE_NUMBER` (the requirement) are already in scope.
