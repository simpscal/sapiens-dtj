---
name: auto
description: Run a feature / refactor / bugfix workflow end-to-end (A→Z), auto-approving routine gates. Pauses to clarify the need up front (discovery) and again before the pre-release phase.
argument-hint: "[what you want, or nothing to continue the in-flight item]"
tools: Read, Write, Bash, AskUserQuestion
---

# /auto — Full-Workflow Autonomous Runner

Drives a workflow from first phase to release, invoking `/feature:*`, `/refactor:*`, `/bugfix:*` in sequence. The override below changes their behaviour at runtime only — never edits them.

## Invoke

`/auto [plain English]` — say what you want. The runner resolves type, mode, target, delta from your words + the board. Examples:

- `/auto` — continue the one in-flight item (resume at its first incomplete phase).
- `/auto add dark mode` — fresh feature.
- `/auto the SePay webhook returns 500` — fresh bugfix.
- `/auto tidy up the payment module` — fresh refactor.
- `/auto keep going on sprint 3` — continue a specific item.
- `/auto redo the stories — we dropped guest checkout` — regenerate + cascade.

## Interpret Intent

Resolve free text → `{type, mode, target, phase, delta}`. No prompt unless genuinely ambiguous:

- **type**: `feature` ← feature / sprint / story / screen / UI; `bugfix` ← bug / fix / broken / error / crash / 500; `refactor` ← refactor / clean up / tidy / restructure / tech debt / tooling / DX. Unstated → infer from verb + board.
- **mode**: `regen` ← regenerate / redo / re-run / amend / change / drop / add-to an existing artifact; `continue` ← continue / resume / keep going, a bare number, or empty input with an in-flight item; `fresh` ← new-work description with no matching existing item.
- **target**: number in text → that sprint# (feature) or issue# (refactor / bugfix); else the active sprint (feature) or the single in-flight issue (refactor / bugfix) from board / `.claude/state`.
- **phase** (regen only): the phase noun in text (requirement / stories / design / technical-design / spec); absent → earliest phase the delta affects.
- **delta**: remaining descriptive text — work description (fresh) or change (regen).

Truly ambiguous (e.g. several in-flight sprints, type unclear) → ask **one** `AskUserQuestion`; else run silently. Before executing, echo the plan: `▶ <type> · <mode> · target <x> · <phase | delta>`.

## Autonomous Override (applies for the whole run)

Override the interactive behaviour of every sub-command invoked:

1. **Never call `AskUserQuestion`** — except (a) start-of-workflow **Discovery** (step D) and (b) **Pre-release Gate** (step G). Everywhere else a sub-command would ask → pick the **forward/default** option and continue:
   - Resume-check fork → **Resume** if state exists, else proceed fresh.
   - Change-origin fork → **Phase intent** if an intent is in scope, else **Upstream update**; never block on a missing intent.
   - Design assumption / approve gate → **Approve** (log assumptions verbatim).
   - Any "draft → approve" loop — create / amend / regenerate of any phase (requirement, stories, technical-design, design, refactor spec, bug story) → accept the first draft, log, persist. (Draft is grounded by Discovery — safe.)
   - Discovery / clarification at the **start of a fresh workflow** (requirement, bug report, refactor spec) → **do NOT synthesize**; run interactively — see step D.
2. **Confirmation Protocol** (`git` + `github` "Proceed? (y/n)") → **auto-approved**: log the planned mutations in one line, proceed without waiting.
3. **Exceptions that still pause / confirm:**
   - **Discovery** (step D) on a fresh run — clarify the real need with the human; synthesizing it seeds hallucinated stories, design, code.
   - **Pre-release Gate** (step G) — the release-side stop.
   - Every `⏸ Human gate` inside a `*:release` command (PR-diff review before merge) — leave intact.
   - Destructive ops surfaced by the `git` skill outside release (force push) — still confirm.
4. Any `⚠️` / error from a sub-command → **stop and report**; do not push past it.

Record the run: write `.claude/state/autonomous.json` = `{ "on": true, "type": "<type>", "arg": "<arg>" }` at start, delete at the end. Its presence means an `/auto` run is in flight — honour the override above on resume after a `/clear`.

## D — Discovery (clarify the need up front)

On a **fresh** run, the first phase (`feature:requirement:create`, `bugfix:report`, or `refactor:spec:create`) opens with a discovery dialog. Run it **interactively** — let it ask the human, wait for real answers. Do **not** synthesize from the one-line description: this seed grounds stories, design, TDD, code — inventing it makes every downstream agent hallucinate against a fabricated need.

- **fresh** only. `continue` / `regen` → the seed artifact exists → skip discovery, resume.
- After discovery, the agent drafts the requirement / bug / spec from the human's answers; `/auto` auto-approves that draft (already grounded).

## Phase Sequences (A→Z)

Run forward from the resume point to the Pre-release Gate. Step 1 of each fresh sequence is **Discovery** (step D). `(if needed)` phases are conditional — see Phase Detection.

