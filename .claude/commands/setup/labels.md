---
name: setup:labels
description: Create GitHub labels from the project label set.
tools: Bash
---

# Setup — Labels

## Workflow
1. Create Labels
2. Confirm
3. Next Step

## Create Labels

Via the `github` skill, create the project labels — run:

```bash
bash .claude/scripts/create-github-labels.sh
```

If the script fails, report the error and halt.

## Confirm

Output: `GitHub labels created (or updated).`

## Next Step

Labels created. Print the next command:

- `/setup:board` — provision the GitHub Project board
