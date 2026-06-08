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
5. Run UI Design (ui-design agent)
6. Commit + Push
7. Upsert Design Hub Comment
8. Next Step

## Resolve Source

Ask via `AskUserQuestion` → `$REGEN_SOURCE`:

- **Story change** — diff existing surface stories against changed story ACs to detect which surfaces need updating. Use after stories were added, amended, or closed.
- **User input** — user describes which surfaces to regenerate and why. Use when the change isn't reflected in story ACs.

## Load Sprint Context

Via the `github` skill, load Sprint Snapshot for Sprint $SPRINT_N → `$STORIES`, `$REQUIREMENT`, `$DESIGN`.

Halt if any precondition fails:

- `$REQUIREMENT` absent → `⛔ No requirement issue found in Sprint $SPRINT_N. Cannot regenerate design without a requirement.`
- `$STORIES` empty → `⛔ No user stories found in Sprint $SPRINT_N. Run /feature:stories:create <requirement_issue> first.`
- `$DESIGN` absent (no `## Design Navigation` hub comment on the requirement issue) → `⛔ No design hub found on the requirement issue — run /feature:design:create $SPRINT_N first.`

Restrict `$STORIES` to `[Story]`-prefixed titles — exclude `[Tech]` and `[Revert]`.

Resolve the frontend codebase. Check out its sprint branch for Sprint $SPRINT_N.

Scan `src/stories/surfaces/` for `*.stories.tsx` files → derive `$EXISTING_SURFACES` (slug from filename: PascalCase → kebab-case). For each, read the story file to extract the rendered states and component list → `$SURFACE_STORIES[slug]`.

Parse the hub comment's surfaces table → `$HUB_SURFACES` (slug + route + name for each surface already documented).

## Build Change Plan

Produce `$REGEN_SURFACES` and `$REMOVED_SURFACES` per `$REGEN_SOURCE`:

### Story change

Compare `$EXISTING_SURFACES` + `$HUB_SURFACES` against current `$STORIES` ACs. Identify changed ACs, added stories, and closed/missing stories. Halt if no differences: `⛔ No story changes found — design is already up to date.`

Map each changed story to affected UI surfaces:

| Affected Surface | Story | Classification | Planned Action |
|---|---|---|---|
| `<slug>` | `#N` | New / Modified / Removed | Create story / Update story / Delete story |

- **New** — story introduces a surface with no existing story file.
- **Modified** — story ACs changed since the surface story was last authored.
- **Removed** — story is closed or no longer covers this surface.

Partition into `$REGEN_SURFACES` (New + Modified) and `$REMOVED_SURFACES` (Removed).

### User input

Ask via `AskUserQuestion`, hold as `$SURFACE_DELTA`: `Which surfaces need regenerating for Sprint $SPRINT_N, and what changed?` If too thin, ask one follow-up.

Decompose `$SURFACE_DELTA` into discrete surface-level changes. For each, classify as **New**, **Modified**, or **Removed** by matching against `$EXISTING_SURFACES` and `$HUB_SURFACES`. A **User input** delta is targeted: never remove a surface the user didn't name.

Partition into `$REGEN_SURFACES` (New + Modified) and `$REMOVED_SURFACES` (Removed).

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/feature-design-regen-sprint-<$SPRINT_N>.md`.

Write `$DRAFT` rendering the full Change Plan table — call out every `$REMOVED_SURFACES` entry explicitly (deletes a surface story file).

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>` — `<count>` to regenerate, `<count>` to remove. Choose:
>
> - **Approve** — apply the plan.
> - **Adjust** — describe what to change; re-run **Build Change Plan** with the appended feedback; rewrite the draft.
> - **Cancel** — abort; no files or comments change.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`, fold into the change-plan inputs, re-run **Build Change Plan**, overwrite `$DRAFT`, re-prompt.
- **Cancel** — halt.
- **Approve** — proceed to **Run UI Design**.

Do not touch surface stories or the hub comment until the user approves.

## Run UI Design

Spawn one **ui-design** agent with a `<context>` block:

```xml
<context>
  <codebase path="[frontend path]" branch="[sprint branch]" />
  <story_acs>
    <story number="..." title="...">
- [ ] [verbatim ACs for regen surfaces]
    </story>
  </story_acs>
  <change_input>
    Regenerate: [each $REGEN_SURFACES surface + what changed]
    Remove: [each $REMOVED_SURFACES surface]
  </change_input>
</context>
```

The agent regenerates and removes the surface story files per the change plan.

## Commit + Push

Via the `git` skill, commit updated / created / deleted Storybook surface stories on the frontend sprint branch (`chore(design): regenerate sprint-{$SPRINT_N} surfaces`) and push. Resolve blob URLs.

## Upsert Design Hub Comment

Via the `github-templates` skill, re-render `comment-design-hub` with the full updated surfaces table — reuse `$DESIGN`'s existing rows for unaffected surfaces; replace rows for `$REGEN_SURFACES`; drop rows for `$REMOVED_SURFACES`.

Via the `github` skill, edit `$DESIGN` (the located hub comment) in place. Create a new one on the requirement issue if absent.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Surface stories regenerated. Print the next command:

- `/feature:technical-design:regenerate <sprint_number>` — reconcile the TDD
- `/feature:implement <story_issue>` — implement against the new design
