---
name: github
description: Use for GitHub issue and project-board operations — create/read/update/close issues, post/update comments, manage labels, drive the project board (status, type, sprint, drafts), load sprint context, and post completion notifications (implementation, refactor, revert). Confirms before mutating ops. Do NOT use for PR operations (use `git` skill), issue body authoring from scratch (caller provides content), or cross-repo issue linking.
tools: Bash
---

## Repo Derivation

Derive at runtime, never hardcode; hold for the session. Run from the relevant repo root — orchestration repo for issues/board/stories/TDD/design, codebase directory (path from the Codebases table) for PRs/branches:

```bash
gh repo view --json owner,name --jq '[.owner.login,.name]|join("/")'
```

## Confirmation Protocol

Before any mutating op: summarise all planned mutations in one block, ask once `"Proceed? (y/n)"`, proceed only if confirmed.

- **Skip**: read-only ops (read issue, list issues, board reads — list sprint, list drafts, resolve active sprint).
- **Always confirm**: create issue, update issue body, update labels, post comment, close issue, update comment, board mutations (set status / type / sprint, add issue to board, create draft, delete item).
- **Exception**: board status transitions and self-assignment (Assign Issue) that a command performs as a documented side effect of an already-confirmed mutation (e.g. Notify Implementation Complete) need no second confirmation.

## Operations

### Link Reference
Format: `#id` (e.g. `#17`) — use in issue bodies and comments.

### Fetch Issue
- `gh issue view {id} --repo {owner}/{repo} --json title,body,labels,comments`

### Create Issue
- `gh issue create --repo {owner}/{repo} --title "{title}" --body "{body}" --label {label}` — returns new issue URL.
- Sprint membership and lifecycle state live on the project board, not the issue — after creating, register the issue on the board (see **Project Board**).

### Update Issue Body
- Read the issue first (Fetch Issue), modify, then write.
- `gh issue edit {id} --repo {owner}/{repo} --body "{body}"`

### Update Labels
- `gh issue edit {id} --repo {owner}/{repo} --add-label {add} --remove-label {remove}` — no read needed; omit either flag to skip that side.

### Assign Issue
- `gh issue edit {id} --repo {owner}/{repo} --add-assignee @me` — assigns the authenticated user; `@me` resolves at runtime, never hardcode a login.

### Post Comment
- `gh issue comment {id} --repo {owner}/{repo} --body "{body}"`

### Update Comment
- `gh api repos/{owner}/{repo}/issues/comments/{comment_id} --method PATCH -f body="{body}"`

### List Open Issues
- `gh issue list --repo {owner}/{repo} --state open --label {label} --json number,title,labels`

### Close Issue
- `gh issue close {id} --repo {owner}/{repo}`

## Project Board (Projects v2)

The board is the single tracking surface: the **Status** field replaces lifecycle labels, the **Sprint** single-select field replaces milestones, and **Type** (Feature / Refactor / Bug) classifies items. All board operations go through `.claude/scripts/board.sh`, which resolves the project by title and field/option IDs by name at runtime, caching the resolution in the gitignored `.claude/state/board.json` (refreshed automatically on lookup miss and after sprint-option mutations — never edit or commit it). Requires the `project` token scope; if a call fails on scope, surface `gh auth refresh -s project --hostname github.com`. If no board exists, surface `run /setup:board first`.

Status lifecycle: `Backlog` (captured draft) → `Todo` (issue filed) → `In Progress` (implement start) → `Implemented` (PRs open, awaiting merge) → `Done` (released + closed).

### Resolve Active Sprint
- `bash .claude/scripts/board.sh current-sprint` — prints the highest `Sprint N` option → `$SPRINT_N` from its number.
- Script halts if none: `⛔ No sprint on the board. Run /feature:requirement:create first.`

### Next Sprint Number
- `bash .claude/scripts/board.sh next-sprint-number` — prints max(N)+1.

### Ensure Sprint
- `bash .claude/scripts/board.sh ensure-sprint {N}` — appends the `Sprint N` option if missing. Idempotent.

### Register Issue on Board
After creating an issue, add it and set its fields (Sprint only for sprint-scoped work — stories, TDD, requirement, dev bugs; refactors and production bugs get none):
- `bash .claude/scripts/board.sh add-issue {id}`
- `bash .claude/scripts/board.sh set-type {id} {Feature|Refactor|Bug}`
- `bash .claude/scripts/board.sh set-status {id} Todo`
- `bash .claude/scripts/board.sh set-sprint {id} "Sprint N"` _(sprint-scoped work only)_

