---
name: feature:requirement:create
description: Draft a new requirement issue from a free-text description, run a PRODUCT.md alignment check, gate via draft+approve, then file.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Requirement — Create

Navigator supplies `$DESCRIPTION`.

## Workflow
1. Load Product Context
2. Resolve Body
3. Draft + Approve Loop
4. Write Issue
5. Provision Sprint
6. Next Step

## Load Product Context

Read `PRODUCT.md` from the repo root. Extract **Vision** and **Business Goals** and hold them.

## Resolve Body

Draft the body from `$DESCRIPTION`.

Via the `github-templates` skill, render the body from the `issue-requirement` template with `{summary, goals, out_of_scope}`.

Append an **Alignment Check** block after the rendered summary:

> **Alignment Check**
> - Vision match: [yes / partial / no — one sentence]
> - Business goal match: [which goal(s) it serves — or "none identified"]

If both checks are "no", surface a warning.

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/feature-requirement-create.md`.

Write `$DRAFT` with the rendered body from **Resolve Body**.

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>`. Choose:
>
> - **Approve** — write the issue.
> - **Adjust** — describe what to change; re-render and rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`, fold into `$DESCRIPTION`, re-run **Resolve Body**, overwrite `$DRAFT`, re-prompt.
- **Cancel** — halt.
- **Approve** — proceed to **Write Issue**.

## Write Issue

Via the `github` skill, create an issue titled `[Requirement] <concise title>` with the rendered body, label `requirement`. Hold the issue number as `$REQ_ISSUE_NUMBER`.

Delete `$DRAFT` via `Bash: rm`.

## Provision Sprint

Via the `github` skill, list milestones to determine the next sprint number `$SPRINT_N`, create milestone `Sprint $SPRINT_N` with a one-line goal from the requirement summary (hold `$MILESTONE_ID`), and attach `#$REQ_ISSUE_NUMBER` to milestone `Sprint $SPRINT_N`.

Resolve every codebase the project exposes (api / web / infrastructure paths). Via the `git` skill, for each create the sprint branch for Sprint `$SPRINT_N`.

## Next Step

Requirement issue filed. Print the next command:

- `/feature:stories:create <requirement_issue>` — decompose into sprint stories
