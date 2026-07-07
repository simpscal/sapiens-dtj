---
name: brainstorm
description: Clarify ONE feature idea WITH the user — intensive Q&A grounded in PRODUCT.md until shared understanding, gate on approval, then write it as a single Feature backlog draft.
argument-hint: "[idea or theme — 'one-tap reorder', or nothing to pick a focus from product strategy]"
tools: Read, Write, Bash, AskUserQuestion
---

# /brainstorm — Clarify One Feature Idea

Parse `$ARGUMENTS` → `$SEED` (optional free-text idea or theme; empty = pick a focus from product strategy).

Pre-backlog: clarify **one** feature idea **with** the user until you share the same understanding, then write it as a single board draft. Draft feeds `/backlog:promote → feature:requirement:create`.

## Workflow
1. Resume Check
2. Load Product Context
3. Clarify Loop
4. Present & Approve
5. Write Draft
6. Next Step

## Resume Check

`$SLUG` = kebab of `$SEED`, else `adhoc`.
Via `checkpoint` skill, read `workflow = brainstorm`, `run_key = $SLUG`.
Hit → run the skill's Resume Prompt → on Resume, jump past `current_step`.

## Load Product Context

Read `PRODUCT.md` (repo root). Hold **Vision**, **Business Goals**, **Target Users**, **Product Boundaries** (in/out), **Strategic Direction**.

## Clarify Loop

Hold facets `{title, problem, target_user, goal, why_now, scope}`.

**Seed.** `$SEED` present → seed the idea from it. Empty → propose **2–3 focuses** from **Strategic Direction** (one line each); one `AskUserQuestion` (single-select) → pick one, or free-text own → `$SEED`.

**Clarify.** Intensively question until every facet is pinned and sits **inside Product Boundaries**, naming the **Goal / Strategic Direction** it serves.

- Per ambiguous facet, propose your best read, ask via `AskUserQuestion` to confirm or correct. Batch related facets in one call; infer what the dialogue already answers; ask only genuine unknowns.
- User free-texts → fold in → re-derive dependent facets.
- Conflicts **Boundaries** → surface it, re-narrow; don't carry an out-of-scope idea forward.
- Continue until no facet is ambiguous. Don't proceed on a guess.

Checkpoint facets → `phases.clarify.decisions.idea`.

## Present & Approve

Render the shared understanding → `$DRAFT = .claude/state/brainstorm-$SLUG.md`:

```
💡 Idea — <title>

Problem      <problem>
Target user  <segment>
Goal served  <business goal / strategic direction>
Scope        <in-boundary scope, why now>
```

Present it back in one screen. One `AskUserQuestion` (single-select): **Approve** / **Revise**.

- **Approve** → **Write Draft**.
- **Revise** → one `AskUserQuestion` (`multiSelect: true`) over facets — **Problem**, **Target user**, **Goal served**, **Scope / why-now**, **Title** → `$REVISE`. Loop to **Clarify Loop** for only the `$REVISE` facets → overwrite `$DRAFT` → re-present. Iterate until **Approve**.

## Write Draft

Via `github` skill run **Create Backlog Draft** — `type = Feature`, `title` = idea title, `body`:

```
<problem>

Target user: <segment>
Goal served: <business goal / strategic direction>
Why now: <clarified trigger / pain from the session>

Source: /brainstorm (<seed>)
```

Hold the returned item ID. Missing-board / missing-scope → surface the skill's message → stop.
Checkpoint ID → `phases.write.artifacts.drafts` (replay-safe).
Delete `$DRAFT` via `Bash: rm`. Clear checkpoint (`workflow = brainstorm`, `run_key = $SLUG`).

Output: `Backlogged 1 idea as a Feature draft: <title>.`

## Next Step

- `/backlog show the backlog` — review the new draft
- `/backlog promote an item` — turn the draft into a requirement
