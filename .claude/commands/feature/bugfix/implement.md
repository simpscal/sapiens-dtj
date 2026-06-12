---
name: feature:bugfix:implement
description: Implement one in-sprint bug fix on the sprint branch. Detects Fresh / Revisit by scanning for an Implementation Complete comment, manages branches, loads sprint artifacts, dispatches agents, commits, opens PRs, and posts notification.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Bugfix — Implement

Implement **one bug fix per invocation** — do not batch.

`$ARGUMENTS` carries `<bug_issue_number> [free-form intent]`. Leading token = `bug_issue_number`; remaining text = `$PHASE_INTENT` (optional).

## Workflow
1. Resume Check
2. Fetch Bug Issue
3. Branch Prep
4. Load Artifacts
5. Classify Change Origin (Revisit only)
6. Dispatch Agents
7. Commit and Push
8. Open PR
9. Notify
10. Next Step

## Resume Check

Look up resume state (`workflow = feature`, `run_key = bugfix-implement-<bug_issue_number>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Fetch Bug Issue**.
- **Cancel** → abort; leave state untouched.

## Fetch Bug Issue

Via `github` skill, fetch issue `#bug_issue_number` in full (title, body, labels, comments).

- Missing `bug` label → halt `⛔ Issue #<N> is not a bug (labels: <labels>). Use /feature:implement for stories.`

Resolve `$SPRINT_N` from board Sprint (`Sprint N`). No board Sprint → halt `⛔ Dev bug #<N> has no board Sprint. Assign it to the active sprint on the board first, or use /bugfix for a production bug.`

Set board Status `In Progress` → assign current user (**Assign Issue**).

Detect mode — scan comments for an implementation-complete notification:

- Comment found → **Revisit**. Parse PR links → `$IMPL_PRS` → confirm each still open → `$OPEN_PRS`.
- No comment → **Fresh**.

## Branch Prep

Resolve every codebase → `$CODEBASES`.

- **Fresh:** via `git` skill, per codebase → create a bugfix branch for issue `<N>` from the sprint branch.
- **Revisit:** via `git` skill, per `$OPEN_PRS` entry → check out the existing PR branch.

## Load Artifacts

Via `github` skill, **Load Sprint Snapshot** for `$SPRINT_N` → `$TDD`, `$DESIGN`.

- `$TDD` present → read body in full → `$TDD_ISSUE`.
- Hold `$DESIGN` (the design hub comment) for surface matching at **Dispatch Agents**.

## Classify Change Origin

Revisit only. Ask via `AskUserQuestion` → `$CHANGE_ORIGIN`:

- **Upstream update** — the ACs changed. Build `delta` against updated ACs.
- **Phase intent** — run driven by a direct instruction. Use `$PHASE_INTENT` as dispatch directive, scope `delta` to it. Absent → ask in the same prompt.

## Dispatch Agents

`$DESIGN` present → read the Storybook story files linked from its **Surfaces** table → `$DESIGN_CONTEXT`. Else leave unset.

Via `dispatch-agents` skill, always dispatch all three domains (`frontend`, `backend`, `devops`) with:

| Parameter | Value |
|---|---|
| `issue` | `{number, title, body}` of `#bug_issue_number` — agents derive root cause + scope themselves |
| `codebases` | `$CODEBASES` |
| `agents` | `frontend`, `backend`, `devops` |
| `tdd_issue` | `$TDD_ISSUE` (if loaded) |
| `design_context` | `$DESIGN_CONTEXT` (if loaded) |
| `delta` | Revisit only: `{satisfied, to_add, to_remove, to_rewrite, affected_files}`. `$CHANGE_ORIGIN = upstream` → compare open PR branch state against current ACs. `$CHANGE_ORIGIN = phase` → derive from `$PHASE_INTENT` |

Receive `$AGENT_RESULTS`.

## Commit and Push

Via `git` skill, per codebase with `files_changed` in `$AGENT_RESULTS` → commit `fix(#<N>): <description>` → push. `<description>`:

- Fresh → imperative-tense fix summary.
- Revisit, `$CHANGE_ORIGIN = upstream` → `revise bug fix per updated ACs`.
- Revisit, `$CHANGE_ORIGIN = phase` → imperative summary of `$PHASE_INTENT`.

## Open PR

**Fresh:** via `git` skill, per codebase that produced work → open a PR:

- Base: sprint branch.
- Title: `fix(#<N>): <short description>`.
- Body: `pr-bug` template via `github-templates` skill.

**Revisit:** no PR action — new commits appear on the existing PR.

## Notify

Via `github` skill, run **Notify Implementation Complete** on `#bug_issue_number`:

- mode = `implementation`.
- variant = single-PR when exactly one PR, else multi-PR (one bullet per codebase).
- Fresh → post a new completion comment. Revisit → update the existing one with current PR link(s).
- Board: Status → `Implemented`.

## Next Step

Dev bug fix implemented on the sprint branch. Next:

- `/feature merge the fix into the sprint`