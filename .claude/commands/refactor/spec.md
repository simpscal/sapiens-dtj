---
name: refactor:spec
description: Refactor spec navigator — pick mode (create / amend), gather inputs, run resume check, then dispatch to the mode file.
tools: Read, AskUserQuestion, Bash
---

# Refactor Spec — Navigator

## Workflow
1. Pick Mode
2. Gather Primary Args
3. Resume Check
4. Dispatch

## Pick Mode

Ask via `AskUserQuestion` → `$MODE`:

- **Create** — draft a new refactor spec.
- **Amend** — revise an existing refactor spec against new findings.

## Gather Primary Args

- **Create**: no args.
- **Amend**: ask via `AskUserQuestion` → `$ISSUE_NUMBER` (positive integer) → read issue. Missing `refactoring` label → `⛔ Issue #$ISSUE_NUMBER is not a refactoring task (label refactoring missing).` → re-ask.

## Resume Check

Look up resume state (`workflow = refactor`, `run_key = spec-<$MODE>-<$ISSUE_NUMBER|new>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from mode file's first step.
- **Cancel** → abort; leave state untouched.

## Dispatch

Read `refactor/spec/<$MODE>.md` → follow from first step. `$ISSUE_NUMBER` (Amend) in scope.
