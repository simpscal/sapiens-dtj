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

Via `github` skill, resolve active sprint → `$SPRINT_N`. None → halt `⛔ No sprint on the board to check.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = pre-release-<$SPRINT_N>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Infer Active Sprint**.
- **Cancel** → abort; leave state untouched.

## Fetch Sprint Snapshot

Via `github` skill, list **open** sprint items only → per item note number, title, labels, status, state. Partition:

- **Stories**: label `user-story` (`[Story]` + `[Tech]`).
- **TDD**: title contains `Technical Design Document`.
- **Design**: label `design`.
- **Requirement**: label `requirement`.

Guard: a feature sprint must carry a Requirement. `$REQUIREMENT` absent → halt `⛔ Sprint $SPRINT_N has no requirement issue — this command targets feature sprints.`

Derive sprint branch name for sprint N.

## Readiness Gate

**Implementable items** = stories (`[Story]`, `[Tech]`) + in-sprint bugs (`[Dev Bug]`) + in-sprint refactors (`[Dev Refactor]`) — every open sprint item carrying work that merges into the sprint branch.

Per implementable item still **open**:

- Check board Status for `In Progress`.
- Per codebase repo (slug: owner from tracker config + directory name from codebase path) → list open PRs for the item's branches of issue N → detect unmerged PRs.

Any open item with an unmerged PR or still In Progress → stop:

```
⛔ Sprint not ready to close. The following items have unmerged work:
  - #N <title> (status: <status>)

Merge all item PRs into the sprint branch with /feature:merge <N>, then run /feature:pre-release again.
```

Every implementable item merged or closed → proceed.

## Build & Test Gate

Per codebase repo → check out `{sprint_branch}`:

- Discover build + test commands from codebase root (CLAUDE.md, solution file, Makefile, or `package.json`).
- Run the full build.
- Run the full test suite.

Any codebase fails build or has failing tests → halt:

```
⛔ Sprint not ready to close. Build/test failures:
  - <codebase>: <build|tests> failed
    <first failing line>

Fix in the owning codebase, merge into {sprint_branch}, then run /feature:pre-release again.
```

Proceed only when every codebase builds clean + all tests pass.

## Check for Migrations (Backend Only)

List files changed between `main` and `{sprint_branch}` in the backend repo → apply the migration detection rule from `project-config` skill (presence check).

- Migration files present → read cutover + rollback SQL from the **sprint TDD's Migration Plan** → capture for **Create Release PRs (Sprint Branch → Main)**.

- No migration files → note "No database migrations in this sprint."

## Create Release PRs (Sprint Branch → Main)

Via `git` skill, per codebase → create a sprint release PR for sprint N: title `feat(sprint-N): {one-line sprint goal from the requirement}`, base `main`, body from `pr-release` template (via `github-templates` skill).

## Post Sprint Summary

Render `comment-sprint-summary` template (via `github-templates` skill) with `{sprint, closed_date, stories, release_prs, migrations}` → post as a comment on the requirement issue via `github` skill.

## Next Step

Sprint readiness gate passed; release PRs open. Next:

- `/feature release the sprint`