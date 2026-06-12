---
name: refactor:release
description: Close a standalone refactor — merge refactor PRs into main, mark Done on the board, close the issue.
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

Look up resume state (`workflow = refactor`, `run_key = release-<refactor_issue>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Parse Arguments**.
- **Cancel** → abort; leave state untouched.

## Parse Arguments

Parse `$ARGUMENTS` as the refactor issue number (e.g. `42`).

Empty → list all open `refactoring` issues → show for the user to choose → stop.

## Fetch Issue

Via `github` skill, read issue `#issue_number` — title, labels, state.

- Missing `refactoring` label → stop `⛔ Issue #N is not a refactoring task (labels: <labels>). Use /refactor:release only for refactoring issues.`
- Already closed → stop `ℹ Issue #N is already closed.`

## Merge Refactor PRs

Via `git` skill, per codebase repo → find open refactor PRs for issue N → squash-merge each (**Merge PR**). Output:

```
✓ Merged <pr_title> in {codebase_name}
```

## Mark Done and Close

Via `github` skill:

1. Set board Status `Done`.
2. Close issue `#issue_number`.

Output:

```
✓ Closed #N — <title>
```

## Next Step

Refactor closed — refactor lifecycle complete. Next:

- start another workflow with `/feature`, `/bugfix`, or `/refactor`
