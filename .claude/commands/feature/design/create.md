---
name: feature:design:create
description: Compose Storybook surface stories for a sprint's UI stories. Commit to the frontend codebase and post a hub comment on the requirement issue.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Design — Create

Navigator supplies `$SPRINT_N`.

## Workflow
1. Load Sprint Context
2. Filter UI Stories
3. Run UI Design (ui-design agent)
4. Commit, PR, Notify
5. Next Step

## Load Sprint Context

Via the `github` skill, load Sprint Snapshot for Sprint $SPRINT_N → `$STORIES`, `$REQUIREMENT`, `$DESIGN`.

Halt if `$DESIGN` is present (the requirement already carries a `## Design Navigation` hub comment): `Design hub already exists on the requirement issue — run /feature:design:regenerate $SPRINT_N to update affected surfaces.`

## Filter UI Stories

Restrict `$STORIES` to `[Story]`-prefixed titles — exclude `[Tech]` and `[Revert]`. Filter to entries with user-facing UI changes → `$UI_STORIES`. Halt if empty: `No UI work found in this sprint — skipping design phase.`

## Run UI Design

Checkout the sprint branch for Sprint $SPRINT_N.

Spawn one **ui-design** agent with a `<context>` block:

```xml
<context>
  <codebase path="[frontend path]" branch="[sprint branch]" />
  <story_acs>
    <story number="..." title="...">
- [ ] [verbatim ACs from $UI_STORIES]
    </story>
  </story_acs>
</context>
```

Omit sections that don't apply.

Collect `$SURFACE_FILES` from the agent's `<files_changed>`.

## Commit, PR, Notify

Via the `git` skill, commit all Storybook surface stories on the frontend sprint branch (`chore(design): sprint-{$SPRINT_N} surface stories`) and push.

Via the `git` skill, open a PR from the sprint branch:

- **Title**: `chore(design): sprint-<$SPRINT_N> Storybook surface stories`.
- **Body**: render the `pr-design-system` template via the `github-templates` skill with `{summary, atmosphere: "N/A — feature sprint", layout_pattern: "N/A", requirement_issue: $REQUIREMENT_ISSUE_NUMBER}`.

Hold the PR URL → `$DESIGN_PR_LINK`.

Resolve blob URLs for each surface story file on the sprint branch.

Via the `github-templates` skill, render `comment-design-hub` with `{ storybook, surfaces }` where each surface row includes the story blob URL. Via the `github` skill, post as a comment on `#$REQUIREMENT`.

Via the `github-templates` skill, render `comment-design-complete` with `{ design_pr_link: $DESIGN_PR_LINK }`. Via the `github` skill, post as a follow-up comment on `#$REQUIREMENT`.

## Next Step

Surface stories composed. Print the next command:

- `/feature:technical-design:create <sprint_number>` — author the TDD
