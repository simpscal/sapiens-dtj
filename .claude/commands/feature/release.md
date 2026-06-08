---
name: feature:release
description: Close a feature sprint — merge release PRs, delete story sub-branches, mark all sprint issues Done and close them.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Feature Release

## Workflow
1. Infer Active Sprint
2. Resume Check
3. Fetch Sprint Snapshot
4. Merge Release PRs
5. Delete Story Sub-branches
6. Close All Sprint Issues
7. Next Step

## Infer Active Sprint

Via the `github` skill, resolve the active sprint → `$SPRINT_N`. Halt if none: `⛔ No sprint on the board to close.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = release-<$SPRINT_N>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Infer Active Sprint**.
- **Cancel** — abort; leave state untouched.

## Fetch Sprint Snapshot

Via the `github` skill, list **all** sprint items (open and closed). For each, note number, title, labels, status, state.

Partition into four groups:

- **Stories**: issues with `user-story` label (both `[Story]` and `[Tech]`).
- **TDD**: issue whose title contains `Technical Design Document`.
- **Design**: issue with `design` label.
- **Requirement**: issue with `requirement` label.

Guard: a feature sprint must carry a Requirement. If `$REQUIREMENT` is absent, halt: `⛔ Sprint $SPRINT_N has no requirement issue — this command targets feature sprints.`

## Merge Release PRs

Via the `git` skill, for each codebase repo find the open release PR for sprint N (created by pre-release) and squash-merge it (**Merge PR** operation). Output:

```
✓ Merged <pr_title> in {codebase_name}
```

## Delete Story Sub-branches

Via the `git` skill, for each codebase list story branches for sprint N. Only delete story branches — sprint branches must not be deleted.

Delete each story branch from the remote. Output:

```
✓ Deleted {branch_name} from {codebase_name}
```

## Close All Sprint Issues

Via the `github` skill, for every issue in the sprint (stories, TDD, requirement, design):

1. Set board Status to `Done`.
2. Close the issue.

Output one line per issue:

```
✓ Closed #N — <title>
```

## Next Step

Sprint closed — feature lifecycle complete. Print:

- `/feature:requirement:create <description>` — start the next feature
- `/help-flows` — pick another workflow
