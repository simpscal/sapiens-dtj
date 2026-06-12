---
name: feature:stories:regenerate
description: Reconcile sprint stories with a scope delta — sourced from the current requirement Goals or from the user's input. Amend / create / remove per scope item.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Stories — Regenerate

Navigator supplies `$ISSUE_NUMBER` (the requirement issue), referenced below as `req_issue_number`.

## Workflow
1. Resolve Scope Delta
2. Fetch Linked Stories
3. Classify Scope Changes
4. Draft + Approve Loop
5. Execute Changes
6. Next Step

## Resolve Scope Delta

Ask via `AskUserQuestion` → `$SYNC_SOURCE`:

- **Requirement change** — diff the requirement's current Goals against linked stories. Use after the requirement was amended.
- **User input** — reconcile against a scope delta the user describes. Use when the change isn't in the requirement Goals.

Via `github` skill, read `#req_issue_number` in full. Produce `$SCOPE_ITEMS` (discrete units of intended scope) per `$SYNC_SOURCE`:

### Requirement change

`$SCOPE_ITEMS` = each requirement **Goal**.

### User input

Ask via `AskUserQuestion` → `$SCOPE_DELTA`: `What scope changed for the stories under #req_issue_number (<title>), and why?` Too thin → one follow-up. Via `user-stories` skill, decompose `$SCOPE_DELTA` → discrete user-observable changes → `$SCOPE_ITEMS`. Requirement is context only.

## Fetch Linked Stories

Via `github` skill, determine the sprint from `req_issue_number`'s board Sprint.

- No board Sprint → halt `⛔ Issue #<N> has no board Sprint. Stories cannot be regenerated until the sprint is assigned on the board.`

Via `github` skill, list sprint items labelled `user-story` with title `[Story]` → filter to **Linked stories** (body references `#req_issue_number`) → read each in full.

- Linked stories empty → halt `⛔ No user stories linked to #<req_issue_number> in the sprint. Run /feature:stories:create first.`

## Classify Scope Changes

Via `user-stories` skill, compare `$SCOPE_ITEMS` against linked stories. Per scope item × linked story:

| Classification | Condition | Planned Action |
|---|---|---|
| **Covered** | Story fully covers the scope item | No change |
| **Updatable** | Story partially covers a scope item not in current ACs | Amend ACs — cite the scope item as delta |
| **New** | No story covers the scope item | Write a new story |
| **Removed** | Story covers a scope item explicitly dropped | Close or revert |
| **Orphaned** | Story matches no current Goal | Close or revert |

**Orphaned** applies only when `$SYNC_SOURCE` = **Requirement change** (a full Goals diff detects stories matching no Goal). **User input** is targeted: never orphan a story the user didn't name.

Output a **Change Plan Table** — every scope item + affected story + classification. Ambiguity → clarify with PO before proceeding.

## Draft + Approve Loop

`$DRAFT = .claude/state/feature-stories-regen-<req_issue_number>.md` → write the full Change Plan Table + per-section detail:

- **Stories to update** — each with a 1-line AC delta summary.
- **Stories to create** — each new title + scope it covers.
- **Stories to remove** — each to close or revert (incl. orphaned).

`AskUserQuestion`:

> Draft `<$DRAFT>` — `<N_update>` updates · `<N_create>` new · `<N_remove>` removals:
> - **Approve** → execute changes from the draft
> - **Adjust** → describe change → re-classify → rewrite draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → fold into classification context → re-run **Classify Scope Changes** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Execute Changes**

## Execute Changes

### 5a — Prune Stale Dependencies

Per open story in this sync → remove any `Depends on:` / `Blocks:` reference pointing to a closed issue.

### 5b — Amend Updatable Stories

Via `user-stories` skill, per updatable story:

- Reshape ACs per the driving scope item.
- Classify each baseline AC: Kept / Removed / Modified; new = Added.
- Run testability linter on Added + Modified.
- Rebuild body, preserving all sections except `## Acceptance Criteria` (and conditionally `## Notes`).

Via `github` skill → update story body → board Status `Todo`.

### 5c — Write New Stories

Via `user-stories` skill, per new scope item → decompose into stories (context: `#req_issue_number` body):

- INVEST
- ACs as user-observable behaviour
- run testability linter

Via `github` skill, per spec → create issue (`issue-user-story` template, label `user-story`, body refs `#req_issue_number`) → **Register Issue on Board** (Type `Feature`, Status `Todo`, Sprint set). After all issues exist → back-fill `Depends on` + `Blocks` references.

### 5d — Remove Obsolete Stories

Via `github` skill, per **Removed** / **Orphaned** story → scan comments for an implementation-complete notification:

- **Has implementation-complete comment (merged PRs)** → create `[Revert] <original-title>` issue, label `user-story`, **Register Issue on Board** under the same Sprint (Type `Feature`, Status `Todo`). Body: `Reverts: #<original>`; ACs describe the rollback (revert merged commits across affected codebases, tests pass, pre-merge behaviour restored). Close original → board Status `Done`.
- **No implementation-complete comment** → close the story → board Status `Done`.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Sprint stories reconciled. Next:

- `/feature regenerate the surfaces` — if surfaces changed
- `/feature regenerate the technical design`
- `/feature implement the changed stories`