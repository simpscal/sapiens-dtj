---
name: feature:requirement
description: Requirement issue navigator — pick mode (create / amend), gather inputs, run resume check, then dispatch to the mode file.
tools: Read, AskUserQuestion, Bash
---

# Feature Requirement — Navigator

## Workflow
1. Pick Mode
2. Resolve Target
3. Resume Check
4. Dispatch

## Pick Mode

Ask via `AskUserQuestion` → `$MODE`:

- **Create** — draft new requirement issue.
- **Amend** — apply delta to existing requirement issue.

## Resolve Target

- **Create**: ask via `AskUserQuestion` → `$DESCRIPTION` (free-text requirement description).
- **Amend**, via `github` skill:
  1. Resolve active sprint → `$SPRINT_N`. None → halt `⛔ No sprint on the board — run /feature:requirement:create first.`
  2. List sprint items → item labelled `requirement` → `$ISSUE_NUMBER`. Absent → halt `⛔ Sprint $SPRINT_N has no requirement issue.`
  3. Ask via `AskUserQuestion` → `$DELTA` (change to apply to `#$ISSUE_NUMBER`).

## Resume Check

Look up resume state (`workflow = feature`, `run_key = requirement-<$MODE>-<$ISSUE_NUMBER|new>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from mode file's first step.
- **Cancel** → abort; leave state untouched.

## Dispatch

Read `feature/requirement/<$MODE>.md` → follow from first step. In scope: `$DESCRIPTION` (Create), `$ISSUE_NUMBER` + `$DELTA` (Amend).
