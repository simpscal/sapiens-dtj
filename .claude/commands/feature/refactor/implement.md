---
name: feature:refactor:implement
description: Implement one in-sprint refactor on the sprint branch. Detects Fresh / Revisit from existing PRs, manages branches, dispatches agents, commits, opens PRs, and posts notification.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Refactor — Implement

Implement **one refactor per invocation** — do not batch.

`$ARGUMENTS` carries `<refactor_issue> [free-form intent]`. Leading token = `refactor_issue`; remaining text = `$PHASE_INTENT` (optional).

## Workflow
1. Resume Check
2. Fetch Refactor Issue
3. Branch Prep
4. Classify Change Origin (Revisit only)
5. Dispatch Agents
6. Commit and Push
7. Open PR
8. Notify
9. Next Step

## Resume Check

Look up resume state (`workflow = feature`, `run_key = refactor-implement-<refactor_issue>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Fetch Refactor Issue**.
- **Cancel** → abort; leave state untouched.

## Fetch Refactor Issue

Via `github` skill, fetch the issue in full (title, body, labels). Missing `refactoring` label → halt `⛔ Issue #<N> does not have the refactoring label. This mode is for refactoring tasks only.`

Resolve `$SPRINT_N` from board Sprint (`Sprint N`). No board Sprint → halt `⛔ Dev refactor #<N> has no board Sprint. Assign it to the active sprint on the board first, or use /refactor for a standalone refactor.`

Set board Status `In Progress` → assign current user (**Assign Issue**).

Extract from body → `$ISSUE_PLAN`: Problem Statement, Scope, Technical Approach, Affected Codebases, Definition of Done.

## Branch Prep

Resolve codebases from `$ISSUE_PLAN`'s Affected Codebases → `$CODEBASES`.

Via `git` skill, per codebase → list open PRs scoped to this issue with `branch_kind = refactor`:

- **Open PR found** → **Revisit**. Check out the existing PR branch.
- **No open PR** → **Fresh**. Create a refactor branch from the sprint branch.

## Classify Change Origin

Revisit only. Ask via `AskUserQuestion` → `$CHANGE_ORIGIN`:

- **Upstream update** — the refactor spec changed. Build `delta` by diffing the PR branch against current spec decisions.
- **Phase intent** — run driven by a direct instruction. Use `$PHASE_INTENT` as dispatch directive, scope `delta` to it. Absent → ask in the same prompt.

## Dispatch Agents

Via `dispatch-agents` skill, dispatch backend/frontend/devops agents with:

| Parameter | Value |
|---|---|
| `issue` | `{number, title, body}` of `#refactor_issue` |
| `codebases` | `$CODEBASES` |
| `agents` | `from-codebases-field` (resolved from Affected Codebases) |
| `decisions` | `type="spec"` with Problem, Scope, Technical Approach, Definition of Done verbatim |
| `delta` | Revisit only: `{satisfied, to_add, to_remove, to_rewrite, affected_files}`. `$CHANGE_ORIGIN = upstream` → compare PR branch state against current spec decisions. `$CHANGE_ORIGIN = phase` → derive from `$PHASE_INTENT` |

Receive `$AGENT_RESULTS`.

## Commit and Push

Via `git` skill, per codebase with `files_changed` in `$AGENT_RESULTS` → commit `refactor(#<N>): <description>` → push. `<description>`:

- Fresh → imperative summary of the refactor work.
- Revisit, `$CHANGE_ORIGIN = upstream` → `re-align with refactor spec`.
- Revisit, `$CHANGE_ORIGIN = phase` → imperative summary of `$PHASE_INTENT`.

## Open PR

**Fresh:** via `git` skill, per codebase that produced work → open a PR:

- Base: sprint branch.
- Title: `refactor(#<N>): <short description>`.
- Body: `pr-refactor` template via `github-templates` skill.

**Revisit:** no PR action — new commits appear on the existing PR.

## Notify

Via `github` skill, run **Notify Implementation Complete** on `#refactor_issue`:

- mode = `refactor`.
- variant = single-PR when exactly one PR, else multi-PR (one bullet per codebase).
- Fresh → post a new completion comment. Revisit → update the existing one with current PR link(s).
- Board: Status → `Implemented`.

## Next Step

In-sprint refactor implemented on the sprint branch. Next:

- `/feature merge the refactor into the sprint`