---
name: feature:merge
description: Merge one sprint item's open PRs into the sprint branch — resolve the story, in-sprint bug, or in-sprint refactor, extract its PRs from the Implementation Complete / Refactor Complete / Revert Ready comment, confirm, then squash-merge each.
tools: Read, Bash, AskUserQuestion
---

# Feature Merge

Merge **one sprint item per invocation** — a story, in-sprint bug, or in-sprint refactor. Parse `$ARGUMENTS`: single token = `issue_number`.

## Workflow
1. Fetch Item
2. Extract PRs From Comment
3. Confirm Merge
4. Merge Into Sprint Branch
5. Next Step

## Fetch Item

Via `github` skill, fetch issue `#issue_number` in full (title, labels, comments).

Guards — accept any in-sprint item:

- Label `user-story`, title `[Story]` / `[Tech]` / `[Revert]` → a story.
- Label `bug`, title `[Dev Bug]` → an in-sprint bug.
- Label `refactoring`, title `[Dev Refactor]` → an in-sprint refactor.
- None of the above → halt `⚠️ Issue #<N> (labels: <labels>, title "<title>") is not an in-sprint story, bug, or refactor. Production bugs and standalone refactors merge via /bugfix:release or /refactor:release.`

Derive `$SPRINT_N` from board Sprint (`Sprint N`) → `$SPRINT_BRANCH = feature/sprint-<$SPRINT_N>`. No board Sprint → halt `⛔ Issue #<N> has no board Sprint — it is not an in-sprint item.`

Locate the completion comment — body starts `## Implementation Complete`, `## Refactor Complete`, **or** `## Revert Ready`. Latest such → `$COMPLETION_COMMENT`. None → halt `⛔ Issue #<N> has no completion comment — run its implement command first.`

## Extract PRs From Comment

Parse `$COMPLETION_COMMENT` for PR links:

- **Implementation Complete** / **Refactor Complete** — single: `- PR: <url>`; multi: `- <codebase>: <url>` per codebase.
- **Revert Ready** — single: `- Revert PR: <url>`; multi: `- <codebase> revert PR: <url>` per codebase.

Collect every PR URL → `$ITEM_PRS`. None → halt `⛔ No PR links in the completion comment for #<N> — re-run its implement command.`

## Confirm Merge

Per PR in `$ITEM_PRS`, via `git` skill **Fetch PR** → read `state`, `merged`, head, base. Partition:

- **$OPEN_PRS** — open, not merged. The merge set.
- **$MERGED_PRS** — already merged. Skip; report `↺ already merged`.
- **$STALE_PRS** — closed but not merged. Skip; warn.

`$OPEN_PRS` empty → print one `↺ already merged` line per `$MERGED_PRS` entry → jump to **Next Step**.

Else print the plan:

```
#<N> — <title>  →  merge into <$SPRINT_BRANCH>

To merge (squash):
  - <pr_title>  (#<pr_number>)
Already merged (skipped):
  - <pr_title>  (#<pr_number>)
Closed, NOT merged (skipped — review manually):
  - <pr_title>  (#<pr_number>)
```

Per `$OPEN_PRS` entry, via `git` skill **Diff Branch Files** (`$SPRINT_BRANCH`...head) → list changed paths.

Ask via `AskUserQuestion`: `Merge the listed PR(s) into <$SPRINT_BRANCH>?` — proceed only on confirmation.

## Merge Into Sprint Branch

Via `git` skill **Merge PR** (squash, **Keep branch** — do not delete head), per `$OPEN_PRS` entry → merge into the sprint branch. Sequential. On failure → stop, surface the reason, tell the user to re-run `/feature:merge <N>`. Output per PR:

```
✓ Merged <pr_title> into <$SPRINT_BRANCH>
```

## Next Step

PRs merged into the sprint branch. Next:

- `/feature merge the next reviewed story, bug, or refactor`
- `/feature pre-release the sprint` — once every item is merged