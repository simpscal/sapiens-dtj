---
name: brainstorm
description: Brainstorm candidate features WITH the user — a collaborative ideation session grounded in PRODUCT.md — clarify and score each on strategic fit, then write the keepers as Feature backlog drafts.
argument-hint: "[plain English theme — e.g. 'ideas to boost checkout conversion', or nothing to ideate from product strategy]"
tools: Read, Write, Bash, AskUserQuestion
---

# /brainstorm — Collaborative Feature Ideation

Parse `$ARGUMENTS` → `$THEME` (optional free-text focus; empty = ideate from product strategy).

Pre-backlog: brainstorm features **with** the user, clarify against PRODUCT.md, keep the validated ones as board drafts. Drafts feed `/backlog:promote → feature:requirement:create`.

## Workflow
1. Resume Check
2. Load Product Context
3. Frame
4. Ideation Dialogue
5. Score Candidates
6. Batch Gate
7. Write Drafts
8. Next Step

## Resume Check

`$SLUG` = kebab of `$THEME`, else `adhoc`.
Via `checkpoint` skill, read `workflow = brainstorm`, `run_key = $SLUG`.
Hit → run the skill's Resume Prompt → on Resume, jump past `current_step`.

## Load Product Context

Read `PRODUCT.md` (repo root). Hold **Vision**, **Business Goals**, **Target Users**, **Product Boundaries** (in/out), **Strategic Direction**.

## Frame

`$THEME` present → frame = the theme.
Empty → frame = current **Strategic Direction**.
Vague or conflicts **Boundaries** → one focused `AskUserQuestion` to narrow.

## Ideation Dialogue

Loop with the user until they converge. Every proposal sits **inside Product Boundaries** and names the **Goal / Strategic Direction** it serves.

**Round 0 — Open angles.** Propose **2–3 directions** (problem areas tied to a Goal), one line each. Ask via `AskUserQuestion` (`multiSelect`): which to pursue + an "own angle" path → `$DIRECTIONS`. User free-texts pains/ideas → fold in.

**Round N — Riff.** Per direction, propose **2–3 candidate features** with the problem each attacks. Ask via `AskUserQuestion` per candidate: **Keep** / **Drop** / **Twist** / **Add my own** → update the working set. Fresh angle each round; don't repeat dropped ones.

**Clarify.** Per surviving candidate fill `{title, problem, target_user, goal, why_now}` — infer from the dialogue; ask only genuinely-unknown fields (one batched `AskUserQuestion`).

**Converge.** After each round ask: **more rounds** / **done — score these**. Cap ~3 rounds; stalling → score what's there.

Per candidate hold `{title, problem, target_user, goal, why_now}`. Checkpoint working set → `phases.ideate.decisions.candidates`.

## Score Candidates

No code, no deep design.

**Rubric — per idea, in order:**

1. **Strategic Fit** vs PRODUCT.md:
   - Matches a Boundaries *out* item → verdict **Shelve**, reason `out of scope: <boundary>`. Stop scoring this idea.
   - Else **Strong** (directly advances a Goal / Strategic Direction) / **Partial** (adjacent, indirect) / **Weak** (in scope, serves no current goal).
2. **Value** — H / M / L. User or ops impact; tie to the goal served.
3. **Effort** — S / M / L. Rough build size across api/web. Guess is fine.
4. **Confidence** — H / M / L. Sure on Value + scope? Low = unknowns remain.

**Verdict:**
- **Validated** — Fit Strong|Partial AND Value H|M AND Conf H|M.
- **Needs-info** — would validate but Conf Low (open question blocks).
- **Shelve** — out of scope, OR Fit Weak, OR Value Low.

Per idea hold `{title, fit, value, effort, confidence, verdict, rationale, open_question?}`.
Checkpoint scored set → `phases.score.decisions.scored`.

## Batch Gate

Render the scored table → `$DRAFT = .claude/state/brainstorm-$SLUG.md`:

```
💡 Brainstorm — <frame>

Validated
- <title>  [Fit <strong> · Value <H> · Effort <M> · Conf <H>]  → <rationale>
Needs-info
- <title>  [Conf <Low>]  ❓ <open_question>
Shelved
- <title>  ⛔ <reason>
```

**One** `AskUserQuestion`, **`multiSelect: true`** — options = every **Validated** + **Needs-info** idea (Shelved shown in draft, not offered); plus **Adjust**, **Cancel**.

> Draft `<$DRAFT>` — pick the ideas to keep as backlog drafts:

- Selection → `$KEEPERS` → **Write Drafts**.
- **Adjust** → `$ADJUSTMENT` → fold into **Frame** / **Ideation Dialogue** → re-run from **Ideation Dialogue** → overwrite `$DRAFT` → re-prompt.
- **Cancel** / empty selection → halt; `$DRAFT` stays on disk.

Picked a **Needs-info** idea → resolve its `open_question` via one follow-up `AskUserQuestion` before writing.

## Write Drafts

Per idea in `$KEEPERS`, via `github` skill run **Create Backlog Draft** — `type = Feature`, `title` = idea title, `body`:

```
<problem one-liner>

Target user: <segment>
Goal served: <business goal / strategic direction>
Why now: <clarified trigger / pain from the session>

Evaluation
- Strategic fit: <strong|partial>
- Value: <H|M> · Effort: <S|M|L> · Confidence: <H|M>
- Rationale: <one line>
- Resolved question: <answer>   (Needs-info only)

Source: /brainstorm (<frame>)
```

Hold each returned item ID. Missing-board / missing-scope → surface the skill's message → stop.
Checkpoint IDs → `phases.write.artifacts.drafts` (replay-safe).
Delete `$DRAFT` via `Bash: rm`. Clear checkpoint (`workflow = brainstorm`, `run_key = $SLUG`).

Output: `Backlogged <N> idea(s) as Feature drafts: <titles>.`

## Next Step

- `/backlog show the backlog` — review the new drafts
- `/backlog promote an item` — turn a draft into a requirement
