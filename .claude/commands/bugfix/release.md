---
name: bugfix:release
description: Close a bug (production or development) — merge bugfix PRs, label `bug-fixed`, close the issue.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Bugfix Release

`$ARGUMENTS` carries `bug_issue_number`.

## Workflow
1. Resume Check
2. Parse Arguments
3. Fetch Issue
4. Merge Bugfix PRs
5. Update Labels and Close
6. Next Step

## Resume Check

Look up resume state (`workflow = bugfix`, `run_key = release-<bug_issue_number>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Parse Arguments**.
- **Cancel** — abort; leave state untouched.

## Parse Arguments

Parse `$ARGUMENTS` as the bug issue number (e.g. `42`).

If `$ARGUMENTS` is empty: list all open issues labeled `bug`, show the results for the user to choose from, then stop.

## Fetch Issue

Via the `github` skill, read issue `#issue_number` — title, labels, state, milestone.

- If missing the `bug` label, stop:
  ```
  ⛔ Issue #N is not a bug (labels: <labels>). Use /bugfix:release only for bug issues.
  ```
- If already closed, stop:
  ```
  ℹ Issue #N is already closed.
  ```

## Merge Bugfix PRs

Via the `git` skill, for each codebase repo find open bugfix PRs for issue N and squash-merge each (**Merge PR** operation). Output:

```
✓ Merged <pr_title> in {codebase_name}
```

## Update Labels and Close

Via the `github` skill:

1. Add label `bug-fixed`; remove `in-progress` and `implemented`.
2. Close issue `#issue_number`.

Output:

```
✓ Closed #N — <title>
```

## Next Step

Bug closed — bugfix lifecycle complete. Print:

- `/help-flows` — pick another workflow
