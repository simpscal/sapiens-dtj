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

Read `PRODUCT.md` from the repo root. Extract **Vision** and **Business Goals** and hold them.

## Resolve Body

Read issue `#$ISSUE_NUMBER` in full. Apply `$DELTA` to produce the revised body.

Via the `github-templates` skill, render the body from the `issue-requirement` template with `{summary, goals, out_of_scope}`.

Append an **Alignment Check** block after the rendered summary:

> **Alignment Check**
> - Vision match: [yes / partial / no — one sentence]
> - Business goal match: [which goal(s) it serves — or "none identified"]

If both checks are "no", surface a warning.

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/feature-requirement-amend-<$ISSUE_NUMBER>.md`.

Write `$DRAFT` with the rendered body from **Resolve Body**.

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>`. Choose:
>
> - **Approve** — update the issue.
> - **Adjust** — describe what to change; re-render and rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`, fold into `$DELTA`, re-run **Resolve Body**, overwrite `$DRAFT`, re-prompt.
- **Cancel** — halt.
- **Approve** — proceed to **Update Issue**.

## Update Issue

Via the `github` skill, update the body of issue `#$ISSUE_NUMBER`. Add label `requirement-updated`. Output: `Issue #N updated — <one-line summary of what changed>`.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Requirement updated. Print the next command:

- `/feature:stories:regenerate <requirement_issue>` — reconcile stories with the delta
