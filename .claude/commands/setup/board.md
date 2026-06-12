---
name: setup:board
description: Provision the GitHub Project board — labels plus the Status / Type / Sprint fields — the workflow's tracking surface.
tools: Bash
---

# Setup — Board

## Workflow
1. Create Labels
2. Create Board
3. Confirm
4. Next Step

## Create Labels

Via `github` skill, create the project labels:

```bash
bash .claude/scripts/create-github-labels.sh
```

Script fails → report the error → halt.

## Create Board

Via `github` skill, provision the project board:

```bash
bash .claude/scripts/setup-github-project.sh
```

Idempotent — safe to re-run; existing project + fields reused. No config persisted; workflows resolve the board at runtime by title.

Fails on missing `project` token scope → surface its instruction (`gh auth refresh -s project --hostname github.com`) → halt. Any other failure → report → halt.

## Confirm

Output: `GitHub labels created (or updated). Project board created (or updated): Status, Type, and Sprint fields ready.`

## Next Step

Board ready. Next:

- `/setup generate PRODUCT.md`