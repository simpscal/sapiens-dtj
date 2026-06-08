---
name: bugfix:implement
description: Implement one bug fix (production or development). Detects Fresh / Revisit by scanning for an Implementation Complete comment, manages branches, dispatches agents, commits, opens PRs, and posts notification.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Bugfix Implement

Implement **one bug fix per invocation** — do not batch.

`$ARGUMENTS` carries `<bug_issue_number> [free-form intent]`. The leading token is `bug_issue_number`; any remaining text is `$PHASE_INTENT` (optional).

## Workflow
1. Resume Check
2. Fetch Bug Issue
3. Branch Prep
4. Load Artifacts (development only)
5. Classify Change Origin (Revisit only)
6. Dispatch Agents
7. Commit and Push
8. Open PR
9. Notify
10. Next Step

## Resume Check

Look up resume state (`workflow = bugfix`, `run_key = implement-<bug_issue_number>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Fetch Bug Issue**.
- **Cancel** — abort; leave state untouched.

## Fetch Bug Issue

Via the `github` skill, fetch issue `#bug_issue_number` in full (title, body, labels, comments).

Guard: must have label `bug`. If absent, halt:

> `⛔ Issue #<N> is not a bug (labels: <labels>). Use /feature:implement for stories.`

Derive `$BUG_SOURCE` from the title prefix (match `[Dev Bug]` before `[Bug]`):

- Title starts with `[Dev Bug]` → `$BUG_SOURCE = development`
- Else title starts with `[Bug]` → `$BUG_SOURCE = production`

If `$BUG_SOURCE = development`: resolve `$SPRINT_N` from the issue's board Sprint value (`Sprint N`). If no board Sprint, halt:

> `⛔ Dev bug #<N> has no board Sprint. Assign it to the active sprint on the board first.`

Set board Status to `In Progress` and assign the current user to the issue (**Assign Issue**).

Detect mode by scanning comments for an implementation-complete notification:

- Comment found → **Revisit**. Parse PR links from the comment body → `$IMPL_PRS`. Confirm each PR is still open → `$OPEN_PRS`.
- No such comment → **Fresh**.

## Branch Prep

Resolve every codebase the project exposes → `$CODEBASES`.

**Fresh:** via the `git` skill, for each codebase create a bugfix branch for issue `<N>`.

**Revisit:** via the `git` skill, for each entry in `$OPEN_PRS` check out the existing PR branch.

## Load Artifacts

Development only. Production → skip; leave `$TDD_ISSUE` and `$DESIGN` unset.

If `$BUG_SOURCE = development`, via the `github` skill **Load Sprint Snapshot** for `$SPRINT_N` → `$TDD`, `$DESIGN`.

- If `$TDD` present, read its body in full → `$TDD_ISSUE`.
- Hold `$DESIGN` (the design hub comment) for surface matching at **Dispatch Agents**.

## Classify Change Origin

Revisit only. Ask via `AskUserQuestion`, hold the answer as `$CHANGE_ORIGIN`:

- **Upstream update** — the ACs changed. Build the `delta` against the updated ACs.
- **Phase intent** — this run is driven by a direct instruction. Use `$PHASE_INTENT` as the dispatch directive and scope the `delta` to it. If `$PHASE_INTENT` is absent, ask for it in the same prompt.

## Dispatch Agents

When `$DESIGN` is present (development bugs), read the Storybook story files linked from its **Surfaces** table → `$DESIGN_CONTEXT`. Otherwise leave `$DESIGN_CONTEXT` unset.

Via the `dispatch-agents` skill, always dispatch all three domains (`frontend`, `backend`, `devops`) with:

| Parameter | Value |
|---|---|
| `issue` | `{number, title, body}` of `#bug_issue_number` — agents derive root cause and scope from the issue themselves |
| `codebases` | `$CODEBASES` |
| `agents` | `frontend`, `backend`, `devops` |
| `design_context` | `$DESIGN_CONTEXT` (if loaded) |
| `delta` | Revisit only: `{satisfied, to_add, to_remove, to_rewrite, affected_files}`. `$CHANGE_ORIGIN = upstream` → compare open PR branch state against current ACs. `$CHANGE_ORIGIN = phase` → derive the delta from `$PHASE_INTENT` |

Receive `$AGENT_RESULTS`.

## Commit and Push

Via the `git` skill, for each codebase with `files_changed` in `$AGENT_RESULTS`:

- Commit: `fix(#<N>): <description>` and push. Derive `<description>`:
  - Fresh → imperative-tense fix summary.
  - Revisit, `$CHANGE_ORIGIN = upstream` → `revise bug fix per updated ACs`.
  - Revisit, `$CHANGE_ORIGIN = phase` → imperative summary of `$PHASE_INTENT`.

## Open PR

**Fresh:** via the `git` skill, for each codebase that produced work open a PR:

- Base: sprint branch.
- Title: `fix(#<N>): <short description>`.
- Body: render the `pr-bug` template via the `github-templates` skill.

**Revisit:** no PR action — new commits appear on the existing PR.

## Notify

Via the `github` skill, run **Notify Implementation Complete** on `#bug_issue_number`:

- mode = `implementation`.
- variant = single-PR when exactly one PR exists, else multi-PR (one bullet per codebase).
- Fresh → posts a new completion comment. Revisit → updates the existing completion comment with the current PR link(s).
- Board: Status → `Implemented`.

## Next Step

Bug fix implemented. Print the next command:

- `/bugfix:pre-release <bug_issue>` — readiness gate
