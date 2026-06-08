---
name: feature:pre-release
description: Pre-release gate for a feature sprint — readiness check, migration detection, create release PRs (sprint → main), post sprint summary.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Feature Pre-release

## Workflow
1. Infer Active Sprint
2. Resume Check
3. Fetch Sprint Snapshot
4. Readiness Gate
5. Build & Test Gate
6. Check for Migrations (Backend Only)
7. Create Release PRs (Sprint Branch → Main)
8. Post Sprint Summary
9. Next Step

## Infer Active Sprint

Via the `github` skill, resolve the active sprint → `$SPRINT_N`. Halt if none: `⛔ No sprint on the board to check.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = pre-release-<$SPRINT_N>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Infer Active Sprint**.
- **Cancel** — abort; leave state untouched.

## Fetch Sprint Snapshot

Via the `github` skill, list **open** sprint items only. For each, note number, title, labels, status, state.

Partition into four groups:

- **Stories**: issues with `user-story` label (both `[Story]` and `[Tech]`).
- **TDD**: issue whose title contains `Technical Design Document`.
- **Design**: issue with `design` label.
- **Requirement**: issue with `requirement` label.

Guard: a feature sprint must carry a Requirement. If `$REQUIREMENT` is absent, halt: `⛔ Sprint $SPRINT_N has no requirement issue — this command targets feature sprints.`

Derive sprint branch name for sprint N.

## Readiness Gate

For each story still **open** (`[Story]` or `[Tech]`):

- Check its board Status for `In Progress`.
- For each codebase repo (derive slug: owner from tracker config + directory name from codebase path), list open pull requests for story branches of issue N in each codebase repo to detect any unmerged PRs.

If any open story has an unmerged PR or is still In Progress, stop and output:

```
⛔ Sprint not ready to close. The following stories have unmerged work:
  - #N <title> (status: <status>)

Merge all story PRs into the sprint branch, then run /feature:pre-release again.
```

If all stories are merged or already closed, check for open dev bugs.

**Dev Bug Gate:**

From the sprint items, filter to open issues with label `bug` whose title starts with `[Dev Bug]`. If any found, halt:

```
⛔ Sprint not ready to close. Open development bug(s) in Sprint $SPRINT_N:
  - #N <title>

Close all dev bugs with /bugfix:release <bug#> first, then run /feature:pre-release again.
```

If no open dev bugs, proceed.

## Build & Test Gate

For each codebase repo, check out `{sprint_branch}`:

- Discover the build and test commands from the codebase root (CLAUDE.md, solution file, Makefile, or `package.json`).
- Run the full build.
- Run the full test suite.

If any codebase fails to build or has failing tests, halt:

```
⛔ Sprint not ready to close. Build/test failures:
  - <codebase>: <build|tests> failed
    <first failing line>

Fix in the owning codebase, merge into {sprint_branch}, then run /feature:pre-release again.
```

Proceed only when every codebase builds clean and all tests pass.

## Check for Migrations (Backend Only)

Get the list of files changed between `main` and `{sprint_branch}` in the backend repo. Apply the migration detection rule from the `project-config` skill. Capture the filtered list (if any) for **Create Release PRs (Sprint Branch → Main)**.

If no migration files are found, note: "No database migrations in this sprint."

## Create Release PRs (Sprint Branch → Main)

Via the `git` skill, for each codebase create a sprint release PR for sprint N with title `feat(sprint-N): {one-line sprint goal from the requirement}`, base `main`, body rendered from the `pr-release` template via the `github-templates` skill.

## Post Sprint Summary

Render the `comment-sprint-summary` template via the `github-templates` skill with `{sprint, closed_date, stories, release_prs, migrations}`. Via the `github` skill, post as a comment on the requirement issue.

## Next Step

Sprint readiness gate passed; release PRs open. Print the next command:

- `/feature:release <sprint_number>` — merge release PRs and close the sprint
