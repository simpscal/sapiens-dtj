---
name: backlog:list
description: List backlog drafts on the project board, grouped by type.
tools: Bash
---

# Backlog — List

## Workflow
1. Fetch Drafts
2. Render
3. Next Step

## Fetch Drafts

Via the `github` skill, run **List Backlog Drafts**. On a missing-board or missing-scope error, surface the skill's message and stop.

## Render

If empty: output `Backlog is empty.` and stop.

Otherwise render grouped by Type (Feature / Refactor / Bug — omit empty groups):

```
🗂 Backlog

Feature
- <title> — <first line of body, if any>  (<item-id>)

Refactor
- ...

Bug
- ...
```

## Next Step

- `/backlog:add <text>` — capture another item
- `/backlog:promote` — promote an item into the workflow
