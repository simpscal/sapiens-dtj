---
name: refactor:release
description: Close a refactor task — merge refactor PRs, remove lifecycle labels, close the issue.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Refactor Release

`$ARGUMENTS` carries `refactor_issue`.

## Workflow
1. Resume Check
2. Parse Arguments
3. Fetch Issue
4. Merge Refactor PRs
5. Update Labels and Close
6. Next Step

## Resume Check

Look up resume state (`workflow = refactor`, `run_key = release-<refactor_issue>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Parse Arguments**.
- **Cancel** — abort; leave state untouched.

## Parse Arguments

Parse `$ARGUMENTS` as the refactor issue number (e.g. `42`).

If `$ARGUMENTS` is empty: list all open issues labeled `refactoring`, show the results for the user to choose from, then stop.

## Fetch Issue

Via the `github` skill, read issue `#issue_number` — title, labels, state.

- If missing `refactoring` label, stop:
  ```
  ⛔ Issue #N is not a refactoring task (labels: <labels>). Use /refactor:release only for refactoring issues.
  ```
- If already closed, stop:
  ```
  ℹ Issue #N is already closed.
  ```

## Merge Refactor PRs

Via the `git` skill, for each codebase repo find open refactor PRs for issue N and squash-merge each (**Merge PR** operation). Output:

```
✓ Merged <pr_title> in {codebase_name}
```

## Update Labels and Close

Via the `github` skill:

1. Remove `in-progress` and `implemented`.
2. Close issue `#issue_number`.

Output:

```
✓ Closed #N — <title>
```

## Next Step

Refactor closed — refactor lifecycle complete. Print:

- `/help-flows` — pick another workflow
