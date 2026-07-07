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
3. Enumerate Surfaces
4. Run UI Design (ui-design agents — one per surface, parallel)
5. Review Agent Output
6. Commit, PR, Notify
7. Next Step

## Load Sprint Context

Via `github` skill, load Sprint Snapshot for Sprint $SPRINT_N → `$STORIES`, `$REQUIREMENT`, `$DESIGN`.

`$DESIGN` present (requirement already carries a `## Design Navigation` hub comment) → halt `Design hub already exists on the requirement issue — run /feature:design:regenerate $SPRINT_N to update affected surfaces.`

## Filter UI Stories

Restrict `$STORIES` to `[Story]`-prefixed titles (exclude `[Tech]`, `[Revert]`) → filter to entries with user-facing UI changes → `$UI_STORIES`. Empty → halt `No UI work found in this sprint — skipping design phase.`

## Enumerate Surfaces

Derive the customer-facing surfaces the `$UI_STORIES` ACs affect → `$SURFACES_TO_DESIGN` (per entry: `slug`, `route`, `name`, the ACs affecting it).

- Exclude admin routes + the OAuth callback.
- Many-to-many: an AC may touch several surfaces; a surface may draw from several ACs.

Empty → halt `No customer-facing surface found for the UI stories — skipping design phase.`

## Run UI Design

Check out the sprint branch for Sprint $SPRINT_N.

Spawn **one ui-design agent per `$SURFACES_TO_DESIGN` entry, in parallel** (single message, multiple Agent calls). Each agent gets its own `<context>`:

```xml
<context>
  <codebase path="[frontend path]" branch="[sprint branch]" />
  <surface slug="[slug]" route="[route]" name="[name]" />
  <requirement>
    [verbatim ACs for THIS surface + on an Adjust re-run, the $ADJUSTMENT for this surface]
  </requirement>
</context>
```

Collect across agents: `$SURFACE_FILES` ← each `<surface><story_file>`, `$SURFACES` ← each `<surface>`, `$COMPONENT_CHANGES` ← each `<authored_components><component>` (name + new|modified + summary), `$THEME_STATUS` ← `diverged` if any agent returns diverged, else `applied`/`absent`.

## Review Agent Output

`AskUserQuestion` (`$THEME_STATUS` = `diverged` → prepend `⚠ Design diverged from DESIGN_THEME.md.`; `$COMPONENT_CHANGES` non-empty → append line `Components added/changed: <$COMPONENT_CHANGES list>`):

> Surfaces composed: `<$SURFACES list>`:
> - **Approve** → commit the stories
> - **Adjust** → describe corrections → re-run the design
> - **Cancel** → abort; stories stay on disk, commit nothing

- **Adjust** → `$ADJUSTMENT` → fold into the affected surfaces' `<requirement>` → re-spawn only those surfaces' ui-design agents → return to this gate
- **Cancel** → halt; stories on disk, nothing committed
- **Approve** → **Commit, PR, Notify**

## Commit, PR, Notify

Via `git` skill → commit all Storybook surface stories **+ any changed shared components and their component stories** on the frontend sprint branch (`chore(design): sprint-{$SPRINT_N} surface stories`; `$COMPONENT_CHANGES` non-empty → append ` + kit`) → push.

Via `git` skill, open a PR from the sprint branch:

- **Title**: `chore(design): sprint-<$SPRINT_N> Storybook surface stories`.
- **Body**: `pr-designs` template (via `github-templates` skill) with `{summary, surfaces: $SURFACES (name + layout + states), component_changes: $COMPONENT_CHANGES, requirement_issue: $REQUIREMENT_ISSUE_NUMBER}`.

Hold PR URL → `$DESIGN_PR_LINK`.

Resolve blob URLs for each surface story file on the sprint branch.

- `comment-design-hub` (via `github-templates` skill) with `{ storybook, surfaces }`, each surface row including the story blob URL → post as comment on `#$REQUIREMENT` via `github` skill.
- `comment-design-complete` (via `github-templates` skill) with `{ design_pr_link: $DESIGN_PR_LINK }` → post as follow-up comment on `#$REQUIREMENT`.

## Next Step

Surface stories composed. Next:

- `/feature write the technical design`