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

Ask via `AskUserQuestion`. Hold as `$MODE`:

- **Create** — draft a new refactor spec.
- **Amend** — revise an existing refactor spec in light of new findings.

## Gather Primary Args

- **Create**: no args.
- **Amend**: ask via `AskUserQuestion` for `$ISSUE_NUMBER` (positive integer). Read the issue. Reject if missing `refactoring` label: `⛔ Issue #$ISSUE_NUMBER is not a refactoring task (label refactoring missing).` and re-ask.

## Resume Check

Look up resume state (`workflow = refactor`, `run_key = spec-<$MODE>-<$ISSUE_NUMBER|new>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from the first step of the mode file.
- **Cancel** — abort; leave state untouched.

## Dispatch

Read `refactor/spec/<$MODE>.md` and follow it from its first step. `$ISSUE_NUMBER` (Amend) is already in scope.
