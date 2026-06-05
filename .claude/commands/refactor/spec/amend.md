---
name: refactor:spec:amend
description: Revise an existing refactor spec against new findings — load context, rebuild the mental model, re-explore if scope expands, then update the issue. Covers any technical system improvement: code quality, tooling, DX, CI/infrastructure, observability, documentation systems, or capability expansions that do not change user-visible behaviour.
tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Refactor Spec — Amend

`$ISSUE_NUMBER` is supplied by the navigator.

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

Via the `github` skill, read issue `#$ISSUE_NUMBER` in full — title, body, labels.

Guard: must have `refactoring` label. If absent → stop:

> ⛔ Issue #N is not a refactoring task (label `refactoring` missing).

Hold as **$REFACTOR**. Extract from body:

- **Problem Statement**
- **Motivation**
- **Scope** (bullet list)
- **Technical Approach** (numbered steps)
- **Affected Codebases**
- **Definition of Done** (checklist)

## Reconstruct the Mental Model

Work through all loaded material silently — no output in this step. From $REFACTOR, establish:

- The pain point driving the refactor.
- Files, modules, or layers in scope.
- The sequence of steps in the current Technical Approach.
- What "done" looks like — which DoD items are objective vs subjective.
- What was explicitly excluded or constrained.

Complete when: you can state the refactor goal, name every file or module in scope, summarise every step of the approach, and flag what would break if scope shifts — without re-reading.

When complete, activate using this format:

> Technical Lead active — refactor #$ISSUE_NUMBER. Full knowledgebase loaded: [list what was loaded]. Ready to discuss changes or alternatives.

## Open Amendment Dialog

Ask via `AskUserQuestion`. Hold as **$CHANGE_INPUT**: `What changed, and why? Describe the problem with the current refactor spec and the direction you want to go — or share options you'd like to evaluate.`

Use `$CHANGE_INPUT` to discuss — answer trade-off questions, surface constraints from the mental model, flag risks from loaded material — until the direction is confirmed.

## Re-explore (if scope expands)

If the confirmed change adds a codebase not previously listed in **Affected Codebases**, or expands scope into modules not yet mapped:

Spawn one `Explore` subagent per newly-in-scope area **in parallel**. Per-role brief:

**Backend**: files, classes, services, patterns to change; coupling points, duplication, structural issues. Return: file paths, class/method names, current pattern, what changes and why.

**Frontend**: components, hooks, utilities, state management affected; shared code, duplication, abstraction gaps. Return: file paths, component names, current pattern, what changes and why.

**Infrastructure**: Terraform resources, modules, config affected. Return: file paths, resource names, current pattern, what changes and why.

Skip if the change stays within the existing Scope.

## Revise Spec

Use the current refactor spec as baseline. Output the **full revised spec**, not a diff.

For each section, decide whether the confirmed change affects it — keep unchanged sections exactly, rewrite only affected parts.

| Field | When to revise |
|-------|----------------|
| Problem Statement | Pain point reframed or sharpened |
| Motivation | What the refactor unlocks has shifted |
| Scope | Files/modules added or removed |
| Technical Approach | Steps reordered, replaced, or added |
| Affected Codebases | Codebase added or dropped |
| Definition of Done | New objective criterion or one no longer applies |

## Draft + Approve Loop

Compute `$DRAFT = .claude/state/refactor-spec-amend-<$ISSUE_NUMBER>.md`.

Write `$DRAFT` with a **Change Summary** header followed by the full revised issue body:

Ask via `AskUserQuestion`:

> Draft at `<$DRAFT>` — revised refactor spec. Choose:
>
> - **Approve** — update the GitHub issue.
> - **Adjust** — describe what to change; re-run **Revise Spec** with appended feedback; rewrite the draft.
> - **Cancel** — abort; leave the draft on disk.

- **Adjust** — ask via `AskUserQuestion` for `$ADJUSTMENT`. Append to `$CHANGE_INPUT`. Re-run **Revise Spec**. Overwrite `$DRAFT`. Re-prompt.
- **Cancel** — halt.
- **Approve** — proceed to **Update Issue**.

## Update Issue

1. Via the `github` skill, update the body of issue `#$ISSUE_NUMBER` with the revised spec (rendered from the `issue-refactoring` template via the `github-templates` skill).
2. Delete `$DRAFT` via `Bash: rm`.
3. Report: `Refactor #<N> amended. Scope: <delta>. Approach: <delta>. DoD: <delta>.`

## Next Step

Refactor spec revised. Print the next command:

- `/refactor:implement <refactor_issue>` — implement the revised spec
