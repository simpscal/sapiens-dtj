---
name: user-stories
description: Use when writing, reviewing, splitting, or refining user stories and acceptance criteria for a product backlog. Enforces INVEST, a testability linter on every AC, and a structured story spec contract. Do NOT use for PRDs, technical specs, epics, or architecture work — for epics, capture the epic separately first, then use this skill to decompose it. Does not touch external systems; the caller owns all orchestration.
tools: Read, Edit, Write, AskUserQuestion
---

# User Story Expertise

Discovery → draft via the Story Spec → Testability Linter on every AC → Validation → Ordering → emit per Notes Rendering.

## Discovery Protocol

Synthesise understanding across the six categories; any gap that would change scope is **blocking**. Probe each:

1. **Role** — who specifically, with context (not "user").
2. **Intent** — the outcome in user terms, not implementation.
3. **Value** — why it matters; if only statable as tautology, not ready.
4. **Definition of done** — the observable success condition.
5. **Constraints** — platform, compliance, performance, permissions, flows to preserve.
6. **Edge and failure cases** — invalid input, missing permission, network failure, missing data, repeated action.

Present synthesis, then ask every blocking gap via **AskUserQuestion** (max 4 questions per call; batch follow-up calls if more) — concrete options per question, not open-ended prose; do not draft yet. Re-synthesise on each response until no blocking gaps remain, then confirm in one line before output. Non-blocking ambiguities → resolve with a stated assumption.

## Scope Boundary

User stories capture **user-observable behaviour only**. Out of scope as stories: design tokens, primitives, shared components, schemas, migrations, data models, infrastructure, cross-cutting modules, refactors, spikes.

When foundational work is needed, do not smuggle it in or invent a "technical story":

- Team prerequisite → capture as a separate task/spike (outside this skill); add to `depends_on_titles` only if it blocks the user-observable outcome.
- User explicitly asked for technical breakdown → stop, say this skill produces user stories only, offer to list the technical work as plain items.

## Story Spec

Draft each story to this spec — Scope Boundary governs what becomes a story, INVEST (first three) and AC Format govern content, Splitting when too big:

```yaml
- title: "[Story] <title>"
  user_story: "As a <role>, I want <action> so that <benefit>"
  acceptance_criteria:
    - "<AC>"
  notes:
    edge_cases: ["<text>", ...]
    design_instructions: [{label: "<filename.md>", url: "<url>"}, ...]
    mockups: [{label: "<filename.html>", url: "<url>"}, ...]
    references: [{label: "<text>", url: "<url>"}, ...]
    depends_on_titles: ["<title>", ...]
```

## INVEST

Every story satisfies all six (first three checked during drafting, last three during validation):

- **Independent** — deliverable without another story first; unavoidable dependencies go in `depends_on_titles`.
- **Negotiable** — the "what" is fixed, the "how" open; no implementation in the want clause.
- **Valuable** — observable value to a user or stakeholder; a tautological "so that" means re-run Discovery on intent.
- **Estimable** — scope clear enough to ballpark; fails on vague scope, unknown dependencies, hidden research.
- **Small** — completable within a sprint by one team (see Splitting).
- **Testable** — every AC passes the linter.

## AC Format

- `When X, then Y.` or `Given X, when Y, then Z.`
- Checklist bullets when the story is about completeness, not behaviour. Don't force Given/When/Then where it doesn't fit.
- An AC may cite a reference by label instead of restating detail.
- Target 2–5 ACs; fewer suggests under-specification, more suggests splitting.

## Splitting

A story failing **Small** or with more than ~5 ACs splits. Techniques, in preference order: workflow steps → happy path vs alternates → CRUD operations → data/input variation → interface surface. Never split by technical layer (frontend/backend story) — that violates Independent and Valuable.

## Testability Linter

Run on every AC; each must pass all four:

1. **Observable** — verifiable without reading code or internal state.
2. **Located** — names the user-visible area/screen/surface.
3. **Specific** — concrete trigger and outcome, not "works correctly".
4. **Verifiable** — a non-engineer can confirm pass/fail in a running system.

On failure choose one:

- **Rewrite** when the requirement is clear but the wording weak. Preserve meaning; record `{original, rewritten, reason}`, aggregate as `rewrote_for_testability`.
- **Escalate** when the requirement itself is unclear (missing trigger, ambiguous outcome, unknown threshold) — re-open Discovery; never silently rewrite.

Cap: more than three rewrites for one story → stop and escalate the whole story.

## Validation

Across the full set: every Discovery capability covered by ≥1 story's ACs; no duplicate scope; no implementation details as AC outcomes; no foundational work as stories; every cross-story dependency explicit in `depends_on_titles`; no gold-plating (every AC traces to stated intent or a surfaced edge case).

## Ordering

Dependency depth first (no `depends_on_titles` first), then user value within each depth level.

## Notes Rendering

- **`design_instructions`** — `- Design Instructions: [label](url)`. Multiple → nested list.
- **`mockups`** — same pattern under `- Mock UI:`.
- **`edge_cases`** — one bullet per item.
- **`depends_on_titles`** — `- Depends on: <resolved refs>`.

## Constraints

- Never invent scope — run Discovery.
- Never add technical details to ACs.
- Never silently rewrite an AC whose underlying requirement is unclear — escalate.
- Never touch GitHub, filesystem, or external systems.
- AC reshape: only `## Acceptance Criteria` and `## Notes` may change.
