---
name: feature:implement
description: Implement one feature user-story or technical-story. Detects Fresh / Revisit by scanning for an Implementation Complete comment, manages branches, dispatches agents, commits, opens PRs, and posts notification.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Implement

Implement **one story per invocation** — do not batch.

Parse `$ARGUMENTS`: leading token = `story_issue_number`; remaining text = `$PHASE_INTENT` (optional).

## Workflow
1. Resume Check
2. Fetch Story
3. Branch Prep
4. Load Artifacts
5. Classify Change Origin (Revisit only)
6. Dispatch Agents
7. Commit and Push
8. Open PR
9. Notify
10. Next Step

## Resume Check

Look up resume state (`workflow = feature`, `run_key = implement-<story_issue_number>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Fetch Story**.
- **Cancel** → abort; leave state untouched.

## Fetch Story

Via `github` skill, fetch issue `#story_issue_number` in full (title, body, labels, comments). Hold `$SPRINT_N` from board Sprint (`Sprint N`).

- Missing `user-story` label → halt `⚠️ Issue #<N> is not a story (labels: <labels>).`
- Title not `[Story]` / `[Tech]` → halt `⚠️ Issue #<N> title "<title>" must begin with [Story] or [Tech].`

Set board Status `In Progress` → assign current user (**Assign Issue**).

Detect mode — scan comments for an implementation-complete notification:

- Comment found → **Revisit**. Parse PR links → `$IMPL_PRS`.
- No comment → **Fresh**.

## Branch Prep

Resolve every codebase → `$CODEBASES`.

- **Fresh:** via `git` skill, per codebase → create a story branch for issue `<N>` from the sprint branch → push → check out.
- **Revisit:** via `git` skill, per `$IMPL_PRS` entry, check PR state:
  - **Open PR** → check out the existing PR branch.
  - **Merged PR** → create a new story branch from the sprint branch → push. Hold the merged PR's commit list for delta comparison.

## Load Artifacts

Via `github` skill, load Sprint Snapshot → `$TDD`, `$DESIGN`.

- `$TDD` present → read body in full → `$TDD_ISSUE`.
- `$DESIGN` present → from its **Surfaces** table, pick rows whose surfaces this story touches → read linked Storybook story files → `$DESIGN_CONTEXT`. Absent or no surface applies → leave `$DESIGN_CONTEXT` unset.

## Classify Change Origin

Revisit only. Ask via `AskUserQuestion` → `$CHANGE_ORIGIN`:

- **Upstream update** — an artifact changed (ACs, design context, or TDD). Build `delta` by diffing the PR branch against current artifacts.
- **Phase intent** — run driven by a direct instruction. Use `$PHASE_INTENT` as dispatch directive, scope `delta` to it. Absent → ask in the same prompt.

## Dispatch Agents

Via `dispatch-agents` skill, dispatch backend/frontend/devops agents with:

| Parameter | Value |
|---|---|
| `issue` | `{number, title, body}` of `#story_issue_number` |
| `codebases` | `$CODEBASES` |
| `agents` | `all` |
| `tdd_issue` | `$TDD_ISSUE` (if loaded) |
| `design_context` | `$DESIGN_CONTEXT` (if loaded) |
| `delta` | Revisit only: `{satisfied, to_add, to_remove, to_rewrite, affected_files}`. `$CHANGE_ORIGIN = upstream` → compare PR branch state (open PR) or merged commit changes (merged PR) against current ACs, design context, TDD. `$CHANGE_ORIGIN = phase` → derive from `$PHASE_INTENT` |

Receive `$AGENT_RESULTS`.

## Commit and Push

Via `git` skill, per codebase with `files_changed` in `$AGENT_RESULTS` → commit `feat(#<N>): <description>` (`[Story]`) or `chore(#<N>): <description>` (`[Tech]`) → push. `<description>`:

- Fresh → imperative summary of the implemented work.
- Revisit, `$CHANGE_ORIGIN = upstream` → `update <short description> per story change`.
- Revisit, `$CHANGE_ORIGIN = phase` → imperative summary of `$PHASE_INTENT`.

## Open PR

Via `git` skill, per codebase that produced work → open a PR:

- Base: sprint branch.
- Title: `feat(#<N>): <short description>` (`[Story]`) or `chore(#<N>): <short description>` (`[Tech]`).
- Body: `pr-story` template via `github-templates` skill.

**Revisit (open PR):** no PR action — new commits appear on the existing PR.

## Notify

Via `github` skill, run **Notify Implementation Complete** on `#story_issue_number`:

- mode = `implementation`.
- variant = single-PR when exactly one PR, else multi-PR (one bullet per codebase).
- Fresh → post a new completion comment. Revisit → update the existing one with current PR link(s).
- Board: Status → `Implemented`.

## Next Step

Story implemented. Next:

- `/feature implement the next story`
- `/feature pre-release the sprint` — once every story is merged