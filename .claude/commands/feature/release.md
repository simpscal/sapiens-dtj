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

Via `github` skill, resolve active sprint → `$SPRINT_N`. None → halt `⛔ No sprint on the board to close.`

## Resume Check

Look up resume state (`workflow = feature`, `run_key = release-<$SPRINT_N>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Infer Active Sprint**.
- **Cancel** → abort; leave state untouched.

## Fetch Sprint Snapshot

Via `github` skill, list **all** sprint items (open + closed) → per item note number, title, labels, status, state. Partition:

- **Stories**: label `user-story` (`[Story]` + `[Tech]`).
- **TDD**: title contains `Technical Design Document`.
- **Design**: label `design`.
- **Requirement**: label `requirement`.

Guard: a feature sprint must carry a Requirement. `$REQUIREMENT` absent → halt `⛔ Sprint $SPRINT_N has no requirement issue — this command targets feature sprints.`

## Merge Release PRs

Via `git` skill, per codebase repo → find the open release PR for sprint N (created by pre-release) → squash-merge (**Merge PR**). Output:

```
✓ Merged <pr_title> in {codebase_name}
```

## Delete Story Sub-branches

Via `git` skill, per codebase → list story branches for sprint N. Delete only story branches — never sprint branches. Delete each from the remote. Output:

```
✓ Deleted {branch_name} from {codebase_name}
```

## Close All Sprint Issues

Via `github` skill, per sprint issue (stories, TDD, requirement, design, in-sprint bugs, in-sprint refactors):

1. Set board Status `Done`.
2. Close the issue.

Output per issue:

```
✓ Closed #N — <title>
```

## Next Step

Sprint closed — feature lifecycle complete. Next:

- `/feature start the next feature`