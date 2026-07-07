---
name: feature:design:regenerate
description: Regenerate Storybook surface stories — sourced from changed story ACs or from the user's input. Update / create / remove surface stories, refresh the hub comment, then commit.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Feature Design — Regenerate

Navigator supplies `$SPRINT_N`.

## Workflow
1. Resolve Source
2. Load Sprint Context
3. Build Change Plan
4. Draft + Approve Loop
5. Run UI Design (ui-design agents — one per regen surface, parallel)
6. Review Agent Output
7. Commit + Push
8. Upsert Design Hub Comment
9. Next Step

## Resolve Source

Ask via `AskUserQuestion` → `$REGEN_SOURCE`:

- **Story change** — diff existing surface stories against changed story ACs → which surfaces need updating. Use after stories were added, amended, or closed.
- **User input** — user names which surfaces to regenerate and why. Use when the change isn't in story ACs.

## Load Sprint Context

Via `github` skill, load Sprint Snapshot for Sprint $SPRINT_N → `$STORIES`, `$REQUIREMENT`, `$DESIGN`. Halt if any precondition fails:

- `$REQUIREMENT` absent → `⛔ No requirement issue found in Sprint $SPRINT_N. Cannot regenerate design without a requirement.`
- `$STORIES` empty → `⛔ No user stories found in Sprint $SPRINT_N. Run /feature:stories:create <requirement_issue> first.`
- `$DESIGN` absent (no `## Design Navigation` hub comment on the requirement) → `⛔ No design hub found on the requirement issue — run /feature:design:create $SPRINT_N first.`

Restrict `$STORIES` to `[Story]`-prefixed titles (exclude `[Tech]`, `[Revert]`).

Resolve the frontend codebase → check out its sprint branch for Sprint $SPRINT_N.

Scan existing surface stories → `$EXISTING_SURFACES` (slug per file). Per file → read rendered states + component list → `$SURFACE_STORIES[slug]`.

Parse the hub comment's surfaces table → `$HUB_SURFACES` (slug + route + name per documented surface).

## Build Change Plan

Produce `$REGEN_SURFACES` + `$REMOVED_SURFACES` per `$REGEN_SOURCE`:

### Story change

Compare `$EXISTING_SURFACES` + `$HUB_SURFACES` against current `$STORIES` ACs → identify changed ACs, added stories, closed/missing stories. No differences → halt `⛔ No story changes found — design is already up to date.`

Map each changed story → affected UI surfaces:

| Affected Surface | Story | Classification | Planned Action |
|---|---|---|---|
| `<slug>` | `#N` | New / Modified / Removed | Create story / Update story / Delete story |

- **New** — story introduces a surface with no existing story file.
- **Modified** — story ACs changed since the surface story was last authored.
- **Removed** — story closed or no longer covers this surface.

Partition → `$REGEN_SURFACES` (New + Modified), `$REMOVED_SURFACES` (Removed).

### User input

Ask via `AskUserQuestion` → `$SURFACE_DELTA`: `Which surfaces need regenerating for Sprint $SPRINT_N, and what changed?` Too thin → one follow-up.

Decompose `$SURFACE_DELTA` → discrete surface-level changes → classify each **New** / **Modified** / **Removed** against `$EXISTING_SURFACES` + `$HUB_SURFACES`. **User input** is targeted: never remove a surface the user didn't name.

Partition → `$REGEN_SURFACES` (New + Modified), `$REMOVED_SURFACES` (Removed).

## Draft + Approve Loop

`$DRAFT = .claude/state/feature-design-regen-sprint-<$SPRINT_N>.md` → write the full Change Plan table — call out every `$REMOVED_SURFACES` entry explicitly (deletes a surface story file).

`AskUserQuestion`:

> Draft `<$DRAFT>` — `<count>` to regenerate, `<count>` to remove:
> - **Approve** → apply the plan
> - **Adjust** → describe change → re-run **Build Change Plan** → rewrite draft
> - **Cancel** → abort; no files or comments change

- **Adjust** → `$ADJUSTMENT` → fold into change-plan inputs → re-run **Build Change Plan** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Run UI Design**

Do not touch surface stories or the hub comment until approved.

## Run UI Design

Spawn **one ui-design agent per `$REGEN_SURFACES` surface, in parallel** (single message, multiple Agent calls). Each agent gets its own `<context>`:

```xml
<context>
  <codebase path="[frontend path]" branch="[sprint branch]" />
  <surface slug="[slug]" route="[route]" name="[name]" />
  <requirement>
    [verbatim ACs for THIS surface + what changed]
  </requirement>
</context>
```

Collect across agents: `$SURFACES` ← each `<surface>`, `$COMPONENT_CHANGES` ← each `<authored_components><component>` (name + new|modified + summary), `$THEME_STATUS` ← `diverged` if any agent returns diverged, else `applied`/`absent`.

## Review Agent Output

`AskUserQuestion` (`$THEME_STATUS` = `diverged` → prepend `⚠ Design diverged from DESIGN_THEME.md.`; `$COMPONENT_CHANGES` non-empty → append line `Components added/changed: <$COMPONENT_CHANGES list>`):

> Surfaces composed: `<$SURFACES list>`:
> - **Approve** → commit the stories
> - **Adjust** → describe corrections → re-run the design
> - **Cancel** → abort; stories stay on disk, commit nothing

- **Adjust** → `$ADJUSTMENT` → fold into the affected surfaces' `<requirement>` → re-spawn only those surfaces' ui-design agents → return to this gate
- **Cancel** → halt; stories on disk, nothing committed
- **Approve** → **Commit + Push**

## Commit + Push

Delete each `$REMOVED_SURFACES` story file from the surfaces folder. Removing a surface story never deletes shared components — they may have other consumers.

Via `git` skill → commit updated / created / deleted Storybook surface stories **+ any changed shared components (`src/components/`) and their component stories (`src/stories/components/`)** on the frontend sprint branch (`chore(design): regenerate sprint-{$SPRINT_N} surfaces`; `$COMPONENT_CHANGES` non-empty → append ` + kit`) → push → resolve blob URLs.

## Upsert Design Hub Comment

Via `github-templates` skill, re-render `comment-design-hub` with the full updated surfaces table:

- reuse `$DESIGN`'s existing rows for unaffected surfaces
- replace rows for `$REGEN_SURFACES`
- drop rows for `$REMOVED_SURFACES`

Via `github` skill → edit `$DESIGN` (the located hub comment) in place. Absent → create a new one on the requirement issue.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Surface stories regenerated. Next:

- `/feature regenerate the technical design`
- `/feature implement against the new design`