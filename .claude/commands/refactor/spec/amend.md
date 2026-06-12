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

Complete when you can state the goal, name every file/module in scope, summarise every approach step, and flag what breaks if scope shifts — without re-reading. Then output:

> Technical Lead active — refactor #$ISSUE_NUMBER. Full knowledgebase loaded: [list what was loaded]. Ready to discuss changes or alternatives.

## Open Amendment Dialog

Ask via `AskUserQuestion` → **$CHANGE_INPUT**: `What changed, and why? Describe the problem with the current refactor spec and the direction you want — or share options to evaluate.`

Use `$CHANGE_INPUT` to discuss — answer trade-off questions, surface constraints + risks from the mental model — until the direction is confirmed.

## Re-explore (if scope expands)

Confirmed change adds a codebase not in **Affected Codebases**, or expands into unmapped modules → spawn one `Explore` subagent per newly-in-scope area **in parallel**. Per-role brief:

- **Backend**: files, classes, services, patterns to change; coupling points, duplication, structural issues. Return: file paths, class/method names, current pattern, what changes and why.
- **Frontend**: components, hooks, utilities, state management affected; shared code, duplication, abstraction gaps. Return: file paths, component names, current pattern, what changes and why.
- **Infrastructure**: IaC resources, modules, config affected. **Query live state** per newly-in-scope resource via the relevant cloud/platform API (running/stopped, attached/detached, exists/missing, rule present/absent) — don't assume what tooling can confirm. Return: file paths, resource names, current pattern, what changes and why; plus live state findings.

Change stays within existing Scope → skip.

## Revise Spec

Baseline = current spec. Output the **full revised spec**, not a diff.

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