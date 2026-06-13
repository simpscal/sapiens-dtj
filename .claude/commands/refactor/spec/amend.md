---
name: refactor:spec:amend
description: Revise an existing refactor spec against new findings — load context, rebuild the mental model, re-explore if scope expands, then update the issue. Covers any technical system improvement: code quality, tooling, DX, CI/infrastructure, observability, documentation systems, or capability expansions that do not change user-visible behaviour.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Refactor Spec — Amend

`$ISSUE_NUMBER` supplied by the navigator.

## Workflow
1. Fetch Refactor Issue
2. Reconstruct the Mental Model
3. Open Amendment Dialog
4. Re-explore (if scope expands)
5. Revise Spec
6. Draft + Approve Loop
7. Update Issue
8. Next Step

## Fetch Refactor Issue

Via `github` skill, read issue `#$ISSUE_NUMBER` in full (title, body, labels). Missing `refactoring` label → halt `⛔ Issue #N is not a refactoring task (label refactoring missing).`

Hold as **$REFACTOR**. Extract from body:

- **Problem Statement**
- **Motivation**
- **Scope** (bullet list)
- **Technical Approach** (numbered steps)
- **Trade-offs** (wins / costs)
- **Affected Codebases**
- **Definition of Done** (checklist)

## Reconstruct the Mental Model

Work through all loaded material silently — no output this step. From $REFACTOR, establish:

- the pain point driving the refactor
- files, modules, or layers in scope
- the sequence of steps in the current Technical Approach
- what "done" looks like — which DoD items are objective vs subjective
- what was explicitly excluded or constrained

Complete when — without re-reading — you can:

- state the goal
- name every file / module in scope
- summarise every approach step
- flag what breaks if scope shifts

Then output:

> Technical Lead active — refactor #$ISSUE_NUMBER. Full knowledgebase loaded: [list what was loaded]. Ready to discuss changes or alternatives.

## Open Amendment Dialog

Ask via `AskUserQuestion` → **$CHANGE_INPUT**: `What changed, and why? Describe the problem with the current refactor spec and the direction you want — or share options to evaluate.`

Use `$CHANGE_INPUT` to discuss — answer trade-off questions, surface constraints + risks from the mental model — until the direction is confirmed.

## Re-explore (if scope expands)

Change stays within existing Scope → skip. Confirmed change adds a codebase not in **Affected Codebases**, or expands into unmapped modules → spawn one `Explore` subagent per newly-in-scope area **in parallel**, each comparing against `main` so partial in-flight work + superseded prior decisions stay out of the revision.

**Brief each subagent** — hand it the confirmed change + the newly-in-scope area it owns. It forms own hypotheses, picks what to read — orient, don't checklist. Per-role starting points (orientation, not checklist):

- **backend** — code, services, patterns in the change's path.
- **frontend** — components, hooks, state, shared primitives in the path.
- **infrastructure** — IaC resources, modules, config in the path.

**Stop when** the subagent can, for its area:

- name the closest existing analogue/pattern per change (with file path)
- state the convention to follow or diverge from
- name where each new or changed piece lives

Can't resolve from code or tooling → blocking question, not a reason to keep probing.

**Verify, don't assume** — confirm each claimed analogue/pattern by reading or grepping the real file, never from naming. Infrastructure → query live state per resource via the cloud/platform API (running/stopped, attached/detached, exists/missing, rule present/absent) — don't assume what tooling can confirm.

**Return** per finding: file path, symbol name, current pattern, what changes and why; infrastructure adds live-state findings.

## Revise Spec

Baseline = current spec. Output the **full revised spec**, not a diff.

Ground every technical claim against `main`, never in-flight branch state → superseded prior decisions don't leak into the revision.

Per section → decide whether the confirmed change affects it → keep unchanged sections exactly, rewrite only affected parts.

Revised body reads as if authored fresh:

- present tense
- replace superseded Problem / Approach / Trade-off content in place
- drop obsolete steps, costs, or decisions rather than annotating them
- no change-narration (no "previously/now", "no longer", "changed from")

Change Summary lives only in the draft for review — never in the issue body.

| Field | When to revise |
|-------|----------------|
| Problem Statement | Pain point reframed or sharpened |
| Motivation | What the refactor unlocks shifted |
| Scope | Files/modules added or removed |
| Technical Approach | Steps reordered, replaced, or added |
| Trade-offs | Approach changed, or a new cost surfaced |
| Migration Plan | Data migration, cutover, or rollback added/changed/obsolete (set `N/A — no data migration required` when obsolete) |
| Affected Codebases | Codebase added or dropped |
| Definition of Done | New objective criterion, or one no longer applies |

## Draft + Approve Loop

`$DRAFT = .claude/state/refactor-spec-amend-<$ISSUE_NUMBER>.md` → write a **Change Summary** header + the full revised issue body.

`AskUserQuestion`:

> Draft `<$DRAFT>` — revised refactor spec:
> - **Approve** → update the GitHub issue
> - **Adjust** → describe change → re-run **Revise Spec** → rewrite draft
> - **Cancel** → abort; draft stays on disk

- **Adjust** → `$ADJUSTMENT` → append to `$CHANGE_INPUT` → re-run **Revise Spec** → overwrite `$DRAFT` → re-prompt
- **Cancel** → halt
- **Approve** → **Update Issue**

## Update Issue

1. Via `github` skill, update body of `#$ISSUE_NUMBER` with the revised spec (`issue-refactoring` template via `github-templates` skill).
2. Delete `$DRAFT` via `Bash: rm`.
3. Report: `Refactor #<N> amended. Scope: <delta>. Approach: <delta>. DoD: <delta>.`

## Next Step

Refactor spec revised. Next:

- `/refactor implement the revised spec`