---
name: bugfix:pre-release
description: Pre-release gate for a bug fix — readiness check, migration detection (production only), post bug summary.
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

Look up resume state (`workflow = bugfix`, `run_key = pre-release-<bug_issue_number>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Parse Arguments**.
- **Cancel** — abort; leave state untouched.

## Parse Arguments

Parse `$ARGUMENTS` as the bug issue number (e.g. `42`).

If `$ARGUMENTS` is empty: list all open issues labeled `bug` whose board Status is `Implemented`, show the results for the user to choose from, then stop.

## Fetch Issue

Via the `github` skill, read issue `#issue_number` — title, labels, state.

- If missing the `bug` label, stop:
  ```
  ⛔ Issue #N is not a bug (labels: <labels>). Use /bugfix:pre-release only for bug issues.
  ```
- If already closed, stop:
  ```
  ℹ Issue #N is already closed.
  ```

Derive `$BUG_SOURCE` from the title prefix (match `[Dev Bug]` before `[Bug]`):

- Title starts with `[Dev Bug]` → `$BUG_SOURCE = development`
- Else title starts with `[Bug]` → `$BUG_SOURCE = production`

## Readiness Gate

For each codebase repo, list bugfix PRs for issue N. If no PRs found, stop:

```
⛔ No bugfix PRs found for #N. Run /bugfix:implement {N} first.
```

Verify all PRs are open (not yet merged). List them:

```
Bugfix PRs for #N:
  - <pr_title> (<pr_url>)
```

Proceed.

## Build & Test Gate

For each codebase repo with an open bugfix PR for issue N, check out the PR branch:

- Discover the build and test commands from the codebase root (CLAUDE.md, solution file, Makefile, or `package.json`).
- Run the full build.
- Run the full test suite.

If any codebase fails to build or has failing tests, halt:

```
⛔ Bug #N not ready to close. Build/test failures:
  - <codebase>: <build|tests> failed
    <first failing line>

Fix on the bugfix branch, then run /bugfix:pre-release {N} again.
```

Proceed only when every codebase with changes builds clean and all tests pass.

## Check for Migrations (Backend Only)

**Production only.** For the backend codebase, find the open bugfix PR for issue N and scan its changed files against the migration detection rule from the `project-config` skill.

- No backend PR found → "No backend PR found for #N — skipping migration check."
- Migration files found → surface warning.
- No migration files → "No database migrations in this bug fix."

**Development:** skip entirely. The sprint pre-release handles migration detection.

## Post Bug Summary

Render the `comment-bug-summary` template via the `github-templates` skill with `{issue_number, title, closed_date, migrations}`. Via the `github` skill, post as a comment on `#issue_number`.

For development bugs, `migrations` is always "None".

## Next Step

Bug readiness gate passed. Print the next command:

- `/bugfix:release <bug_issue>` — merge and close the bug
