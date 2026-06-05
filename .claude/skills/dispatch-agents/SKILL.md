---
name: dispatch-agents
description: Use when implementing a user story, bug, or technical work item by fanning out parallel agents across the backend, frontend, and devops domains. Loads context, builds the `<context>` XML block, spawns agents in parallel, and collects structured results. Do NOT use for: branch creation, commits, PRs, issue comments, notifications, or any orchestration outside the dispatch itself — the caller owns all of that. Pairs with the `technical-design` skill (consumes its TDD output) and the `user-stories` skill (consumes the ACs).
tools: Agent, Read
---

# Dispatch Agents

Flow: Pre-flight → Spawn → Collect. When `delta` is present, `<constraints>` carries it and agents implement only the delta rows (see Delta Rendering).

Never read from external systems mid-run — everything an agent needs is passed inline in its `<context>`.

## Inputs

| Parameter | Required | Notes |
|-----------|----------|-------|
| `issue` | yes | `{number, title, body}` — the story or bug being implemented. |
| `codebases` | yes | `[{name, role, path}]` — resolved from project-config. |
| `agents` | yes | `all` / explicit domain list / `from-codebases-field`. |
| `tdd_issue` | no | `{number, body}` — TDD issue for the sprint. Absent for bugs without TDD. |
| `design_context` | no | Frontend design context — Storybook surface stories for the surfaces the story touches. Frontend-only. |
| `decisions` | no | `<decisions>` payload (`type` + verbatim content) — investigation or plan. **Replaces TDD when provided** (see Decision Source Precedence). |
| `delta` | no | `{satisfied, to_add, to_remove, to_rewrite, affected_files}` — agents constrain work to the delta. |

## Pre-flight

Validate before spawning. **Blocker** → return immediately with `status: precheck_failed` and the reason; do not spawn. **Warning** → continue, include in `$AGENT_RESULTS.warnings`.

| Check | On failure |
|-------|-----------|
| `issue.body` contains `## Acceptance Criteria` | Blocker — `"issue missing acceptance criteria"` |
| Resolved agent list non-empty | Blocker — `"no agents resolved"` |
| Every `codebases` entry has a `role` matching a resolvable agent (`backend`, `frontend`, `devops`) | Warning — skip unmappable entries, list them |
| `agents: from-codebases-field` and the Affected Codebases bullet list is present/parseable | Blocker — `"affected codebases not parseable"` |
| `tdd_issue` absent and `decisions` absent and `issue` not a bug | Warning — `"dispatching without TDD or decisions on a non-bug issue"` |
| `design_context` provided but no frontend agent resolved | Warning — `"design_context provided but no frontend agent dispatched"` |

## Decision Source Precedence

Every agent receives exactly one `<decisions>` block, sourced in strict order:

1. **`decisions` present** → use verbatim with the caller's `type` (`investigation`, `plan`, etc.).
2. **`tdd_issue` present** → pass full `tdd_issue.body` verbatim, emit `type="tdd"`.
3. **Neither** → emit `type="none"`. Acceptable for bugs with sufficient `issue.body`; surface a warning in `$AGENT_RESULTS`.

## Context Protocol

Build one `<context>` XML block per agent. Same shape for every domain; omit sections that don't apply (no empty `<design_context/>` or `<constraints/>` tags). `<acceptance_criteria>` is the verbatim checklist from `issue.body`, never paraphrased.

```xml
<context>
  <requirements>
    <story>[work-item statement from issue.body]</story>
    <acceptance_criteria>
- [ ] [AC 1]
- [ ] [AC 2]
    </acceptance_criteria>
  </requirements>
  <decisions type="tdd|investigation|plan|none">
    [verbatim TDD slice, investigation fields, plan sections, or "none"]
  </decisions>
  <design_context>
    <surface slug="..." route="...">
      <story path="[relative path to Storybook story file]">
        [verbatim Storybook story file content]
      </story>
    </surface>
    <!-- repeat for each matched surface; omit entirely for backend, devops, and bug fixes -->
  </design_context>
  <constraints>
    [omit entirely if no delta; otherwise see Delta Rendering]
  </constraints>
</context>
```

### Delta Rendering

When `delta` is provided, render `<constraints>` as:

```xml
<constraints>
  <delta>
    <satisfied>[file list]</satisfied>
    <to_add>[items]</to_add>
    <to_remove>[items]</to_remove>
    <to_rewrite>[items]</to_rewrite>
    <affected_files>[file list]</affected_files>
  </delta>
  <instruction>Implement the delta only — preserve satisfied work, add to_add items, revert to_remove items, rewrite to_rewrite items. Do not modify files outside affected_files unless a delta row explicitly requires it.</instruction>
</constraints>
```

## Spawn

Spawn all resolved agents in **one parallel message**.

## Collect

Each agent returns exactly one of:

| Return | Meaning | Skill action |
|--------|---------|--------------|
| `<result>` with `<files_changed>` | Domain implementation complete | Record `status: complete` |
| `<no_work>` with `<reason>` | No work needed | Record `status: no_work` with the reason |
| `<blocked>` with `<reason>` | Cannot proceed | Record `status: blocked` with the reason; do not post anywhere |

If one agent blocks, let the others finish — collect and return all results. If every agent returns `<no_work>`, add warning `"all agents reported no work — verify dispatch was appropriate"`.

## Returns

`$AGENT_RESULTS`:

```yaml
status: complete | partial | blocked | no_work | precheck_failed
results:
  - agent: backend|frontend|devops
    codebase: <name from codebases input>
    status: complete | no_work | blocked
    files_changed: [<paths>]   # present when status: complete
    reason: <string>           # present when status: no_work or blocked
warnings: [<string>, ...]      # pre-flight + collection warnings
```

Top-level `status`:

- `precheck_failed` — pre-flight blocker; `results` empty.
- `complete` — every agent returned `<result>`.
- `no_work` — every agent returned `<no_work>`.
- `blocked` — at least one `<blocked>`, no `<result>`.
- `partial` — mixed: at least one `<result>` and at least one `<blocked>` or `<no_work>`.

## Constraints

- Never fetch, read, or re-derive context from inside spawned agents — pass everything inline via `<context>`.
- Never post comments, open issues, or notify any channel — return blocked reasons in `$AGENT_RESULTS`.
- Never spawn agents sequentially — always one parallel message.
- Never cancel in-flight agents when one returns `<blocked>` — let them finish and collect.
- Never emit empty optional XML sections — omit them.
- Never paraphrase ACs — pass the verbatim checklist from `issue.body`.
- Filesystem: read-only on `issue`, `tdd_issue`, project-config; no writes from this skill.
