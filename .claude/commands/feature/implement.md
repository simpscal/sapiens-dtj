---
name: feature:implement
description: Implement one feature user-story or technical-story. Detects Fresh / Revisit by scanning for an Implementation Complete comment, manages branches, dispatches agents, commits, opens PRs, and posts notification.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Implement

Implement **one story per invocation** — do not batch.

Parse `$ARGUMENTS`: leading token is `story_issue_number`; remaining text is `$PHASE_INTENT` (optional).

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

Look up resume state (`workflow = feature`, `run_key = implement-<story_issue_number>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Fetch Story**.
- **Cancel** — abort; leave state untouched.

## Fetch Story

Via the `github` skill, fetch issue `#story_issue_number` in full (title, body, labels, comments). Hold `$SPRINT_N` from the issue's board Sprint value (`Sprint N`). Reject if missing `user-story` label: `⚠️ Issue #<N> is not a story (labels: <labels>).` Set board Status to `In Progress` and assign the current user to the issue (**Assign Issue**).

Validate the title prefix — it must begin with `[Story]` or `[Tech]`. Otherwise halt: `⚠️ Issue #<N> title "<title>" must begin with [Story] or [Tech].`

Detect mode by scanning comments for an implementation-complete notification:

- Comment found → **Revisit**. Parse PR links from the comment body → `$IMPL_PRS`.
- No such comment → **Fresh**.

## Branch Prep

Resolve every codebase the project exposes → `$CODEBASES`.

**Fresh:** via the `git` skill, for each codebase create a story branch for issue `<N>` from the sprint branch and push. Check out.

**Revisit:** via the `git` skill, for each entry in `$IMPL_PRS` check PR state:

- **Open PR** → check out the existing PR branch.
- **Merged PR** → create a new story branch from the sprint branch and push. Hold the merged PR's commit list for delta comparison.

## Load Artifacts

Via the `github` skill, load Sprint Snapshot for the sprint → `$TDD`, `$DESIGN`.

If `$TDD` present, read its body in full → `$TDD_ISSUE`.

If `$DESIGN` present, from its **Surfaces** table pick the rows whose surfaces this story touches and read their linked Storybook story files → `$DESIGN_CONTEXT`. If `$DESIGN` is absent or no surface applies, leave `$DESIGN_CONTEXT` unset.

## Classify Change Origin

Revisit only. Ask via `AskUserQuestion`, hold the answer as `$CHANGE_ORIGIN`:

- **Upstream update** — an artifact changed (ACs, design context, or TDD). Build the `delta` by diffing the PR branch against the current artifacts.
- **Phase intent** — this run is driven by a direct instruction. Use `$PHASE_INTENT` as the dispatch directive and scope the `delta` to it. If `$PHASE_INTENT` is absent, ask for it in the same prompt.

## Dispatch Agents

Via the `dispatch-agents` skill, dispatch backend/frontend/devops agents with:

| Parameter | Value |
|---|---|
| `issue` | `{number, title, body}` of `#story_issue_number` |
| `codebases` | `$CODEBASES` |
| `agents` | `all` |
| `tdd_issue` | `$TDD_ISSUE` (if loaded) |
| `design_context` | `$DESIGN_CONTEXT` (if loaded) |
| `delta` | Revisit only: `{satisfied, to_add, to_remove, to_rewrite, affected_files}`. `$CHANGE_ORIGIN = upstream` → compare the PR branch state (open PR) or merged commit changes (merged PR) against current ACs, design context, and TDD. `$CHANGE_ORIGIN = phase` → derive the delta from `$PHASE_INTENT` |

Receive `$AGENT_RESULTS`.

## Commit and Push

Via the `git` skill, for each codebase with `files_changed` in `$AGENT_RESULTS`:

Commit: `feat(#<N>): <description>` (`[Story]` title) or `chore(#<N>): <description>` (`[Tech]` title) and push. Derive `<description>`:

- Fresh → imperative summary of the implemented work.
- Revisit, `$CHANGE_ORIGIN = upstream` → `update <short description> per story change`.
- Revisit, `$CHANGE_ORIGIN = phase` → imperative summary of `$PHASE_INTENT`.

## Open PR

Via the `git` skill, for each codebase that produced work open a PR:

- Base: sprint branch.
- Title: `feat(#<N>): <short description>` (`[Story]`) or `chore(#<N>): <short description>` (`[Tech]`).
- Body: render the `pr-story` template via the `github-templates` skill.

**Revisit (open PR):** no PR action — new commits appear on the existing PR.

## Notify

Via the `github` skill, run **Notify Implementation Complete** on `#story_issue_number`:

- mode = `implementation`.
- variant = single-PR when exactly one PR exists, else multi-PR (one bullet per codebase).
- Fresh → posts a new completion comment. Revisit → updates the existing completion comment with the current PR link(s).
- Board: Status → `Implemented`.

## Next Step

Story implemented. Print the next command:

- `/feature:implement <next_story_issue>` — implement the next open story
- `/feature:pre-release <sprint_number>` — once every story is merged
