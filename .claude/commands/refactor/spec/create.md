---
name: refactor:spec:create
description: Draft a new refactor spec — discovery dialog, parallel codebase exploration, design, draft + approve gate, then file as an issue. Covers any technical system improvement: code quality, tooling, DX, CI/infrastructure, observability, documentation systems, or capability expansions that do not change user-visible behaviour.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Refactor Spec — Create

## Workflow
1. Discovery Dialog
2. Explore Codebase
3. Resolve Blocking Questions
4. Design Refactoring Spec
5. Draft + Approve Loop
6. Create Refactoring Issue
7. Next Step

## Discovery Dialog

Ask via `AskUserQuestion` to collect in a single call:

- **What is the technical goal?** — the improvement driving this work, remediation (tech debt, coupling, performance, tooling/DX gap, missing CI check, observability gap) or additive (new tooling, docs system, capability expansion). Be specific about what is wrong or missing today.
- **What is the scope?** — modules, layers, config files, pipelines, or files affected.
- **Definition of done** — what should be true after the work that is not true now.

If any answer is too vague, fire a follow-up `AskUserQuestion`.

## Explore Codebase

Spawn one `Explore` subagent per in-scope codebase **in parallel** with a targeted brief. Transformative work (restructuring existing code/config) looks for what must change; additive work (new capability) looks for what is missing.

**Backend** (if in scope):

- Find files, classes, services, patterns to change; coupling points, duplication, structural issues.
- Additive: identify what is absent and where to introduce it.
- Return: file paths, class/method names, current pattern, what changes or is added and why.

**Frontend** (if in scope):

- Find components, hooks, utilities, state management affected; shared code, duplication, abstraction gaps.
- Additive: identify missing capabilities and where to introduce them.
- Return: file paths, component names, current pattern, what changes or is added and why.

**Infrastructure** (if in scope):

- Find Terraform resources, modules, config affected.
- Additive: identify missing pieces and where they belong.
- Return: file paths, resource names, current pattern, what changes or is added and why.

**Tooling and DX** (if in scope):

- Find config files, CI definitions, build scripts, manifests, tool setup files affected; missing/misconfigured tooling or capability gaps.
- Return: file paths, tool names, current state, what is missing or changes and why.

## Resolve Blocking Questions

Try to answer each question from the exploration findings first. Raise only questions the codebase cannot answer. Collect all blockers and present in a single `AskUserQuestion` call.

| Category | Decisions to resolve |
|----------|----------------------|
| **Nature of change** | Is this additive (new tooling/setup with no existing code changed), transformative (existing code restructured), or mixed? This determines which downstream rows apply. |
| **Scope boundary** | Any files or modules to exclude even if they look related? |
| **Backward compatibility** | (Skip for purely additive work.) Must public contracts (API, events, DB schema, CI script interfaces, published npm scripts, env variable names) remain unchanged during and after the refactor? |
| **Migration** | Any data, state, configuration, or environment to migrate as part of this change (e.g., DB data, config file format change, CI env vars, lockfile regeneration, developer machine setup steps)? |
| **Dependencies** | Does any other in-progress work share the affected files? Risk of conflicts? |
| **Non-functional targets** | Any latency, throughput, memory, build time, CI pipeline duration, or developer-tooling performance goals this refactor must hit or preserve? |

Skip categories that clearly do not apply.

## Design Refactoring Spec

Using exploration findings, draft the full refactoring spec. Do NOT write implementation code.

Produce:

- **Technical Gap / Problem Statement** — 2–3 sentences: the specific deficiency in existing code OR the absent capability, stated concretely and technically.
- **Motivation** — what this refactor unlocks or improves once complete.
- **Scope** — bullet list of specific files, modules, config files, pipelines, or layers in scope.
- **Technical Approach** — numbered steps describing how to execute the refactor in sequence. For tooling/DX changes steps may include: adding config files, installing packages, wiring CI jobs, updating developer setup docs, or enabling flags — not only source-code edits.
- **Affected Codebases** — list each codebase and the area of change.
- **Definition of Done**:
  - Always include: "All existing tests pass" and "No user-visible behavior change".
  - For additive tooling work, also include a "new tooling runs without error" check appropriate to the tool (e.g., "Storybook dev server starts without errors", "CI pipeline completes under N minutes", "All engineers can run the test suite locally without additional setup steps").
  - Add specifics derived from the problem and approach (e.g., "No circular dependencies in X module", "Response time for Y endpoint unchanged").

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/refactor-spec-create.md`.

Write `$DRAFT` with every **Design Refactoring Spec** field rendered via the `issue-refactoring` template.

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>` — proposed refactor spec. Choose:
>
> - **Approve** — create the GitHub issue.
> - **Adjust** — describe what to change; re-run **Design Refactoring Spec** with the appended feedback; rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`. Append to the **Discovery Dialog** / **Design Refactoring Spec** inputs. Re-run **Design Refactoring Spec**. Overwrite `$DRAFT`. Re-prompt
- **Cancel** — halt.
- **Approve** — proceed to **Create Refactoring Issue**.

## Create Refactoring Issue

Via the `github` skill, create a GitHub issue in the **orchestrator repo**:

- **Title**: `refactor: <short imperative description>`.
- **Label**: `refactoring`.
- **Body**: render the `issue-refactoring` template via the `github-templates` skill with all fields from **Design Refactoring Spec**.
- **No milestone** — standalone, not sprint-tied.

Delete `$DRAFT` via `Bash: rm`.

## Next Step

Refactor spec filed. Print the next command:

- `/refactor:implement <refactor_issue>` — implement the spec
