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

- **Story change** — compare the TDD against current story ACs → detect divergence. Use after stories were added, amended, or closed.
- **User input** — user describes what changed in the technical design. Use when the delta isn't in story ACs.

## Load Sprint Context

Via `github` skill, load Sprint Snapshot for Sprint $SPRINT_N → `$STORIES`, `$REQUIREMENT`, `$TDD`, `$DESIGN`. Halt if any precondition fails:

- `$REQUIREMENT` absent → `⛔ No requirement issue found in Sprint $SPRINT_N. Cannot regenerate TDD without a requirement.`
- `$STORIES` empty → `⛔ No user stories found in Sprint $SPRINT_N. Run /feature:stories:create <requirement_issue> first.`
- `$TDD` absent → `⛔ No TDD found for Sprint $SPRINT_N — run /feature:technical-design:create first.`

Exclude `[Revert]`-prefixed issues from `$STORIES`.

`$DESIGN` present → read the Storybook story files its Surfaces table links (full surface set) → design context for the TDD author.

Resolve every codebase → `$AVAILABLE_CODEBASES` (each: name, role ∈ `{backend, frontend, infrastructure}`, path).

## Derive Change Intent

Via `technical-design` skill, produce `$CHANGE_INTENT` per `$REGEN_SOURCE`:

### Story change

Compare the TDD body's assumptions (data models, API spec, components, stories referenced) against current ACs → identify:

- stories whose ACs diverged from the TDD
- stories added since the TDD was written
- stories now closed

No differences → report `⛔ No story changes found — TDD is already up to date.` and stop.

Summarise the cumulative scope delta across changed stories — added / modified / removed at feature level → `$CHANGE_INTENT`.

### User input

Ask via `AskUserQuestion` → `$TDD_DELTA`: `What changed in the technical design for Sprint $SPRINT_N, and why?` Too thin → one follow-up. Decompose `$TDD_DELTA` → feature-level summary of added / modified / removed concerns → `$CHANGE_INTENT`.

## Amend the TDD

Probe the codebase against `main` → revised decisions ground in the sprint's true baseline, never partially-implemented sprint-branch work (superseded prior-story decisions stay out of the revision).

Via `technical-design` skill, spawn a subagent to revise the TDD. Pass: existing TDD body, all `$STORIES` (with implementation status), requirement body, design context (if present), `$AVAILABLE_CODEBASES`, `$CHANGE_INTENT`.

Subagent: revises affected canonical sections → reconciles technical stories → classifies scope impact.

`$CHANGE_INTENT` selects what to rewrite only. `$NEW_BODY` must read as a freshly-authored current-state TDD:

- present tense
- no delta framing
- no mention of what changed or of superseded decisions

Change record lives in `$SCOPE_CLASSIFICATION_TABLE` + `$TECHNICAL_STORIES_DELTA`, never in the body.

Returns:

- `$NEW_BODY` — full revised TDD markdown (unchanged areas preserved byte-for-byte), including the `technical_stories` table.
- `$SCOPE_CLASSIFICATION_TABLE` — markdown classifying every implemented story as `additive` / `breaking` / `structural` / `unaffected`.
- `$TECHNICAL_STORIES_DELTA` — added / modified / removed / unchanged per technical story vs the baseline TDD.

## Draft + Approve Loop

`$DRAFT = .claude/state/feature-technical-design-regen-sprint-<$SPRINT_N>.md` → write:

1. `$SCOPE_CLASSIFICATION_TABLE` as a fenced block.
2. `$NEW_BODY`.
3. `## Technical Stories` rendering every row of `$TECHNICAL_STORIES_DELTA` grouped by action.

`AskUserQuestion`:

> Draft `<$DRAFT>` — classification + revised TDD body:
> - **Approve** → update the TDD issue
> - **Adjust** → describe change → re-run **Amend the TDD** → rewrite draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → append to `$CHANGE_INTENT` → re-run **Amend the TDD** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Update TDD Issue**

## Update TDD Issue

Via `github` skill, update the TDD issue body with `$NEW_BODY`. Hold its number → `$TDD_ISSUE_NUMBER`.

Per `[Story]` classified `breaking` or `structural` in `$SCOPE_CLASSIFICATION_TABLE` → set board Status back to `Todo` (the TDD change invalidates its implementation).

## Reconcile Technical Stories

Via `github` skill, per row in `$TECHNICAL_STORIES_DELTA`:

| Action | Tracker mutation |
|--------|------------------|
| `added` | Create a `[Tech]` issue — label `user-story`, body from `issue-technical-story` template (via `github-templates` skill) referencing `#$TDD_ISSUE_NUMBER` → **Register Issue on Board** (Type `Feature`, Status `Todo`, Sprint `Sprint $SPRINT_N`). Back-fill `Required by:` → `[Story]` `#id`s and `Depends on:` → `[Tech]` `#id`s; append `Depends on: #<tech-issue>` to each referenced `[Story]`'s Notes. |
| `modified` | Look up the matching `[Tech]` issue by title → rewrite body → re-back-fill cross-refs → if `required_by_titles` changed, update affected `[Story]` Notes → board Status `Todo`. |
| `removed` | Scan the matching `[Tech]` issue's comments for an implementation-complete notification. **Has implementation-complete comment (merged PRs)** → create a `[Revert] <original-title>` issue (label `user-story`, **Register Issue on Board** under the same Sprint, body `Reverts: #<original>`, ACs describe the rollback) → close the original → board Status `Done`. **No implementation-complete comment** → close the issue → board Status `Done`. Drop the matching `Depends on:` bullet from every `[Story]` that referenced it. |
| `unchanged` | Skip. |

Delete `$DRAFT` via `Bash: rm`.

## Next Step

TDD regenerated. Next:

- `/feature implement the affected stories`