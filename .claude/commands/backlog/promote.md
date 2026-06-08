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

Via the `github` skill, run **List Backlog Drafts**. If empty, halt: `Backlog is empty — nothing to promote.`

Ask via `AskUserQuestion`: "Which item do you want to promote?" Present the drafts grouped by type. Hold `$ITEM_ID`, `$TITLE`, `$NOTES`, `$TYPE`.

Guard: if the selected draft has no Type, halt: `⛔ Draft has no Type — set it on the board or re-add via /backlog:add.`

Write resume state (`workflow = backlog`, `run_key = promote-<$ITEM_ID>`) with the selected draft held as a decision.

## Route by Type

Dispatch the draft text into its authoring flow — these flows own templates, quality gates, and approval; do not bypass them:

| `$TYPE` | Flow | Input |
|---------|------|-------|
| Feature | Read `feature/requirement/create.md`, follow from its first step | `$DESCRIPTION = "$TITLE\n\n$NOTES"` |
| Refactor | Read `refactor/spec/create.md`, follow from its first step | Seed the Discovery Dialog with `$TITLE` and `$NOTES` |
| Bug | Read `bugfix/report.md`, follow from its first step | `$ARGUMENTS = "$TITLE\n\n$NOTES"` |

The flow files the real issue (and registers it on the board with Status `Todo`). Hold the resulting issue number as `$ISSUE_NUMBER`. Checkpoint the artifact.

If the flow is cancelled at its approval gate, leave the draft untouched, clear resume state, and stop.

## Remove Draft

The draft is now redundant — the issue-backed board item replaces it. Via the `github` skill, run **Delete Board Item** on `$ITEM_ID`.

Clear resume state. Output: `Promoted [<Type>] <Title> → issue #$ISSUE_NUMBER.`

## Next Step

Print the typed flow's natural next command:

- Feature → `/feature:stories:create $ISSUE_NUMBER`
- Refactor → `/refactor:implement $ISSUE_NUMBER`
- Bug → `/bugfix:story $ISSUE_NUMBER`

Plus: `/backlog:list` — review remaining items.
