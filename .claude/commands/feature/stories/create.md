---
name: feature:stories:create
description: Decompose a requirement into INVEST user stories under a new sprint milestone. Draft + approve gate, then persist to GitHub.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Stories — Create

Navigator supplies `$ISSUE_NUMBER` (the requirement issue).

## Workflow
1. Decompose
2. Draft + Approve Loop
3. Persist
4. Next Step

## Decompose

Read requirement `#$ISSUE_NUMBER` in full. Derive a one-sentence sprint goal from it. Via the `user-stories` skill, decompose into user stories — apply INVEST, phrase ACs as user-observable behaviour, run the testability linter, order by dependency depth then user value. Hold as `$STORIES` + `rewrote_for_testability`.

If `rewrote_for_testability` is non-empty, surface `N ACs were rewritten for testability — see details below` and the list before continuing.

Read `#$ISSUE_NUMBER`'s milestone field → `$SPRINT_N` and `$MILESTONE_ID`. If absent, halt: `⛔ Issue #$ISSUE_NUMBER has no sprint milestone — provision the sprint via /feature:requirement:create first.`

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/feature-stories-<$ISSUE_NUMBER>.md`.

Write `$DRAFT` rendering every story spec field verbatim from `$STORIES` — `title`, `user_story`, `acceptance_criteria`, Notes per the user-stories skill's Notes rendering rules. Include a `## Testability rewrites` section when `rewrote_for_testability` is non-empty.

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>` — `<N>` stories. Choose:
>
> - **Approve** — create GitHub issues from the draft.
> - **Adjust** — describe what to change; re-decompose and rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`, fold into the decomposition context, re-run, overwrite `$DRAFT`, re-prompt.
- **Cancel** — halt.
- **Approve** — proceed to **Persist**.

## Persist

Via the `github` skill, for each spec in `$STORIES`:

1. Create an issue titled `spec.title` with label `user-story`, body rendered from the `issue-user-story` template via the `github-templates` skill with `{user_story, acceptance_criteria, notes, requirement_issue: $ISSUE_NUMBER}`.
2. Set milestone `Sprint $SPRINT_N`.

After all issues exist, back-fill dependency references in Notes (resolve `spec.notes.depends_on_titles` to issue numbers) for both `Depends on` and `Blocks` directions.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Sprint stories filed. Print the next command:

- `/feature:design:create <sprint_number>` — compose Storybook surfaces for UI stories
- `/feature:technical-design:create <sprint_number>` — author the TDD

