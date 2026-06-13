---
name: backlog:add
description: Quick-capture a backlog item as a board draft — title, type, optional notes. Seconds, not minutes.
tools: Bash, AskUserQuestion
---

# Backlog — Add

Navigator supplies `$CAPTURE_TEXT` (optional free text).

## Workflow
1. Gather Fields
2. Create Draft
3. Next Step

## Gather Fields

Parse `$CAPTURE_TEXT` for:

- **Title** — one line, what the item is.
- **Type** — Feature / Refactor / Bug (infer only when unambiguous, e.g. "bug:", "fix crash", "refactor").
- **Notes** — remaining detail (optional).

Ask via `AskUserQuestion` for whatever's missing — title + type only; never ask for notes. Quick capture: no alignment checks, no AC drafting, no approval loop.

## Create Draft

Via `github` skill, run **Create Backlog Draft** with `{title, body: notes, type}` → hold returned item ID → `$ITEM_ID`. Missing-board or missing-scope error → surface the skill's message → stop.

Output: `Captured to backlog: [<Type>] <Title>`

## Next Step

- `/backlog show the backlog` — review the backlog
- `/backlog promote an item` — promote an item into the workflow