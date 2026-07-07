---
name: setup:design-system
description: Generate DESIGN_THEME.md, conform the frontend token config to it, refactor the shared component kit to realize the theme, and author Storybook stories — token stories (colors, borders, typography, elevation, radius) + component stories grouped by category. Lands as a PR on the frontend repo (sprint branch if a sprint is active, else main).
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, WebSearch, WebFetch
---

# Setup — Design System

Generate `DESIGN_THEME.md` (a concrete design system — token values, type scale, component catalog), then bridge it into the frontend: bind token values to the theme's Color Tokens, refactor the shared component kit to realize the theme, then author the design-system Storybook stories. Discover tooling + conventions at runtime (no assumed filenames/stack).

## Workflow
1. Resolve Frontend
2. Generate DESIGN_THEME.md
3. Existence Check
4. Resolve Base
5. Branch
6. Conform Tokens
7. Refactor Component Kit
8. Write Token Stories
9. Write Component Stories
10. Verify
11. Review Gate
12. Commit + PR
13. Confirm + Next Step

## Resolve Frontend

Frontend path → via `project-config` skill (the `web` codebase). Absent → halt `⛔ No web codebase in project-config — run /setup project-config first.`

Component inventory → via `project-config` skill.

## Generate DESIGN_THEME.md

Via `design-theme` skill, create/ensure `DESIGN_THEME.md` at the repo root — it handles the full flow: existence check (Skip / Regenerate gate), source selection, interview, write, confirm.

Then read `DESIGN_THEME.md` → `$THEME`.

## Existence Check

Detect an already-set-up system:

- Five token stories present → colors, borders, typography, elevation, radius.
- Every inventory component has a story.
- Component story titles are category-grouped (`Components/<Category>/<Name>`).

All true → `AskUserQuestion`:

- **Skip** *(default)* → exit `design system already set up — no changes made.`
- **Regenerate** → refresh tokens, component kit + stories to the current `$THEME`.

Not fully present → proceed (Set up).

## Resolve Base

Via `github` skill, resolve the active sprint (`board.sh current-sprint` → `$SPRINT_N`).

- Active sprint `Sprint N` **and** `feature/sprint-{N}` exists on `web` (via `git` skill Check Branch Exists) → `$BASE = feature/sprint-{N}`.
- No active sprint, or sprint branch absent on `web` → `$BASE = web` default branch.

## Branch

Via `git` skill → create the design-system branch on `web` (`chore/design-system`, base = `$BASE`).

## Conform Tokens

Discover the token/style config (no assumed filename). For every semantic token the config exposes **and** `$THEME` **Color Tokens** define → bind the config to the theme's concrete values (realizing `$THEME` **Design Principles** + **Color Tokens**):

- Radius → fit **Spacing & Shape** + **Design Principles**.
- Font → per **Typography**.
- Spacing rhythm → per **Spacing & Shape**.

Rules:

- Preserve config structure → light + dark, theme→var mapping, existing token groups.
- `$THEME` references a role missing from tokens → add it. Token absent from `$THEME` → keep (theme is direction, not exhaustive).
- **Contrast check** → every foreground/background pair WCAG AA.
- Theme direction can't be realized within the token structure → note it, never silently drop.

Record `$TOKENS_CHANGED` (role → old → new).

## Refactor Component Kit

Refactor the **existing** shared components so their code realizes `$THEME` — the conventions tokens alone can't express (selected-state color, control shape, variant placement).

- Map each `$THEME` **Core Components** + **Color Tokens** rule to the component that owns it → adjust that component's variant/class definitions to consume the semantic token (e.g. selected state → the `surface-inverse` token, icon buttons → the pill shape rule).
- `$THEME` names a role/variant a component lacks → add the variant to that component. Component already conforms → leave untouched.
- Behaviour-preserving only: change styling + variant wiring — never prop semantics, event contracts, or accessibility roles.
- Refactor the kit that exists; never author a **new** component. Net-new components are out of scope.
- Variant added → cover it in that component's story (**Write Component Stories**).

Record `$COMPONENTS_REFACTORED` (component → change).

## Write Token Stories

Write/refresh: colors, borders, typography, elevation, radius.

- Match the codebase's existing story conventions → discover title namespace (e.g. `Design Tokens/<Name>`), autodocs, dark-variant exports, live token swatches vs hardcoded descriptors, i18n copy. Preserve the existing namespace; never invent a new one.
- Reflect the conformed tokens (Conform Tokens) → stories read live tokens where the codebase does.

## Write Component Stories

Cover the **full** inventory. Title `Components/<Category>/<Name>`.

- **Discover the existing category scheme** from current component story titles → preserve it. Component lacking a story → assign the best-fit category consistent with that scheme.
- Create missing stories, retitle drift, cover variants added in **Refactor Component Kit**. Never author new components — refactor + stories only.
- Match existing authoring conventions → controls/argTypes, `Default` + scenario exports, i18n namespaces if the codebase uses them.

Record per-category counts → `$STORY_COUNTS`.

## Verify

Discover + run the codebase's build, type-check, lint/test, and storybook-build commands. All must finish clean before proceeding — the component refactor is behaviour-preserving, so the test suite must stay green.

Any error → stop, surface the failing command + reason, commit nothing. Do not silence build errors.

## Review Gate

`AskUserQuestion` — summarize `$TOKENS_CHANGED`, `$COMPONENTS_REFACTORED`, `$STORY_COUNTS` by category, theme-conformance (note any divergence):

- **Approve** → **Commit + PR**
- **Adjust** → describe corrections → re-run **Conform Tokens** / **Refactor Component Kit** → **Verify** → return to this gate
- **Cancel** → halt; files stay on disk, nothing committed

## Commit + PR

Via `git` skill on `web`:

- Commit → `chore(design-system): conform tokens, refactor component kit, author stories` → push.
- Open PR → base `$BASE` → body from `pr-design-system` template (via `github-templates` skill) with `{summary, tokens_changed: $TOKENS_CHANGED, components_refactored: $COMPONENTS_REFACTORED, token_stories: colors/borders/typography/elevation/radius, component_categories: $STORY_COUNTS}`.

Hold PR URL → `$DS_PR_LINK`.

## Confirm + Next Step

Output: `Design system set up on web — tokens conformed to DESIGN_THEME.md, component kit refactored, Storybook stories authored. PR: $DS_PR_LINK`.

Next:

- `/feature design the next sprint's surfaces`
