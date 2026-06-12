---
name: feature:stories:create
description: Decompose a requirement into INVEST user stories under the active sprint. Draft + approve gate, then persist to GitHub.
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

Read requirement `#$ISSUE_NUMBER` → derive 1-sentence sprint goal. Via `user-stories` skill, decompose → `$STORIES` + `rewrote_for_testability`:

- INVEST
- ACs as user-observable behaviour
- run testability linter
- order by dependency depth → user value

`rewrote_for_testability` non-empty → surface `N ACs were rewritten for testability — see details below` + the list before continuing.

Via `github` skill, read `#$ISSUE_NUMBER`'s board Sprint → `$SPRINT_N`. Absent → halt `⛔ Issue #$ISSUE_NUMBER has no board Sprint — provision the sprint via /feature:requirement:create first.`

## Draft + Approve Loop

`$DRAFT = .claude/state/feature-stories-<$ISSUE_NUMBER>.md` → write every story spec field verbatim from `$STORIES` (`title`, `user_story`, `acceptance_criteria`, Notes per the `user-stories` skill's Notes rules). Add `## Testability rewrites` section when `rewrote_for_testability` non-empty.

`AskUserQuestion`:

> Draft `<$DRAFT>` — `<N>` stories:
> - **Approve** → create GitHub issues from the draft
> - **Adjust** → describe change → re-decompose → rewrite draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → fold into decomposition context → re-run → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Persist**

## Persist

Via `github` skill, per spec in `$STORIES`:

1. Create issue `spec.title`, label `user-story`, body from `issue-user-story` template (via `github-templates` skill) with `{user_story, acceptance_criteria, notes, requirement_issue: $ISSUE_NUMBER}`.
2. **Register Issue on Board** — Type `Feature`, Status `Todo`, Sprint `Sprint $SPRINT_N`.

After all issues exist → back-fill dependency refs in Notes (resolve `spec.notes.depends_on_titles` → issue numbers) for both `Depends on` + `Blocks`.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Sprint stories filed. Next:

- `/feature design the Storybook surfaces`
- `/feature write the technical design`