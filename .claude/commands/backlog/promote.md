---
name: backlog:promote
description: Promote a backlog draft into a real issue — route by type into the matching authoring flow, then remove the draft.
tools: Read, Bash, AskUserQuestion
---

# Backlog — Promote

## Workflow
1. Select Draft
2. Route by Type
3. Remove Draft
4. Next Step

## Select Draft

Via `github` skill, run **List Backlog Drafts**. Empty → halt `Backlog is empty — nothing to promote.`

Ask via `AskUserQuestion` "Which item do you want to promote?" — present the drafts grouped by type. Hold `$ITEM_ID`, `$TITLE`, `$NOTES`, `$TYPE`.

Selected draft has no Type → halt `⛔ Draft has no Type — set it on the board or re-add via /backlog:add.`

Write resume state (`workflow = backlog`, `run_key = promote-<$ITEM_ID>`) with the selected draft held as a decision.

## Route by Type

Dispatch the draft text into its authoring flow — these flows own templates, quality gates, and approval; do not bypass them:

| `$TYPE` | Flow | Input |
|---------|------|-------|
| Feature | Read `feature/requirement/create.md`, follow from first step | `$DESCRIPTION = "$TITLE\n\n$NOTES"` |
| Refactor | Read `refactor/spec/create.md`, follow from first step | Seed the Discovery Dialog with `$TITLE` + `$NOTES` |
| Bug | Read `bugfix/report.md`, follow from first step | `$ARGUMENTS = "$TITLE\n\n$NOTES"` |

The flow files the real issue (and registers it on the board, Status `Todo`). Hold the resulting issue number → `$ISSUE_NUMBER`. Checkpoint the artifact.

Flow cancelled at its approval gate → leave the draft untouched → clear resume state → stop.

## Remove Draft

The draft is now redundant — the issue-backed board item replaces it. Via `github` skill, run **Delete Board Item** on `$ITEM_ID`.

Clear resume state. Output: `Promoted [<Type>] <Title> → issue #$ISSUE_NUMBER.`

## Next Step

Print the typed flow's natural next step:

- Feature → `/feature break requirement $ISSUE_NUMBER into stories`
- Refactor → `/refactor implement refactor $ISSUE_NUMBER`
- Bug → `/bugfix add acceptance criteria to bug $ISSUE_NUMBER`

Plus: `/backlog show the backlog` — review remaining items.
