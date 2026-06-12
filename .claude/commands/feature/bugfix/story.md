---
name: feature:bugfix:story
description: Author the acceptance criteria for an in-sprint bug. Loads the sprint baseline, drafts ACs from the bug body, gates on approval, then appends to the issue.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Bugfix — Story

`$ARGUMENTS` carries `bug_issue_number`.

## Workflow
1. Resume Check
2. Load Baseline
3. Author ACs
4. Draft + Approve Loop
5. Update the Bug Issue
6. Next Step

## Resume Check

Look up resume state (`workflow = feature`, `run_key = bugfix-story-<bug_issue_number>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Load Baseline**.
- **Cancel** → abort; leave state untouched.

Read issue `#bug_issue_number` in full. Missing `bug` label → halt `⛔ Issue #<N> is not a bug (labels: <labels>).`

## Load Baseline

Resolve `$SPRINT_N` from board Sprint (`Sprint N`). No board Sprint → halt `⛔ Dev bug #<N> has no board Sprint. Assign it to the active sprint on the board first.`

Via `github` skill, **Load Sprint Snapshot** for `$SPRINT_N` → `$STORIES` + `$REQUIREMENT` (open `requirement` issue; may be absent).

## Author ACs

Via `user-stories` skill, author ACs that prove bug `#bug_issue_number` is fixed, sourced from the bug body (incl. `## Bug Report`):

- phrase every AC as user-observable behaviour
- run the testability linter
- one outcome → single story spec

Pass `$STORIES` + `$REQUIREMENT` into the `user-stories` `<context>` as sprint baseline: the bug's ACs must stay consistent with existing story scope. Bug body remains the primary source.

Hold `$STORIES[0]` + `rewrote_for_testability`. Non-empty → surface `N ACs were rewritten for testability — see details below` + the list before continuing.

Extract `$AC_SET = {criteria: $STORIES[0].acceptance_criteria, notes: $STORIES[0].notes.edge_cases joined as prose}`.

## Draft + Approve Loop

`$DRAFT = .claude/state/feature-bugfix-story-<bug_issue_number>.md` → write `acceptance-criteria` template with `{criteria: $AC_SET.criteria, notes: $AC_SET.notes}`. Add `## Testability rewrites` section when `rewrote_for_testability` non-empty.

`AskUserQuestion`:

> Draft `<$DRAFT>` — ACs for bug `#bug_issue_number`:
> - **Approve** → append to the bug issue body
> - **Adjust** → describe change → re-run **Author ACs** → rewrite draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → append to **Author ACs** `<context>` → re-run **Author ACs** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Update the Bug Issue**

## Update the Bug Issue

Via `github` skill, append the rendered `acceptance-criteria` block to the end of the issue body. Do NOT modify the original `## Bug Report` section or anything before it.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Dev bug ACs filed. Next:

- `/feature fix the bug`