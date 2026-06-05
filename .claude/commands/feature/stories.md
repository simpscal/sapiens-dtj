---
name: feature:stories
description: User-story authoring navigator — pick mode (create / regenerate), infer the active sprint, run resume check, then dispatch to the mode file.
tools: Read, AskUserQuestion, Bash
---

# Feature Stories — Navigator

## Workflow
1. Pick Mode
2. Resolve Target
3. Resume Check
4. Dispatch

## Pick Mode

Ask via `AskUserQuestion` → `$MODE`:

- **Create** — decompose a requirement into stories under a new sprint.
- **Regenerate** — reconcile sprint stories against a scope delta (requirement change or user input).

## Resolve Target

List open milestones titled `Sprint N`; pick the one with the highest N → `$SPRINT_N`, `$MILESTONE_ID`. Halt if none: `⛔ No open sprint milestone — run /feature:requirement:create first.` Find the issue in `$MILESTONE_ID` labelled `requirement` → `$ISSUE_NUMBER`. Halt if absent: `⛔ Sprint $SPRINT_N has no requirement issue.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = stories-<$MODE>-<$ISSUE_NUMBER>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from the first step of the mode file.
- **Cancel** — abort; leave state untouched.

## Dispatch

Read `feature/stories/<$MODE>.md` and follow it from its first step. `$ISSUE_NUMBER` is already in scope.

## Constraints

- Never produce tracker output until the user confirms the picture is correct.
