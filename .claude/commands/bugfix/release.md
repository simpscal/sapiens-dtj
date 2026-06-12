---
name: bugfix:release
description: Close a production bug — merge bugfix PRs into main, mark Done on the board, close the issue.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Bugfix Release

`$ARGUMENTS` carries `bug_issue_number`.

## Workflow
1. Resume Check
2. Parse Arguments
3. Fetch Issue
4. Merge Bugfix PRs
5. Mark Done and Close
6. Next Step

## Resume Check

Look up resume state (`workflow = bugfix`, `run_key = release-<bug_issue_number>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Parse Arguments**.
- **Cancel** → abort; leave state untouched.

## Parse Arguments

Parse `$ARGUMENTS` as the bug issue number (e.g. `42`).

Empty → list all open `bug` issues → show for the user to choose → stop.

## Fetch Issue

Via `github` skill, read issue `#issue_number` — title, labels, state.

- Missing `bug` label → stop `⛔ Issue #N is not a bug (labels: <labels>). Use /bugfix:release only for bug issues.`
- Already closed → stop `ℹ Issue #N is already closed.`

## Merge Bugfix PRs

Via `git` skill, per codebase repo → find open bugfix PRs for issue N → squash-merge each (**Merge PR**). Output:

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

Bug closed — bugfix lifecycle complete. Next:

- start another workflow with `/feature`, `/bugfix`, or `/refactor`
