---
name: setup:board
description: Provision the GitHub Project board — Status / Type / Sprint fields — the workflow's tracking surface.
tools: Bash
---

# Setup — Board

## Workflow
1. Create Board
2. Confirm
3. Next Step

## Create Board

Via the `github` skill, provision the project board — run:

```bash
bash .claude/scripts/setup-github-project.sh
```

Idempotent — safe to re-run; existing project and fields are reused. No configuration is persisted; workflows resolve the board at runtime by title.

If the script fails on a missing `project` token scope, surface its instruction (`gh auth refresh -s project --hostname github.com`) and halt. For any other failure, report the error and halt.

## Confirm

Output: `Project board created (or updated): Status, Type, and Sprint fields ready.`

## Next Step

Board ready. Print the next command:

- `/setup:product` — generate PRODUCT.md
