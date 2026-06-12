---
name: feature:requirement:amend
description: Apply a free-text delta to an existing requirement issue body, run a PRODUCT.md alignment check, gate via draft+approve, then update.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Requirement — Amend

Navigator supplies `$ISSUE_NUMBER` and `$DELTA`.

## Workflow
1. Load Product Context
2. Resolve Body
3. Draft + Approve Loop
4. Update Issue
5. Next Step

## Load Product Context

Read `PRODUCT.md` (repo root). Hold **Vision** + **Business Goals**.

## Resolve Body

Read issue `#$ISSUE_NUMBER` → apply `$DELTA` → revised body.

Via `github-templates` skill, render from `issue-requirement` template with `{summary, goals, out_of_scope}`.

Append after the rendered summary:

> **Alignment Check**
> - Vision match: [yes / partial / no — one sentence]
> - Business goal match: [which goal(s) it serves — or "none identified"]

Both "no" → surface a warning.

## Draft + Approve Loop

`$DRAFT = .claude/state/feature-requirement-amend-<$ISSUE_NUMBER>.md` → write rendered body → `AskUserQuestion`:

> Draft `<$DRAFT>`:
> - **Approve** → update issue
> - **Adjust** → describe change → re-render draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → fold into `$DELTA` → re-run **Resolve Body** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Update Issue**

## Update Issue

Via `github` skill, update body of `#$ISSUE_NUMBER`. Add label `requirement-updated`. Output: `Issue #N updated — <one-line summary of what changed>`.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Requirement updated. Next:

- `/feature reconcile the stories with the delta`