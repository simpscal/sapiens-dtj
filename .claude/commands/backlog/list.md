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

Via `github` skill, run **List Backlog Drafts**. Missing-board or missing-scope error → surface the skill's message → stop.

## Render

Empty → output `Backlog is empty.` → stop.

Else render grouped by Type (Feature / Refactor / Bug — omit empty groups):

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

- `/backlog:add` — capture another item
- `/backlog:promote` — promote an item into the workflow