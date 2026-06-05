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

- **Create** — draft a new requirement issue.
- **Amend** — apply a delta to an existing requirement issue.

## Resolve Target

- **Create**: ask via `AskUserQuestion` for `$DESCRIPTION` — free-text requirement description.
- **Amend**:
  1. List open milestones titled `Sprint N`; pick the one with the highest N → `$SPRINT_N`, `$MILESTONE_ID`. Halt if none: `⛔ No open sprint milestone — run /feature:requirement:create first.`
  2. Find the issue in `$MILESTONE_ID` labelled `requirement` → `$ISSUE_NUMBER`. Halt if absent: `⛔ Sprint $SPRINT_N has no requirement issue.`
  3. Ask via `AskUserQuestion` for `$DELTA` — free-text describing the change to apply to `#$ISSUE_NUMBER`.

## Resume Check

Look up resume state (`workflow = feature`, `run_key = requirement-<$MODE>-<$ISSUE_NUMBER|new>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from the first step of the mode file.
- **Cancel** — abort; leave state untouched.

## Dispatch

Read `feature/requirement/<$MODE>.md` and follow it from its first step. Inputs (`$DESCRIPTION` for Create, `$ISSUE_NUMBER` + `$DELTA` for Amend) are already in scope.
