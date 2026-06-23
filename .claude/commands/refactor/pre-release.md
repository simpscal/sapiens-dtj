---
name: refactor:pre-release
description: Pre-release gate for a refactor task — readiness check, migration detection, post summary.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Refactor Pre-release

`$ARGUMENTS` carries `refactor_issue`.

## Workflow
1. Resume Check
2. Parse Arguments
3. Fetch Issue
4. Readiness Gate
5. Build & Test Gate
6. Check for Migrations (Backend Only)
7. Post Summary
8. Next Step

## Resume Check

Look up resume state (`workflow = refactor`, `run_key = pre-release-<refactor_issue>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Parse Arguments**.
- **Cancel** → abort; leave state untouched.

## Parse Arguments

Parse `$ARGUMENTS` as the refactor issue number (e.g. `42`).

Empty → list all open `refactoring` issues with board Status `Implemented` → show for the user to choose → stop.

## Fetch Issue

Via `github` skill, read issue `#issue_number` — title, labels, state.

- Missing `refactoring` label → stop `⛔ Issue #N is not a refactoring task (labels: <labels>). Use /refactor:pre-release only for refactoring issues.`
- Already closed → stop `ℹ Issue #N is already closed.`

## Readiness Gate

Per codebase repo → list refactor PRs for issue N. None → stop:

```
⛔ No refactor PRs found for #N. Run /refactor:implement {N} first.
```

Verify all PRs open (not merged). List them:

```
Refactor PRs for #N:
  - <pr_title> (<pr_url>)
```

Proceed.

## Build & Test Gate

Per codebase repo with an open refactor PR for issue N → check out the PR branch:

- Discover build + test commands from codebase root (CLAUDE.md, solution file, Makefile, or `package.json`).
- Run the full build.
- Run the full test suite.

Any codebase fails build or has failing tests → halt:

```
⛔ Refactor #N not ready to close. Build/test failures:
  - <codebase>: <build|tests> failed
    <first failing line>

Fix on the refactor branch, then run /refactor:pre-release {N} again.
```

Proceed only when every codebase with changes builds clean + all tests pass.

## Check for Migrations (Backend Only)

For the backend codebase → find the open refactor PR for issue N → scan its changed files against the migration detection rule from `project-config` skill (presence check).

- No backend PR → "No backend PR found for #N — skipping migration check."
- Migration files found → read cutover + rollback SQL from the **refactor spec issue's Migration Plan** → surface warning with the scripts.
- No migration files → "No database migrations in this refactor."

## Post Summary

Render `comment-refactor-summary` template (via `github-templates` skill) with `{issue_number, title, date, migrations}` → post as a comment on `#issue_number` via `github` skill. `migrations` carries the Check for Migrations result, or `None`.

## Next Step

Refactor readiness gate passed. Next:

- `/refactor release and close the refactor`