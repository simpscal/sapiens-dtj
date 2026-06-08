---
name: feature:merge
description: Merge one story's open PRs into the sprint branch — resolve the story, extract its PRs from the Implementation Complete or Revert Ready comment, confirm, then squash-merge each.
tools: Read, Bash, AskUserQuestion
---

# Feature Merge

Merge **one story per invocation**. Parse `$ARGUMENTS`: the single token is `story_issue_number`.

## Workflow
1. Fetch Story
2. Extract PRs From Comment
3. Confirm Merge
4. Merge Into Sprint Branch
5. Next Step

## Fetch Story

Via the `github` skill, fetch issue `#story_issue_number` in full (title, labels, comments).

Guards:

- Missing `user-story` label → halt: `⚠️ Issue #<N> is not a story (labels: <labels>).`
- Title not prefixed `[Story]`, `[Tech]`, or `[Revert]` → halt: `⚠️ Issue #<N> title "<title>" must begin with [Story], [Tech], or [Revert].`

Derive `$SPRINT_N` from the issue's board Sprint value (`Sprint N`); build `$SPRINT_BRANCH = feature/sprint-<$SPRINT_N>`.

Locate the completion comment — body starts `## Implementation Complete` **or** `## Revert Ready`. Use the latest such comment → `$COMPLETION_COMMENT`. If neither exists, halt: `⛔ Issue #<N> has no Implementation Complete or Revert Ready comment — run /feature:implement <N> first.`

## Extract PRs From Comment

Parse `$COMPLETION_COMMENT` for PR links:

- **Implementation Complete** — single: `- PR: <url>`; multi: `- <codebase>: <url>` per codebase.
- **Revert Ready** — single: `- Revert PR: <url>`; multi: `- <codebase> revert PR: <url>` per codebase.

Collect every PR URL → `$STORY_PRS`. If none found, halt: `⛔ No PR links in the completion comment for #<N> — re-run /feature:implement <N>.`

## Confirm Merge

For each PR in `$STORY_PRS`, via the `git` skill **Fetch PR**, read its `state`, `merged`, head and base. Partition:

- **$OPEN_PRS** — open, not merged. The merge set.
- **$MERGED_PRS** — already merged. Skip; report `↺ already merged`.
- **$STALE_PRS** — closed but not merged. Skip; warn.

If `$OPEN_PRS` is empty, print one `↺ already merged` line per `$MERGED_PRS` entry and jump to **Next Step**.

Otherwise print the plan:

```
Story #<N> — <title>  →  merge into <$SPRINT_BRANCH>

To merge (squash):
  - <pr_title>  (#<pr_number>)
Already merged (skipped):
  - <pr_title>  (#<pr_number>)
Closed, NOT merged (skipped — review manually):
  - <pr_title>  (#<pr_number>)
```

For each `$OPEN_PRS` entry, via the `git` skill **Diff Branch Files** (`$SPRINT_BRANCH`...head) list the changed paths.

Ask via `AskUserQuestion`: `Merge the listed PR(s) into <$SPRINT_BRANCH>?` — proceed only on confirmation.

## Merge Into Sprint Branch

Via the `git` skill **Merge PR** operation (squash, **Keep branch** path — do not delete the head branch), for each `$OPEN_PRS` entry merge it into the sprint branch. Run sequentially. On failure, stop, surface the reason, and tell the user to re-run `/feature:merge <N>`. Output per PR:

```
✓ Merged <pr_title> into <$SPRINT_BRANCH>
```

## Next Step

Story PRs merged into the sprint branch. Print:

- `/feature:merge <next_story_issue>` — merge the next reviewed story
- `/feature:pre-release <sprint_number>` — once every story is merged
