---
name: feature:technical-design:regenerate
description: Regenerate the sprint TDD — sourced from changed story ACs or from the user's input. Revise affected sections, classify scope impact, reconcile technical stories.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Technical Design — Regenerate

Navigator supplies `$SPRINT_N`.

## Workflow
1. Resolve Source
2. Load Sprint Context
3. Derive Change Intent
4. Amend the TDD
5. Draft + Approve Loop
6. Update TDD Issue
7. Reconcile Technical Stories
8. Next Step

## Resolve Source

Ask via `AskUserQuestion` → `$REGEN_SOURCE`:

- **Story change** — compare the TDD against current story ACs to detect divergence. Use after stories were added, amended, or closed.
- **User input** — user describes what changed in the technical design. Use when the delta isn't reflected in story ACs.

## Load Sprint Context

Via the `github` skill, load Sprint Snapshot for Sprint $SPRINT_N. Hold `$STORIES`, `$REQUIREMENT`, `$TDD`, `$DESIGN`.

Preconditions (halt if any fail):

- `$REQUIREMENT` absent → `⛔ No requirement issue found in Sprint $SPRINT_N. Cannot regenerate TDD without a requirement.`
- `$STORIES` empty → `⛔ No user stories found in Sprint $SPRINT_N. Run /feature:stories:create <requirement_issue> first.`
- `$TDD` absent → `⛔ No TDD found for Sprint $SPRINT_N — run /feature:technical-design:create first.`

Exclude `[Revert]`-prefixed issues from `$STORIES`.

If `$DESIGN` is present, read the Storybook story files its Surfaces table links (full surface set) → design context for the TDD author.

Resolve every codebase the project exposes into `$AVAILABLE_CODEBASES` (each entry: name, role ∈ `{backend, frontend, infrastructure}`, path).

## Derive Change Intent

Via the `technical-design` skill, produce `$CHANGE_INTENT` per `$REGEN_SOURCE`:

### Story change

Compare the TDD body's assumptions (data models, API spec, components, stories referenced) against the stories' current ACs. Identify stories whose ACs have diverged from what the TDD describes, stories added since the TDD was written, and stories that are now closed. If no differences, report `⛔ No story changes found — TDD is already up to date.` and stop.

Summarise the cumulative scope delta across the changed stories — added / modified / removed at the feature level. Hold as `$CHANGE_INTENT`.

### User input

Ask via `AskUserQuestion`, hold as `$TDD_DELTA`: `What changed in the technical design for Sprint $SPRINT_N, and why?` If too thin, ask one follow-up. Decompose `$TDD_DELTA` into a feature-level summary of added / modified / removed concerns. Hold as `$CHANGE_INTENT`.

## Amend the TDD

Via the `technical-design` skill, spawn a subagent to revise the TDD. Pass the existing TDD body, all `$STORIES` (with implementation status), the requirement body, design context (if present), `$AVAILABLE_CODEBASES`, and `$CHANGE_INTENT`.

The subagent revises affected canonical sections, reconciles technical stories, and classifies scope impact.

Returns:

- `$NEW_BODY` — full revised TDD markdown (unchanged areas preserved byte-for-byte), including the `technical_stories` table.
- `$SCOPE_CLASSIFICATION_TABLE` — markdown classifying every implemented story as `additive` / `breaking` / `structural` / `unaffected`.
- `$TECHNICAL_STORIES_DELTA` — added / modified / removed / unchanged classification per technical story against the baseline TDD.

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/feature-technical-design-regen-sprint-<$SPRINT_N>.md`.

Write `$DRAFT` (overwrite on iteration) with:

1. `$SCOPE_CLASSIFICATION_TABLE` as a fenced block.
2. `$NEW_BODY`.
3. `## Technical Stories` rendering every row of `$TECHNICAL_STORIES_DELTA` grouped by action.

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>` — classification + revised TDD body. Choose:
>
> - **Approve** — update the TDD issue.
> - **Adjust** — describe what to change; re-run **Amend the TDD** with the appended feedback; rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`, append to `$CHANGE_INTENT`, re-run **Amend the TDD**, overwrite `$DRAFT`, re-prompt
- **Cancel** — halt.
- **Approve** — proceed to **Update TDD Issue**.

## Update TDD Issue

Via the `github` skill, update the body of the TDD issue with `$NEW_BODY`. Hold its number as `$TDD_ISSUE_NUMBER`.

For every `[Story]` issue classified `breaking` or `structural` in `$SCOPE_CLASSIFICATION_TABLE`, set board Status back to `Todo` — the TDD change invalidates its implementation.

## Reconcile Technical Stories

Via the `github` skill, for each row in `$TECHNICAL_STORIES_DELTA`:

| Action | Tracker mutation |
|--------|------------------|
| `added` | Create a `[Tech]` issue — label `user-story`, body rendered from the `issue-technical-story` template via the `github-templates` skill referencing `#$TDD_ISSUE_NUMBER`, registered on the board via **Register Issue on Board** — Type `Feature`, Status `Todo`, Sprint `Sprint $SPRINT_N`. Back-fill `Required by:` → `[Story]` `#id`s and `Depends on:` → `[Tech]` `#id`s; append `Depends on: #<tech-issue>` to each referenced `[Story]`'s Notes. |
| `modified` | Look up the matching `[Tech]` issue by title; rewrite the body; re-back-fill cross-refs; if `required_by_titles` changed, update affected `[Story]` Notes. Set board Status back to `Todo`. |
| `removed` | Scan the matching `[Tech]` issue's comments for an implementation-complete notification. **Has implementation-complete comment (merged PRs)** → create a `[Revert] <original-title>` issue with label `user-story`, registered on the board under the same Sprint, body includes `Reverts: #<original>`, ACs describe the rollback; close the original and set its board Status to `Done`. **No implementation-complete comment** → close the issue directly and set its board Status to `Done`. Drop the matching `Depends on:` bullet from every `[Story]` that referenced it. |
| `unchanged` | Skip. |

Delete `$DRAFT` via `Bash: rm`.

## Next Step

TDD regenerated. Print the next command:

- `/feature:implement <story_issue>` — implement affected stories

