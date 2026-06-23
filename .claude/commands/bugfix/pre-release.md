---
name: bugfix:pre-release
description: Pre-release gate for a production bug fix — readiness check, migration detection, post bug summary.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Bugfix Pre-release

`$ARGUMENTS` carries `bug_issue_number`.

## Workflow
1. Resume Check
2. Parse Arguments
3. Fetch Issue
4. Readiness Gate
5. Build & Test Gate
6. Check for Migrations (Backend Only)
7. Post Bug Summary
8. Next Step

## Resume Check

Look up resume state (`workflow = bugfix`, `run_key = pre-release-<bug_issue_number>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Parse Arguments**.
- **Cancel** → abort; leave state untouched.

## Parse Arguments

Parse `$ARGUMENTS` as the bug issue number (e.g. `42`).

Empty → list all open `bug` issues with board Status `Implemented` → show for the user to choose → stop.

## Fetch Issue

Via `github` skill, read issue `#issue_number` — title, labels, state.

- Missing `bug` label → stop `⛔ Issue #N is not a bug (labels: <labels>). Use /bugfix:pre-release only for bug issues.`
- Already closed → stop `ℹ Issue #N is already closed.`

## Readiness Gate

Per codebase repo → list bugfix PRs for issue N. None → stop:

```
⛔ No bugfix PRs found for #N. Run /bugfix:implement {N} first.
```

Verify all PRs open (not merged). List them:

```
Bugfix PRs for #N:
  - <pr_title> (<pr_url>)
```

Proceed.

## Build & Test Gate

Per codebase repo with an open bugfix PR for issue N → check out the PR branch:

- Discover build + test commands from codebase root (CLAUDE.md, solution file, Makefile, or `package.json`).
- Run the full build.
- Run the full test suite.

Any codebase fails build or has failing tests → halt:

```
⛔ Bug #N not ready to close. Build/test failures:
  - <codebase>: <build|tests> failed
    <first failing line>

Fix on the bugfix branch, then run /bugfix:pre-release {N} again.
```

Proceed only when every codebase with changes builds clean + all tests pass.

## Check for Migrations (Backend Only)

For the backend codebase → find the open bugfix PR for issue N → scan its changed files against the migration detection rule from `project-config` skill (presence check).

- No backend PR → "No backend PR found for #N — skipping migration check."
- Migration files found → read cutover + rollback SQL from the **Dev Investigation comment's Migration Plan** on `#issue_number` → surface warning with the scripts.
- No migration files → "No database migrations in this bug fix."

## Post Bug Summary

Render `comment-bug-summary` template (via `github-templates` skill) with `{issue_number, title, closed_date, migrations}` → post as a comment on `#issue_number` via `github` skill.

## Next Step

Bug readiness gate passed. Next:

- `/bugfix release and close the bug`