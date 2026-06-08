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

Look up resume state (`workflow = refactor`, `run_key = pre-release-<refactor_issue>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Parse Arguments**.
- **Cancel** — abort; leave state untouched.

## Parse Arguments

Parse `$ARGUMENTS` as the refactor issue number (e.g. `42`).

If `$ARGUMENTS` is empty: list all open issues labeled `refactoring` whose board Status is `Implemented`, show the results for the user to choose from, then stop.

## Fetch Issue

Via the `github` skill, read issue `#issue_number` — title, labels, state.

- If missing `refactoring` label, stop:
  ```
  ⛔ Issue #N is not a refactoring task (labels: <labels>). Use /refactor:pre-release only for refactoring issues.
  ```
- If already closed, stop:
  ```
  ℹ Issue #N is already closed.
  ```

## Readiness Gate

For each codebase repo, list refactor PRs for issue N. If no PRs found, stop:

```
⛔ No refactor PRs found for #N. Run /refactor:implement {N} first.
```

Verify all PRs are open (not yet merged). List them:

```
Refactor PRs for #N:
  - <pr_title> (<pr_url>)
```

Proceed.

## Build & Test Gate

For each codebase repo with an open refactor PR for issue N, check out the PR branch:

- Discover the build and test commands from the codebase root (CLAUDE.md, solution file, Makefile, or `package.json`).
- Run the full build.
- Run the full test suite.

If any codebase fails to build or has failing tests, halt:

```
⛔ Refactor #N not ready to close. Build/test failures:
  - <codebase>: <build|tests> failed
    <first failing line>

Fix on the refactor branch, then run /refactor:pre-release {N} again.
```

Proceed only when every codebase with changes builds clean and all tests pass.

## Check for Migrations (Backend Only)

For the backend codebase, find the open refactor PR for issue N and scan its changed files against the migration detection rule from the `project-config` skill.

- No backend PR found → "No backend PR found for #N — skipping migration check."
- Migration files found → surface warning.
- No migration files → "No database migrations in this refactor."

## Post Summary

Render the `comment-refactor-summary` template via the `github-templates` skill with `{issue_number, title, date, migrations}`. Via the `github` skill, post as a comment on `#issue_number`. `migrations` carries the Check for Migrations result, or `None`.

## Next Step

Refactor readiness gate passed. Print the next command:

- `/refactor:release <refactor_issue>` — merge and close the refactor
