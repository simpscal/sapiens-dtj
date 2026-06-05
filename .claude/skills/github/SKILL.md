---
name: github
description: Use for GitHub issue operations — create/read/update/close issues, post/update comments, manage labels and milestones, load sprint context, and post completion notifications (implementation, refactor, revert). Confirms before mutating ops. Do NOT use for PR operations (use `git` skill), issue body authoring from scratch (caller provides content), or cross-repo issue linking.
tools: Bash
---

## Repo Derivation

Derive at runtime, never hardcode; hold for the session. Run from the relevant repo root — orchestration repo for issues/milestones/stories/TDD/design, codebase directory (path from the Codebases table) for PRs/branches:

```bash
gh repo view --json owner,name --jq '[.owner.login,.name]|join("/")'
```

## Confirmation Protocol

Before any mutating op: summarise all planned mutations in one block, ask once `"Proceed? (y/n)"`, proceed only if confirmed.

- **Skip**: read-only ops (read issue, list issues, list milestones).
- **Always confirm**: create issue, create milestone, update issue body, update labels, post comment, close issue, update comment.

## Operations

### Link Reference
Format: `#id` (e.g. `#17`) — use in issue bodies and comments.

### Fetch Issue
- `gh issue view {id} --repo {owner}/{repo} --json title,body,labels,milestone,comments`

### List Issues
- `gh issue list --repo {owner}/{repo} --milestone "{milestone_title}" --label {label} --state open --json number,title,labels,assignees` — repeat `--label` for AND.

### Create Issue
- `gh issue create --repo {owner}/{repo} --title "{title}" --body "{body}" --label {label} --milestone "{milestone_title}"` — returns new issue URL.

### Update Issue Body
- Read the issue first (Fetch Issue), modify, then write.
- `gh issue edit {id} --repo {owner}/{repo} --body "{body}"`

### Update Labels
- `gh issue edit {id} --repo {owner}/{repo} --add-label {add} --remove-label {remove}` — no read needed; omit either flag to skip that side.

### Post Comment
- `gh issue comment {id} --repo {owner}/{repo} --body "{body}"`

### Update Comment
- `gh api repos/{owner}/{repo}/issues/comments/{comment_id} --method PATCH -f body="{body}"`

### Create Milestone
- `gh api repos/{owner}/{repo}/milestones --method POST -f title="{title}" -f description="{description}"` — returns milestone id.

### List Milestones
- `gh api repos/{owner}/{repo}/milestones --jq '.[].title'`

### List Milestones Detail
- `gh api repos/{owner}/{repo}/milestones --jq '[.[] | {number: .number, title: .title, open_issues: .open_issues}]'`

### Resolve Sprint Milestone
- List milestones, find the one titled `Sprint N`, hold its GitHub ID as `$MILESTONE_ID`.
- Not found → list available titles and stop: `⛔ No milestone found titled "Sprint N". Available: <titles>`.

### Load Sprint Snapshot
Resolve Sprint Milestone, list all **open** issues in it once (closed issues are out of sprint scope), then partition in memory and read all present partitions in parallel:

- **$STORIES** — open issues labelled `user-story`. Read each in full.
- **$REQUIREMENT** — single open issue labelled `requirement`. May be absent.
- **$TDD** — single open issue whose title contains `Technical Design Document`. Read in full. May be absent.
- **$DESIGN** — the design hub comment on `$REQUIREMENT` (comment body starting `## Design Navigation`), whose Surfaces table links each surface's Storybook story file. Resolve by reading `$REQUIREMENT`'s comments — design is a comment, never a labelled issue. May be absent. Callers read the linked story files for the surfaces they need.

### List Open Issues
- `gh issue list --repo {owner}/{repo} --state open --label {label} --json number,title,labels`

### Close Issue
- `gh issue close {id} --repo {owner}/{repo}`

### Notify Implementation Complete

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

#### Step 2 — Update labels

Apply via **Update Labels**:

| Mode | Add | Remove |
|------|-----|--------|
| implementation | `implemented` | `in-progress` |
| refactor | `implemented` | `in-progress` |

#### Step 3 — Confirm

Output a single line listing the PR URL(s) for the orchestrator's summary.
