---
name: refactor:spec:create
description: Draft a new standalone refactor spec — discovery dialog, parallel codebase exploration, design, draft + approve gate, then file as an issue. Covers any technical system improvement: code quality, tooling, DX, CI/infrastructure, observability, documentation systems, or capability expansions that do not change user-visible behaviour.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Refactor Spec — Create

Refactor scoped to an active sprint → use `/feature:refactor:spec`.

## Workflow
1. Discovery Dialog
2. Explore Codebase
3. Resolve Blocking Questions
4. Design Refactoring Spec
5. Draft + Approve Loop
6. Create Refactoring Issue
7. Next Step

## Discovery Dialog

Ask via `AskUserQuestion` (single call):

- **Technical goal?** — the improvement driving this work. Remediation (tech debt, coupling, performance, tooling/DX gap, missing CI check, observability gap) or additive (new tooling, docs system, capability expansion). Be specific about what's wrong or missing today.
- **Scope?** — modules, layers, config files, pipelines, or files affected.
- **Definition of done** — what's true after the work that isn't now.

Vague answer → follow-up `AskUserQuestion`.

## Explore Codebase

**Where** — via `git` skill, check out `main` in each in-scope codebase (exploration reflects the exact base state the work builds on). Spawn one `Explore` subagent per in-scope codebase **in parallel**.

**Brief each subagent** — hand it the technical goal + scope from Discovery + the Resolve Blocking Questions categories its codebase must answer. Transformative → find what must change; additive → find what's missing. It forms own hypotheses, picks what to read — orient, don't checklist. Per-role starting points (orientation, not checklist):

- **backend** — code, services, patterns in the goal's path; plus backend tooling/DX (config, build scripts, manifests, linters, test setup).
- **frontend** — components, hooks, state, shared primitives in the path; plus frontend tooling/DX (config, build scripts, manifests, linters, test/Storybook setup).
- **infrastructure** — IaC resources, modules, config; plus CI/CD + platform tooling (pipelines, build/deploy scripts, runner config, environment setup).

**Stop when** the subagent can, for its codebase:

- name the closest existing analogue/pattern for each change or addition, with file path;
- state the convention to follow or diverge from;
- name where each new or changed piece lives.

Can't resolve from code or tooling → blocking question, not a reason to keep probing.

**Verify, don't assume** — confirm each claimed analogue/pattern by reading or grepping the real file, never from naming. Infrastructure → per resource, call the cloud/platform API for actual current state (running/stopped, attached/detached, exists/missing, rule present/absent). Don't assume or ask what tooling can confirm directly.

**Return** per finding: file path, symbol name (class/method/component/resource/tool), current pattern, what changes or is added and why; infrastructure adds live-state findings.

## Resolve Blocking Questions

Answer each from exploration findings first (incl. live infrastructure state). Raise only what neither codebase nor tooling can answer. Collect all blockers → single `AskUserQuestion`.

| Category | Decisions to resolve |
|----------|----------------------|
| **Nature of change** | Additive (new tooling/setup, no existing code changed), transformative (existing code restructured), or mixed? Determines which downstream rows apply. |
| **Scope boundary** | Files/modules to exclude even if they look related? |
| **Backward compatibility** | (Skip for purely additive.) Must public contracts (API, events, DB schema, CI script interfaces, published npm scripts, env var names) stay unchanged during + after? |
| **Migration** | Data, state, config, or environment to migrate (DB data, config format change, CI env vars, lockfile regen, dev machine setup)? |
| **Dependencies** | Does other in-progress work share the affected files? Conflict risk? |
| **Non-functional targets** | Latency, throughput, memory, build time, CI duration, or dev-tooling performance goals to hit or preserve? |

Skip categories that clearly don't apply.

## Design Refactoring Spec

From exploration findings, draft the full spec. No implementation code. Keep every field.

**Writing style** — terse, scannable; mirror the TDD Writing Style:
- Bullets / numbered over paragraphs — never a multi-sentence paragraph where a list works; one fact per bullet, one action per step. Long paragraph → split into bullets or numbered points.
- Cut filler + articles; fewest words per idea.
- Arrows (`→`) for transitions, flows, mappings — not prose.
- Deltas only — state what changes; don't re-justify unchanged behaviour.

Produce:

- **Technical Gap / Problem Statement** — 1–2 sentences: the specific deficiency or absent capability, stated concretely.
- **Motivation** — what this unlocks or improves.
- **Scope** — bullet list of specific files, modules, config files, pipelines, or layers.
- **Technical Approach** — numbered steps. Tooling/DX changes may include: adding config files, installing packages, wiring CI jobs, updating dev setup docs, enabling flags — not only source edits.
- **Trade-offs** — honest, not a sales pitch:
  - **Wins** — what the approach buys (decoupling, enforceability, testability, …).
  - **Costs** — what the team lives with (boilerplate, indirection, runtime overhead, maintenance/drift risk).
- **Migration Plan** — **Data migration** bullet + fenced ```sql **Cutover** + **Rollback** DDL, mirroring the TDD's Migration Plan. Carry over whatever the **Migration** blocking question surfaced. Migrations run manually against the target DB (deploy auto-applies none) — author the SQL inline here, not committed. Verify locally during implementation. Nothing migrates → single bullet `N/A — no data migration required`.
- **Affected Codebases** — each codebase + area of change.
- **Definition of Done**:
  - Always: "All existing tests pass" + "No user-visible behavior change".
  - Additive tooling → a "new tooling runs without error" check (e.g. "Storybook dev server starts without errors", "CI pipeline completes under N minutes", "All engineers can run the test suite locally without extra setup").
  - Specifics from the problem + approach (e.g. "No circular dependencies in X module", "Response time for Y endpoint unchanged").

## Draft + Approve Loop

`$DRAFT = .claude/state/refactor-spec-create.md` → write every **Design Refactoring Spec** field via the `issue-refactoring` template.

`AskUserQuestion`:

> Draft `<$DRAFT>` — proposed refactor spec:
> - **Approve** → create the GitHub issue
> - **Adjust** → describe change → re-run **Design Refactoring Spec** → rewrite draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → append to **Discovery Dialog** / **Design Refactoring Spec** inputs → re-run **Design Refactoring Spec** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Create Refactoring Issue**

## Create Refactoring Issue

Via `github` skill, create an issue in the **orchestrator repo**:

- **Title**: `[Refactor] <short imperative description>`
- **Label**: `refactoring`
- **Body**: `issue-refactoring` template (via `github-templates` skill) with all **Design Refactoring Spec** fields.
- **Board**: **Register Issue on Board** — Type `Refactor`, Status `Todo`. No Sprint.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Refactor spec filed. Next:

- `/refactor implement the spec`