---
name: feature:requirement:create
description: Draft a new requirement issue from a free-text description, run a PRODUCT.md alignment check, gate via draft+approve, then file.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Requirement — Create

Navigator supplies `$DESCRIPTION`.

## Workflow
1. Load Product Context
2. Discovery Dialog
3. Resolve Body
4. Draft + Approve Loop
5. Write Issue
6. Provision Sprint
7. Next Step

## Load Product Context

Read `PRODUCT.md` (repo root). Hold **Vision** + **Business Goals**.

## Discovery Dialog

Ask via `AskUserQuestion` (single call; skip what `$DESCRIPTION` already answers clearly):

- **Problem / user need** — what problem, why now? The underlying need, not a proposed solution.
- **Target users** — which segment(s).
- **Success outcome** — what's true once shipped; how we'd know.
- **Scope boundaries** — what's in, what's out.
- **Constraints** — deadlines, dependencies, platforms, non-negotiables.

Vague answer, or conflicts with PRODUCT.md **Vision** / **Business Goals** → focused follow-up `AskUserQuestion` first. Fold answers into `$DESCRIPTION` — the enriched need **Resolve Body** drafts from.

## Resolve Body

Via `github-templates` skill, render body from `issue-requirement` template with `{summary, goals, out_of_scope}`.

Append after the rendered summary:

> **Alignment Check**
> - Vision match: [yes / partial / no — one sentence]
> - Business goal match: [which goal(s) it serves — or "none identified"]

Both "no" → surface a warning.

## Draft + Approve Loop

`$DRAFT = .claude/state/feature-requirement-create.md` → write rendered body → `AskUserQuestion`:

> Draft `<$DRAFT>`:
> - **Approve** → write issue
> - **Adjust** → describe change → re-render draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → fold into `$DESCRIPTION` → re-run **Resolve Body** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Write Issue**

## Write Issue

Via `github` skill, create issue `[Requirement] <concise title>`, rendered body, label `requirement` → hold `$REQ_ISSUE_NUMBER`.

Delete `$DRAFT` via `Bash: rm`.

## Provision Sprint

Via `github` skill:
1. **Next Sprint Number** → `$SPRINT_N`.
2. **Ensure Sprint** for `$SPRINT_N` — create `Sprint $SPRINT_N` option.
3. **Register Issue on Board** for `#$REQ_ISSUE_NUMBER` — Type `Feature`, Status `Todo`, Sprint `Sprint $SPRINT_N`.

Resolve every codebase (api / web / infrastructure). Via `git` skill, create the sprint branch for `$SPRINT_N` in each.

## Next Step

Requirement filed. Next:

- `/feature break the requirement into stories`