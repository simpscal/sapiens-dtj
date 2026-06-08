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
- **Notes** — any remaining detail (optional).

Ask via `AskUserQuestion` for whatever is missing — title and type only; never ask for notes. This is quick capture: no alignment checks, no AC drafting, no approval loop.

## Create Draft

Via the `github` skill, run **Create Backlog Draft** with `{title, body: notes, type}`. Hold the returned item ID as `$ITEM_ID`. On a missing-board or missing-scope error, surface the skill's message and stop.

Output: `Captured to backlog: [<Type>] <Title>`

## Next Step

- `/backlog:list` — review the backlog
- `/backlog:promote` — promote an item into the workflow
