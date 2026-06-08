---
name: git
description: Use for git and GitHub PR operations — creating branches (sprint, story, bug, revert, refactor), checkout, commit, push, and PR create/read/list/review/delete. Confirms before mutating ops. Pairs with `github-templates` (PR/comment body content) and `dispatch-agents` (typical upstream that hands off file changes to commit). Do NOT use for resolving merge conflicts, rebasing history, writing commit messages from scratch, or issue-tracker operations (use `github` skill).
tools: Bash
---

# Git and PR Operations

**Prerequisites:** `gh` CLI installed and authenticated. On `gh: command not found` or auth errors, stop and surface — no workarounds.

Resolve the repo per Repo Derivation; different codebases resolve independently. Run the Confirmation Protocol before mutating ops. Multi-codebase ops run per codebase, then aggregate into one report.

## Operation Index

| Request shape | Section |
|---------------|---------|
| Create branch (any kind) | Create Branch |
| Checkout / switch / go to branch | Checkout |
| Branch exists check | Check Branch Exists |
| Commit and push | Commit and Push |
| Delete branch / clean up | Delete Branch |
| Delete all story branches | Delete All Story Branches |
| Create / open / raise PR | Create PR |
| Show / view / read PR | Fetch PR |
| List PRs | List PRs |
| Approve / LGTM / request changes / review | Submit Review |
| Merge / squash / land PR | Merge PR |
| Diff / compare branches | Diff Branch Files |

## Placeholders

- `{N}` — issue number (`#42` → `42`). In `feature/sprint-{N}`, the sprint number.
- `{short-description}` — derived per Branch Naming.
- `{branch}` / `{branch_name}` — full branch name from the caller or context.
- `{message}` — commit message, **provided by the caller**.
- `{files}` — file paths to stage, provided by the caller.
- `{body}` — PR or review body, rendered via the `github-templates` skill.

## Repo Derivation

`owner`/`repo` derived at runtime, never hardcoded. Run from inside the codebase directory (path from the Codebases table, never `cwd`); derive once per codebase and cache.

```bash
gh repo view --json owner,name --jq '[.owner.login,.name]|join("/")'
```

## Confirmation Protocol

Before any mutating op: summarise all planned mutations in one block, ask once `"Proceed? (y/n)"`, proceed only if confirmed.

| Class | Confirmation |
|-------|--------------|
| Read-only (list, fetch, check exists, diff) | Skip |
| Create branch, checkout, commit, push, create PR, submit review | Standard |
| Delete branch, delete all story branches, force push | **Always**, even within a larger flow |

## Branch Naming

| Context | Pattern | Base branch |
|---------|---------|-------------|
| Sprint | `feature/sprint-{N}` | `main` |
| Story | `feature/issue-{N}-{short-description}` | `feature/sprint-{N}` |
| Bug (production) | `fix/issue-{N}-{short-description}` | `main` |
| Bug (development) | `fix/issue-{N}-{short-description}` | `feature/sprint-{N}` |
| Revert | `revert/issue-{N}-{short-description}` | `main` |
| Refactor | `refactor/issue-{N}-{short-description}` | `main` |

**Production vs. development bug** (when unspecified): board Sprint value set → development, branch from the sprint branch. No board Sprint → production, branch from `main`. Ambiguous → ask.

**`short-description` derivation:**

1. Strip leading `[Tag]` prefix (e.g. `[Story]`, `[Bug]`).
2. Lowercase; replace spaces and special chars with hyphens.
3. Remove stop words: `a`, `an`, `the`, `and`, `or`, `for`, `to`, `of`, `in`, `on`, `at`, `by`, `with`, `when`, `then`.
4. Keep first 4 remaining words; trim trailing hyphens.

**Collision:** if the derived name exists on remote (check via Check Branch Exists), append `-2`, `-3`, etc. until unique.

## Operations

### Create Branch

```bash
git checkout {base_branch} && git pull
git checkout -b {new_branch}
git push -u origin {new_branch}
```

Story branches: confirm the sprint branch exists first via Check Branch Exists; if not, stop and surface — never auto-create it. Run the collision check before creating.

### Checkout

```bash
git checkout {branch_name}
git pull
```

"Checkout sprint branch" → `feature/sprint-{N}` for the current sprint.

### Check Branch Exists

`git ls-remote --exit-code --heads origin {branch_name}` — exit 0 = exists (`true`), exit 2 = not found (`false`).

### Commit and Push

```bash
git add {files}
git commit -m "{message}"
git push origin {branch_name}
```

`{message}` is caller-provided. If asked to author it, stop and surface: "Commit message authoring is out of scope — provide a message or use a commit-message skill."

### Delete Branch

```bash
git push origin --delete {branch}
```

`remote ref does not exist` → treat as success, skip silently. Any other error surfaces.

### Delete All Story Branches

- `gh api --paginate repos/{owner}/{repo}/branches --jq '.[].name'`
- Filter for `feature/issue-{N}-*`, `fix/issue-{N}-*`, or `revert/issue-{N}-*`.
- Confirm the full delete list, then delete each via `git push origin --delete {branch}` (skip silently on "remote ref does not exist").
- Report: count deleted, count skipped, failures.

### Create PR

- `gh pr create --repo {owner}/{repo} --title "{title}" --body "{body}" --head {head} --base {base}` — returns PR URL.
- `body` rendered via `github-templates` (e.g. `pr-story`, `pr-bug`) — never freeform.
- Resolve the number from the URL or `gh pr view {url} --json number,url`. Report both number and URL.

### Fetch PR

- `gh pr view {id} --repo {owner}/{repo} --json title,body,headRefName,baseRefName,files,merged,closingIssuesReferences`
- Also `gh pr diff {id}` for file list and diff content.

### List PRs

- `gh pr list --repo {owner}/{repo} --state {state} --json number,title,url,headRefName,state,merged`
- `state`: `open` | `closed` | `merged` | `all`. "Merged only" → `--state merged`.

### Submit Review

- Approve: `gh pr review {pr_id} --approve --body "{body}"`
- Request changes: `gh pr review {pr_id} --request-changes --body "{body}"`
- `{body}` for structured reviews rendered via `github-templates`.

### Merge PR

- `gh pr merge {pr_id} --repo {owner}/{repo} --squash`

### Diff Branch Files

- `gh api repos/{owner}/{repo}/compare/{base}...{head} --jq '[.files[].filename]'` — array of changed file paths.

## Multi-codebase Operations

Resolve owner/repo per codebase, build the full mutation plan across all, run the Confirmation Protocol once with the combined list, execute per codebase sequentially (parallel pushes can race), then aggregate per-codebase success/skip/error into one summary.

## Constraints

- Never hardcode `owner`/`repo` — always derive via `gh repo view` from the codebase directory.
- Never write commit message content — the caller provides `{message}`.
- Never write PR or review body content from scratch — render via `github-templates`.
- Never auto-create missing base branches — stop and surface.
- Never run mutating ops without confirmation, even from a higher-level orchestrator.
- Never silently swallow errors other than `remote ref does not exist` on delete.
- Never operate on a codebase whose path isn't in the Codebases table.
- Force pushes require explicit caller request plus confirmation — never inferred.