### Set Board Status
- `bash .claude/scripts/board.sh set-status {id} {Backlog|Todo|In Progress|Implemented|Done}` — self-healing: adds the issue to the board first if absent.

### List Sprint Items
- `bash .claude/scripts/board.sh list-sprint "Sprint N" [--open-only]` — JSON `[{number, title, labels, status, type, state}]`.

### Create Backlog Draft
- `bash .claude/scripts/board.sh set-draft "{title}" "{body}" {Type}` — draft item, Status=Backlog. Prints item ID.

### List Backlog Drafts
- `bash .claude/scripts/board.sh list-drafts` — JSON `[{id, title, body, type, status}]`.

### Delete Board Item
- `bash .claude/scripts/board.sh delete-item {item-id}` — used after promoting a draft.

### Load Sprint Snapshot
Resolve Active Sprint, run `list-sprint "Sprint N" --open-only` once (closed issues are out of sprint scope), then partition in memory and read all present partitions in parallel:

- **$STORIES** — open issues labelled `user-story`. Read each in full.
- **$REQUIREMENT** — single open issue labelled `requirement`. May be absent.
- **$TDD** — single open issue whose title contains `Technical Design Document`. Read in full. May be absent.
- **$DESIGN** — the design hub comment on `$REQUIREMENT` (comment body starting `## Design Navigation`), whose Surfaces table links each surface's Storybook story file. Resolve by reading `$REQUIREMENT`'s comments — design is a comment, never a labelled issue. May be absent. Callers read the linked story files for the surfaces they need.

## Notify Implementation Complete

Two mandatory mutations on issue `#ISSUE_NUMBER` — run **both**, never stop after the comment.

#### Step 1 — Post or update completion comment

Fetch comments (`gh issue view {id} --repo {owner}/{repo} --json comments`). If one starts with `## Refactor Complete`, `## Implementation Complete`, or `## Revert Ready` → update it via **Update Comment** (do not post new). Else post a new comment via **Post Comment**.

Pick **mode** (refactor / revert / implementation) and **variant** — **Single-PR** (one PR) or **Multi-PR** (one bullet per PR, labelled by codebase name from the Codebases table, e.g. `api`, `web`, `infrastructure` — never hardcode `Backend`/`Frontend`). Substitute every `<pr-url>` with the actual URL.

**Refactor — single-PR:**
```
## Refactor Complete

- PR: <pr-url>

---
> ⏸ Human gate: Review the PR diff. When approved, merge into `main`.
```

**Refactor — multi-PR** (one bullet per codebase):
```
## Refactor Complete

- <codebase-name>: <pr-url>
- <codebase-name>: <pr-url>

---
> ⏸ Human gate: Review all PR diffs. When approved, merge into `main`.
```

**Revert — single-PR:**
```
## Revert Ready

Story #<ISSUE_NUMBER> was removed from scope. Implementation has been reversed.

- Revert PR: <revert-pr-url>

---
> ⏸ Human gate: Review the revert PR diff. When approved, merge into the sprint branch.
```

**Revert — multi-PR:**
```
## Revert Ready

Story #<ISSUE_NUMBER> was removed from scope. Implementation has been reversed across all codebases.

- <codebase-name> revert PR: <revert-pr-url>
- <codebase-name> revert PR: <revert-pr-url>

---
> ⏸ Human gate: Review all revert PR diffs. When approved, merge into the sprint branch.
```

**Implementation — single-PR:**
```
## Implementation Complete

- PR: <pr-url>

---
> ⏸ Human gate: Review the PR diff. When approved, merge into the staging branch.
```

**Implementation — multi-PR:**
```
## Implementation Complete

- <codebase-name>: <pr-url>
- <codebase-name>: <pr-url>

---
> ⏸ Human gate: Review all PR diffs. When approved, merge into the staging branch.
```

#### Step 2 — Update board status

Via **Set Board Status** (implementation and refactor modes; skip for revert):

```bash
bash .claude/scripts/board.sh set-status {ISSUE_NUMBER} Implemented
```

#### Step 3 — Confirm

Output a single line listing the PR URL(s) for the orchestrator's summary.
