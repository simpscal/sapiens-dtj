---
name: feature:bugfix:implement
description: Implement one in-sprint bug fix on the sprint branch. Detects Fresh / Revisit via Implementation Complete comment, manages branches, loads sprint artifacts, investigates root cause (draft + approve gate), dispatches agents, commits, opens PRs, posts notification.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Bugfix — Implement

Implement **one bug fix per invocation** — do not batch.

`$ARGUMENTS` = `<bug_issue_number> [free-form intent]`. First token → `bug_issue_number`; rest → `$PHASE_INTENT` (optional).

## Workflow
1. Resume Check
2. Fetch Bug Issue
3. Branch Prep
4. Load Artifacts
5. Classify Change Origin (Revisit only)
6. Investigate Root Cause
7. Dispatch Agents
8. Commit and Push
9. Open PR
10. Notify
11. Next Step

## Resume Check

Resume state (`workflow = feature`, `run_key = bugfix-implement-<bug_issue_number>`) exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Fetch Bug Issue**.
- **Cancel** → abort; leave state untouched.

## Fetch Bug Issue

`github` skill → fetch `#bug_issue_number` in full (title, body, labels, comments).

- Missing `bug` label → halt `⛔ Issue #<N> is not a bug (labels: <labels>). Use /feature:implement for stories.`

Resolve `$SPRINT_N` from board Sprint (`Sprint N`). None → halt `⛔ Dev bug #<N> has no board Sprint. Assign it to the active sprint on the board first, or use /bugfix for a production bug.`

Set board Status `In Progress` → assign current user (**Assign Issue**).

Detect mode — scan comments for implementation-complete notification:

- Comment found → **Revisit**. Parse PR links → `$IMPL_PRS` → confirm each still open → `$OPEN_PRS`.
- No comment → **Fresh**.

## Branch Prep

Resolve every codebase → `$CODEBASES`.

- **Fresh** → `git` skill, per codebase → branch off the sprint branch for issue `<N>`.
- **Revisit** → `git` skill, per `$OPEN_PRS` → check out existing PR branch.

## Load Artifacts

`github` skill → **Load Sprint Snapshot** for `$SPRINT_N` → `$TDD`, `$DESIGN`.

- `$TDD` present → read body in full → `$TDD_ISSUE`.
- Hold `$DESIGN` (design hub comment) for surface matching at **Dispatch Agents**.

## Classify Change Origin

Revisit only. Ask via `AskUserQuestion` → `$CHANGE_ORIGIN`:

- **Upstream update** — ACs changed → build `delta` against updated ACs.
- **Phase intent** — direct instruction → use `$PHASE_INTENT` as dispatch directive, scope `delta` to it. Absent → ask in same prompt.

## Investigate Root Cause

Establish *why* the bug occurs before any fix agent runs. Both branches leave `$INVESTIGATION_DECISIONS` set.

**Fresh:**

- **Explore** — on the **Branch Prep** branch, spawn one `Explore` subagent per in-scope codebase **in parallel** to surface code paths behind the reported behaviour. Feed each: issue title + body, verbatim Acceptance Criteria, relevant `$TDD_ISSUE` slice (if loaded). Each returns → implicated code paths + observed mechanism.
- **Draft** — synthesise findings → investigation fields: Complexity, Root Cause (plain-English *why*, no file paths), Scope (product area), Fix Approach (`[domain]` tags + imperative bullets), Risk. `github-templates` skill → `comment-dev-investigation` → `$INVESTIGATION`.
- **Approve gate** — ask via `AskUserQuestion`:
  - **Approve** → proceed.
  - **Revise** → fold feedback, redraft (re-spawn `Explore` if scope shifted), re-gate.
  - **Reject** → abort; leave branch + board Status as set in **Fetch Bug Issue**.
- **Post** — approved → `github` skill **Post Comment** → post `$INVESTIGATION` on `#bug_issue_number`. Hold fields → `$INVESTIGATION_DECISIONS`.

**Revisit:**

- **Load prior** — find the prior investigation comment on `#bug_issue_number` (the `comment-dev-investigation` render from the Fresh run) → prior fields.
- **Revise / Keep gate** — ask via `AskUserQuestion`, framed by `$CHANGE_ORIGIN` / `delta`:
  - **Keep** → root cause unchanged → carry prior fields → `$INVESTIGATION_DECISIONS`. No re-explore, no comment change.
  - **Revise** → re-spawn `Explore` per in-scope codebase **in parallel**, scoped to `delta` / `$PHASE_INTENT` (still passing `$TDD_ISSUE` slice if loaded), diffed **vs sprint branch** (pre-fix state, never branch commits) → **redraft** investigation fields, *replacing* prior (no change-narration, no stale decisions), **grounded in original root cause** (bug as on sprint branch, not post-fix branch) → `github-templates` skill → `comment-dev-investigation` → `$INVESTIGATION` → **Approve gate** (Approve / Revise / Reject). Approved → `github` skill **update existing investigation comment in place** (not new). Hold fields → `$INVESTIGATION_DECISIONS`.

## Dispatch Agents

`$DESIGN` present → read Storybook story files linked from its **Surfaces** table → `$DESIGN_CONTEXT`. Else unset.

`dispatch-agents` skill → dispatch fix agents:

| Parameter | Value |
|---|---|
| `issue` | `{number, title, body}` of `#bug_issue_number` |
| `codebases` | `$CODEBASES` |
| `agents` | Domains named in investigation Fix Approach (fallback `frontend`, `backend`, `devops` if ambiguous) |
| `decisions` | `type="investigation"` with Root Cause, Scope, Fix Approach, Risk verbatim (`$INVESTIGATION_DECISIONS`) — Fresh draft or Revisit revised-or-kept |
| `tdd_issue` | `$TDD_ISSUE` (if loaded) |
| `design_context` | `$DESIGN_CONTEXT` (if loaded) |
| `delta` | Revisit only: `{satisfied, to_add, to_remove, to_rewrite, affected_files}` **vs sprint branch** (pre-fix state, never branch commits) → applied fix → `satisfied` (preserve); rest → `to_add` / `to_remove` / `to_rewrite`. `$CHANGE_ORIGIN = upstream` → vs current ACs. `$CHANGE_ORIGIN = phase` → from `$PHASE_INTENT` |

Receive `$AGENT_RESULTS`.

## Commit and Push

`git` skill, per codebase with `files_changed` in `$AGENT_RESULTS` → commit `fix(#<N>): <description>` → push. `<description>`:

- Fresh → imperative-tense fix summary.
- Revisit, `$CHANGE_ORIGIN = upstream` → `revise bug fix per updated ACs`.
- Revisit, `$CHANGE_ORIGIN = phase` → imperative summary of `$PHASE_INTENT`.

## Open PR

**Fresh** → `git` skill, per codebase that produced work → open PR:

- Base: sprint branch.
- Title: `fix(#<N>): <short description>`.
- Body: `pr-bug` template via `github-templates` skill.

**Revisit** → no PR action; new commits land on existing PR.

## Notify

`github` skill → **Notify Implementation Complete** on `#bug_issue_number`:

- mode = `implementation`.
- variant = single-PR when exactly one PR, else multi-PR (one bullet per codebase).
- Fresh → post new completion comment. Revisit → update existing one with current PR link(s).
- Board: Status → `Implemented`.

## Next Step

Dev bug fix implemented on the sprint branch. Next:

- `/feature merge the fix into the sprint`