`/auto` runs `bugfix` and `refactor` as **standalone** workflows (production bug / standalone refactor → `main`). A bug or refactor scoped to an active sprint belongs to the **feature** workflow (`/feature:bugfix`, `/feature:refactor`), handled by hand within that sprint run — not a separate `/auto` type.

### feature  *(operates on a sprint)*
1. `/feature:requirement:create <description>` → requirement issue + sprint.
2. `/feature:stories:create <requirement#>`
3. `/feature:design:create <sprint>` *(if needed — sprint has UI/web stories)*
4. `/feature:technical-design:create <sprint>` *(if needed — foundational/architectural work)*
5. Per open story, in issue order: `/feature:implement <story#>` → `/feature:merge <story#>`.
6. **Pre-release Gate** — notify + approve (step G).
7. On approval: `/feature:pre-release <sprint>` (creates release PRs) → `/feature:release <sprint>`.

### refactor  *(operates on one issue — standalone, ships to `main`)*
1. `/refactor:spec:create <description>` → refactor issue.
2. `/refactor:implement <issue#>`
3. **Pre-release Gate** — notify + approve (step G).
4. On approval: `/refactor:pre-release <issue#>` → `/refactor:release <issue#>`.

### bugfix  *(operates on one issue — production bug, ships to `main`)*
1. `/bugfix:report <description>` → production bug issue.
2. `/bugfix:story <issue#>`
3. `/bugfix:implement <issue#>`
4. **Pre-release Gate** — notify + approve (step G).
5. On approval: `/bugfix:pre-release <issue#>` → `/bugfix:release <issue#>`.

## Regenerate Mode

Entered when Interpret Intent resolves `mode = regen`. Regenerate one phase via its amend/regenerate variant → cascade every downstream phase that depends on it → end at the Pre-release Gate. `delta` = the change description; omit it to let the variant source the change from current artifacts. All draft gates auto-approve per the override.

**Regenerate-capable phases (run only if supported):**

| type | phase | command |
|---|---|---|
| feature | requirement | `/feature:requirement:amend <req#> <delta>` |
| feature | stories | `/feature:stories:regenerate <req#>` |
| feature | design | `/feature:design:regenerate <sprint>` |
| feature | technical-design | `/feature:technical-design:regenerate <sprint>` |
| refactor | spec | `/refactor:spec:amend <issue#> <delta>` |

`bugfix` has no regenerate/amend variant — `regen` unsupported; re-run `/auto bugfix <issue#>` to re-implement (Revisit).

**Cascade — after the regenerated phase, run its downstream-dependent phases in order:**

- feature · `requirement` → stories:regenerate → design:regenerate *(if UI)* → technical-design:regenerate *(if needed)* → implement *(Revisit, affected stories)* → merge → **Pre-release Gate** → pre-release → release.
- feature · `stories` → design:regenerate *(if UI)* → technical-design:regenerate *(if needed)* → implement → merge → **Pre-release Gate** → pre-release → release.
- feature · `design` → implement *(Revisit, UI stories)* → merge → **Pre-release Gate** → pre-release → release.
- feature · `technical-design` → implement *(Revisit, affected stories)* → merge → **Pre-release Gate** → pre-release → release.
- refactor · `spec` → implement *(Revisit)* → **Pre-release Gate** → pre-release → release.

Re-implementation runs as **Revisit**, change-origin = **Upstream update** (an artifact changed). `delta` a direct instruction rather than an artifact diff → pass it as the phase intent so change-origin = **Phase intent**. Only re-implement stories whose ACs / design / TDD changed; skip the rest, log which were skipped.

## Phase Detection (resume / idempotency)

Determine the first incomplete phase so re-running `/auto` continues rather than duplicates. Probe via the `github` skill (board + issues):

- **feature**: requirement issue exists? stories exist (open `user-story`)? design hub comment present (only if UI stories)? TDD issue present (only if foundational work)? per-story board Status (`Implemented` = implement+merge done)? Start at the first phase whose output is missing. Free-text `arg`, no matching requirement → phase 1. Numeric sprint `arg` → resolve that sprint, resume.
- **refactor / bugfix**: numeric `arg` → fetch the issue, check for spec/story/Implementation-Complete comment + board Status, resume at the first gap. Free-text `arg` → phase 1.

**"If needed" rule:** run **design** when any story targets a UI/web surface; run **technical-design** when the requirement implies new architecture, data model, or cross-cutting foundations. Ambiguous → run technical-design (the standard path); skip design only if clearly no UI work.

## G — Pre-release Gate (the release-side pause)

Reached after implementation (and merge, for feature) — **before** `pre-release`. Present a compact digest:

- target (sprint# / issue#), implemented PR links (story / fix PRs), implementation summary, a **migration? likely yes/no** heads-up (pre-release confirms), anything needing human eyes.

Ask **once** via `AskUserQuestion`: proceed to pre-release + release?

- **Proceed** → run `*:pre-release` → `*:release`. Release's internal `⏸ Human gate` (PR-diff review before merge) still applies.
- **Hold** → stop; leave everything staged. Marker stays armed so a later `/auto` resumes at this gate.

## Disarm

After release completes (or on Hold), delete `.claude/state/autonomous.json` and confirm: `🔓 Autonomous mode off.`
