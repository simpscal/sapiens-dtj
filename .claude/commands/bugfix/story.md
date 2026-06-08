---
name: bugfix:story
description: Author the acceptance criteria for an existing bug. Drafts ACs from the bug body, gates on approval, then appends to the issue.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Bugfix Story

`$ARGUMENTS` carries `bug_issue_number`.

## Workflow
1. Resume Check
2. Load Baseline (development only)
3. Author ACs
4. Draft + Approve Loop
5. Update the Bug Issue
6. Next Step

## Resume Check

Look up resume state (`workflow = bugfix`, `run_key = story-<bug_issue_number>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Load Baseline**.
- **Cancel** — abort; leave state untouched.

Read issue `#bug_issue_number` in full.

Derive `$BUG_SOURCE` from the title prefix (match `[Dev Bug]` before `[Bug]`):

- Title starts with `[Dev Bug]` → `$BUG_SOURCE = development`
- Else title starts with `[Bug]` → `$BUG_SOURCE = production`

## Load Baseline

Development only. Production → skip; leave the baseline unset.

If `$BUG_SOURCE = development`: resolve `$SPRINT_N` from the issue's board Sprint value (`Sprint N`). If no board Sprint, halt:

> `⛔ Dev bug #<N> has no board Sprint. Assign it to the active sprint on the board first.`

Via the `github` skill, **Load Sprint Snapshot** for `$SPRINT_N` → `$STORIES` and `$REQUIREMENT` (open `requirement` issue; may be absent).

## Author ACs

Via the `user-stories` skill, author ACs that prove bug `#bug_issue_number` is fixed, sourced from the bug issue body (including `## Bug Report`). Phrase every AC as user-observable behaviour; run the testability linter. The bug is one outcome — produce a single story spec.

When the baseline is loaded (`$BUG_SOURCE = development`), pass `$STORIES` and `$REQUIREMENT` into the `user-stories` `<context>` as the sprint baseline: the bug's ACs must stay consistent with — and not contradict — existing story scope. The bug issue body remains the primary source.

Hold as `$STORIES[0]` + `rewrote_for_testability`.

If `rewrote_for_testability` is non-empty, surface `N ACs were rewritten for testability — see details below` and the list before continuing.

Extract `$AC_SET = {criteria: $STORIES[0].acceptance_criteria, notes: $STORIES[0].notes.edge_cases joined as prose}`.

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/bugfix-story-<bug_issue_number>.md`.

Write `$DRAFT` rendering the `acceptance-criteria` template with `{criteria: $AC_SET.criteria, notes: $AC_SET.notes}`. Include a `## Testability rewrites` section when `rewrote_for_testability` is non-empty.

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>` — ACs for bug `#bug_issue_number`. Choose:
>
> - **Approve** — append to the bug issue body.
> - **Adjust** — describe what to change; re-run **Author ACs** with the appended feedback; rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`. Append to the **Author ACs** `<context>`. Re-run **Author ACs**. Overwrite `$DRAFT`. Re-prompt
- **Cancel** — halt.
- **Approve** — proceed to **Update the Bug Issue**.

## Update the Bug Issue

Via the `github` skill, append the rendered `acceptance-criteria` block to the end of the existing issue body.

Do NOT modify the original `## Bug Report` section or anything before it.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Bug ACs filed. Print the next command:

- `/bugfix:implement <bug_issue>` — fix it
