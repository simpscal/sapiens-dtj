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
4. Review Agent Output
5. Commit, PR, Notify
6. Next Step

## Load Sprint Context

Via `github` skill, load Sprint Snapshot for Sprint $SPRINT_N → `$STORIES`, `$REQUIREMENT`, `$DESIGN`.

`$DESIGN` present (requirement already carries a `## Design Navigation` hub comment) → halt `Design hub already exists on the requirement issue — run /feature:design:regenerate $SPRINT_N to update affected surfaces.`

## Filter UI Stories

Restrict `$STORIES` to `[Story]`-prefixed titles (exclude `[Tech]`, `[Revert]`) → filter to entries with user-facing UI changes → `$UI_STORIES`. Empty → halt `No UI work found in this sprint — skipping design phase.`

## Run UI Design

Check out the sprint branch for Sprint $SPRINT_N.

Spawn one **ui-design** agent with a `<context>` block:

```xml
<context>
  <codebase path="[frontend path]" branch="[sprint branch]" />
  <story_acs>
    <story number="..." title="...">
- [ ] [verbatim ACs from $UI_STORIES]
    </story>
  </story_acs>
  <change_input>[present only on an Adjust re-run — the $ADJUSTMENT feedback]</change_input>
</context>
```

Omit sections that don't apply.

Collect: `$SURFACE_FILES` ← `<files_changed>`, `$SURFACES` ← `<surfaces_composed>`, `$CONFIRMATIONS` ← `<confirmations>`.

## Review Agent Output

`AskUserQuestion`:

> Surfaces composed: `<$SURFACES list>`. `<count>` assumption(s) need confirmation: `<render each $CONFIRMATIONS item>`:
> - **Approve** → commit the stories
> - **Adjust** → describe corrections → re-run the design
> - **Cancel** → abort; stories stay on disk, commit nothing

- **Adjust** → `$ADJUSTMENT` → fold into `<change_input>` → re-run **Run UI Design** → return to this gate
- **Cancel** → halt; stories on disk, nothing committed
- **Approve** → **Commit, PR, Notify**

## Commit, PR, Notify

Via `git` skill → commit all Storybook surface stories on the frontend sprint branch (`chore(design): sprint-{$SPRINT_N} surface stories`) → push.

Via `git` skill, open a PR from the sprint branch:

- **Title**: `chore(design): sprint-<$SPRINT_N> Storybook surface stories`.
- **Body**: `pr-design-system` template (via `github-templates` skill) with `{summary, atmosphere: "N/A — feature sprint", layout_pattern: "N/A", requirement_issue: $REQUIREMENT_ISSUE_NUMBER}`.

Hold PR URL → `$DESIGN_PR_LINK`.

Resolve blob URLs for each surface story file on the sprint branch.

- `comment-design-hub` (via `github-templates` skill) with `{ storybook, surfaces }`, each surface row including the story blob URL → post as comment on `#$REQUIREMENT` via `github` skill.
- `comment-design-complete` (via `github-templates` skill) with `{ design_pr_link: $DESIGN_PR_LINK }` → post as follow-up comment on `#$REQUIREMENT`.

## Next Step

Surface stories composed. Next:

- `/feature write the technical design`