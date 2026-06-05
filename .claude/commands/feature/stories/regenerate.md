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

- **Requirement change** — diff the requirement's current Goals against the linked stories. Use after the requirement issue was amended.
- **User input** — reconcile against a scope delta the user describes in plain language. Use when the change isn't captured in the requirement Goals.

Via the `github` skill, read issue `#req_issue_number` in full for context. Produce `$SCOPE_ITEMS` — the discrete units of intended scope to reconcile against — per `$SYNC_SOURCE`:

### Requirement change

Extract the requirement's **Goals**. `$SCOPE_ITEMS` = each Goal.

### User input

Ask via `AskUserQuestion`, hold as `$SCOPE_DELTA`: `What scope changed for the stories under #req_issue_number (<title>), and why?` If too thin, ask one follow-up. Via the `user-stories` skill, decompose `$SCOPE_DELTA` into discrete, user-observable changes → `$SCOPE_ITEMS`. The requirement is context only.

## Fetch Linked Stories

Determine the sprint milestone from `req_issue_number`'s milestone field.

- No milestone → halt: `⛔ Issue #<N> has no sprint milestone. Stories cannot be regenerated until a sprint milestone is assigned.`

Via the `github` skill, list open issues labelled `user-story` whose title starts with `[Story]` in the sprint milestone. Filter to **Linked stories** — body references `#req_issue_number`. Read each in full.

Preconditions:

- Linked stories empty → halt: `⛔ No user stories linked to #<req_issue_number> in the sprint milestone. Run /feature:stories:create first.`

## Classify Scope Changes

Via the `user-stories` skill, compare `$SCOPE_ITEMS` against the linked stories.

For each scope item and each linked story:

| Classification | Condition | Planned Action |
|---|---|---|
| **Covered** | Linked story fully covers the scope item | No change |
| **Updatable** | Linked story partially covers a scope item not reflected in the current ACs | Amend ACs — cite the scope item as the delta |
| **New** | No existing story covers the scope item | Write a new story |
| **Removed** | Linked story covers a scope item explicitly dropped | Close or revert |
| **Orphaned** | Linked story doesn't match any current Goal | Close or revert |

**Orphaned** applies only when `$SYNC_SOURCE` is **Requirement change** — a full Goals diff can detect stories matching no Goal. A **User input** delta is targeted: never orphan a story the user didn't name.

Output a **Change Plan Table** listing every scope item and affected story with its classification. Clarify any ambiguity with the PO before proceeding.

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/feature-stories-regen-<req_issue_number>.md`.

Write `$DRAFT` rendering the full Change Plan Table plus per-section detail:

- **Stories to update** — each story with a one-line AC delta summary.
- **Stories to create** — each new story title and the scope it covers.
- **Stories to remove** — each story to close or revert (including orphaned).

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>` — `<N_update>` updates · `<N_create>` new · `<N_remove>` removals. Choose:
>
> - **Approve** — execute changes from the draft.
> - **Adjust** — describe what to change; re-classify and rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`, fold into the classification context, re-run Classify Scope Changes, overwrite `$DRAFT`, re-prompt..
- **Cancel** — halt.
- **Approve** — proceed to **Execute Changes**.

## Execute Changes

### 5a — Prune Stale Dependencies

Scan every open story involved in this sync. Remove any `Depends on:` or `Blocks:` reference pointing to a closed issue.

### 5b — Amend Updatable Stories

Via the `user-stories` skill, for each updatable story reshape its ACs per the scope item driving the amendment. Classify each baseline AC as Kept / Removed / Modified; new entries are Added. Run the testability linter on Added and Modified ACs. Reconstruct the body preserving all sections except `## Acceptance Criteria` (and conditionally `## Notes`). Via the `github` skill, update the story body and remove label `implemented`.

### 5c — Write New Stories

Via the `user-stories` skill, for each new scope item decompose into user stories using the requirement `#req_issue_number` body as context. Apply INVEST, phrase ACs as user-observable behaviour, run the testability linter. Via the `github` skill, for each spec create an issue with the `issue-user-story` template, label `user-story`, milestone set to the sprint milestone, body referencing `#req_issue_number`. After all issues exist, back-fill dependency references for both `Depends on` and `Blocks` directions.

### 5d — Remove Obsolete Stories

Via the `github` skill, for each **Removed** or **Orphaned** story scan its comments for an implementation-complete notification:

- **Has implementation-complete comment (merged PRs)** → create a `[Revert] <original-title>` issue under the same sprint milestone with label `user-story`. Body includes `Reverts: #<original>`. ACs describe the rollback (revert merged commits across affected codebases, tests pass, pre-merge behaviour restored). Close the original story.
- **No implementation-complete comment** → close the story directly.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Sprint stories reconciled. Print the next command:

- `/feature:design:regenerate <sprint_number>` — if surfaces changed
- `/feature:technical-design:regenerate <sprint_number>` — reconcile the TDD
- `/feature:implement <story_issue>` — implement changed stories
