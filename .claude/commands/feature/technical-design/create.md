---
name: feature:technical-design:create
description: Author a new TDD for a feature sprint and persist technical stories.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Technical Design — Create

Navigator supplies `$SPRINT_N`.

## Workflow
1. Load Sprint Context
2. Author TDD
3. Draft + Approve Loop
4. Write TDD Issue
5. Persist Technical Stories
6. Next Step

## Load Sprint Context

Via the `github` skill, load Sprint Snapshot for Sprint $SPRINT_N. Hold `$MILESTONE_ID`, `$STORIES`, `$REQUIREMENT`, `$TDD`, `$DESIGN`.

Exclude `[Revert]`-prefixed issues from `$STORIES`.

If `$DESIGN` is present, read the Storybook story files its Surfaces table links (full surface set) → design context for the TDD author.

Guard: if `$TDD` is present, halt: `⛔ A TDD already exists for Sprint $SPRINT_N — run /feature:technical-design:regenerate to revise it.`

Resolve every codebase the project exposes into `$AVAILABLE_CODEBASES` (each entry: name, role ∈ `{backend, frontend, infrastructure}`, path).

## Author TDD

Initialise `$FEEDBACK` empty on first entry. Via the `technical-design` skill, spawn a subagent to author the TDD. Pass the sprint goal (derived from `$REQUIREMENT`), all `$STORIES` (id, title, user_story, acceptance_criteria, notes), the requirement body, design context (if present), and `$AVAILABLE_CODEBASES`. On iteration passes, include `$FEEDBACK`.

The subagent resolves in-scope codebases, probes each in parallel, resolves blocking questions, designs all canonical sections, and decomposes technical stories.

Hold as `$TDD_BODY` + `$TECHNICAL_STORIES`. Treat as draft — not yet final.

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/feature-technical-design-sprint-<$SPRINT_N>.md`.

Write `$DRAFT` (overwrite on iteration) with `$TDD_BODY`, then append a `## Technical Stories` section rendering every spec in `$TECHNICAL_STORIES`.

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>` — TDD for Sprint $SPRINT_N + technical stories. Choose:
>
> - **Approve** — write the TDD issue.
> - **Adjust** — describe what to change; re-run **Author TDD** with the appended feedback; rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`, append to `$FEEDBACK`, re-run **Author TDD**, overwrite `$DRAFT`, re-prompt.
- **Cancel** — halt.
- **Approve** — proceed to **Write TDD Issue**.

## Write TDD Issue

Via the `github` skill, create an issue:

- Title: `Sprint $SPRINT_N — Technical Design Document`.
- Body: `$TDD_BODY` rendered from the `issue-technical-design` template via the `github-templates` skill, with `Part of #$REQUIREMENT.issue_number` at the very top.
- Labels: none (identified by title).
- Milestone: `$MILESTONE_ID`.
- Hold the issue number as `$TDD_ISSUE_NUMBER`.

## Persist Technical Stories

Via the `github` skill, for each spec in `$TECHNICAL_STORIES`:

1. Create an issue titled `spec.title` (begins with `[Tech]`), label `user-story`, milestone `$MILESTONE_ID`, body rendered from the `issue-technical-story` template via the `github-templates` skill with `{scope_summary, acceptance_criteria, notes, tdd_issue: $TDD_ISSUE_NUMBER}`.

After all `[Tech]` issues exist, back-fill cross-references:

- Resolve `spec.required_by_titles` → `[Story]` `#id`s in the sprint milestone; write `Required by:` into each `[Tech]` body.
- Resolve `spec.notes.depends_on_titles` → `[Tech]` `#id`s; write `Depends on:` and `Blocks:` into each `[Tech]` body.
- For each `[Story]` referenced by any `[Tech]`, append `Depends on: #<tech-issue>` to its Notes.

Delete `$DRAFT` via `Bash: rm`. The GitHub issues are the source of truth.

## Next Step

TDD filed. Print the next command:

- `/feature:implement <story_issue>` — implement each story (repeat per story)
