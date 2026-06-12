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

Via `github` skill, load Sprint Snapshot for Sprint $SPRINT_N → `$STORIES`, `$REQUIREMENT`, `$TDD`, `$DESIGN`.

Exclude `[Revert]`-prefixed issues from `$STORIES`.

`$DESIGN` present → read the Storybook story files its Surfaces table links (full surface set) → design context for the TDD author.

`$TDD` present → halt `⛔ A TDD already exists for Sprint $SPRINT_N — run /feature:technical-design:regenerate to revise it.`

Resolve every codebase → `$AVAILABLE_CODEBASES` (each: name, role ∈ `{backend, frontend, infrastructure}`, path).

## Author TDD

Init `$FEEDBACK` empty. Via `technical-design` skill, spawn a subagent to author the TDD. Pass:

- sprint goal (from `$REQUIREMENT`)
- all `$STORIES` (id, title, user_story, acceptance_criteria, notes)
- requirement body
- design context (if present)
- `$AVAILABLE_CODEBASES`
- `$FEEDBACK` (iteration passes only)

Subagent: resolves in-scope codebases → probes each in parallel → resolves blocking questions → designs all canonical sections → decomposes technical stories.

Hold `$TDD_BODY` + `$TECHNICAL_STORIES`.

## Draft + Approve Loop

`$DRAFT = .claude/state/feature-technical-design-sprint-<$SPRINT_N>.md` → write `$TDD_BODY`, then append `## Technical Stories` rendering every spec in `$TECHNICAL_STORIES`.

`AskUserQuestion`:

> Draft `<$DRAFT>` — TDD for Sprint $SPRINT_N + technical stories:
> - **Approve** → write the TDD issue
> - **Adjust** → describe change → re-run **Author TDD** → rewrite draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → append to `$FEEDBACK` → re-run **Author TDD** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Write TDD Issue**

## Write TDD Issue

Via `github` skill, create issue:

- Title: `Sprint $SPRINT_N — Technical Design Document`.
- Body: `$TDD_BODY` from `issue-technical-design` template (via `github-templates` skill), with `Part of #$REQUIREMENT.issue_number` at the very top.
- Labels: none (identified by title).
- Hold issue number → `$TDD_ISSUE_NUMBER`.
- **Register Issue on Board** — Type `Feature`, Status `Todo`, Sprint `Sprint $SPRINT_N`.

## Persist Technical Stories

Via `github` skill, per spec in `$TECHNICAL_STORIES`:

1. Create issue `spec.title` (begins `[Tech]`), label `user-story`, body from `issue-technical-story` template (via `github-templates` skill) with `{scope_summary, acceptance_criteria, notes, tdd_issue: $TDD_ISSUE_NUMBER}` → **Register Issue on Board** (Type `Feature`, Status `Todo`, Sprint `Sprint $SPRINT_N`).

After all `[Tech]` issues exist → back-fill cross-references:

- `spec.required_by_titles` → `[Story]` `#id`s in the sprint → write `Required by:` into each `[Tech]` body.
- `spec.notes.depends_on_titles` → `[Tech]` `#id`s → write `Depends on:` + `Blocks:` into each `[Tech]` body.
- Per `[Story]` referenced by any `[Tech]` → append `Depends on: #<tech-issue>` to its Notes.

Delete `$DRAFT` via `Bash: rm`. GitHub issues are the source of truth.

## Next Step

TDD filed. Next:

- `/feature implement each story`