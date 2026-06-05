---
name: checkpoint
description: Use to read, write, or clear workflow resume state under `.claude/state/<workflow>.json`. Auto-invoke at workflow entry (read + resume prompt) and after each step completes (write). Single source of truth for resume across feature, bugfix, refactor.
tools: Read, Write, Edit, Bash
---

## File Layout

```
.claude/state/
  feature.json
  bugfix.json
  refactor.json
```

## Schema

```json
{
  "_version": 1,
  "<run-key>": {
    "stage": "<stage-name>",
    "primary_arg": "<value>",
    "current_phase": "<phase-id>",
    "current_step": "<step-label>",
    "started": "<iso8601>",
    "updated": "<iso8601>",
    "completed_steps": ["step-1", "step-2"],
    "phases": {
      "<phase-id>": {
        "decisions": { "key": "value" },
        "artifacts": { "issues": [], "branches": [], "files": [] }
      }
    }
  }
}
```

- `_version = 1`. Halt with `"checkpoint schema version mismatch: file=<v> expected=1"` on mismatch.
- `<run-key>` = `<stage>-<primary-arg>`.
- `completed_steps` is append-only and ordered.
- Decision keys must be stable identifiers (e.g. `stack_choice`), not question text.

## Read

Read `.claude/state/<workflow>.json` (absent → `null`), validate `_version`, return the entry at `<run-key>` or `null`.

## Write

Inputs: `workflow`, `run_key`, `stage`, `primary_arg`, `phase`, `step`, optional `decisions`, optional `artifacts`.

Initialise the run-key entry if absent (`stage`, `primary_arg`, `started`, empty `completed_steps`/`phases`). Deep-merge `decisions` and `artifacts` into `phases[phase]` (arrays append + dedupe). Set `current_phase`, `current_step` (the **next** step), `updated`; append the previously-current step to `completed_steps` if not already there. Write back with 2-space indent.

## Clear

Inputs: `workflow`, `run_key`. Delete `obj[run_key]`; if only `_version` remains, `rm` the file, else write back. Absent file → no-op.

## List

Inputs: `workflow`. Return keys except `_version`, sorted by `updated` desc (absent file → `[]`).

## Resume Prompt

On checkpoint hit at workflow entry, always ask via `AskUserQuestion`:

```
Found checkpoint for <workflow> <run-key>:
  Stage:    <stage>
  Started:  <started>
  Last:     <updated> (<current_step>)
  Done:     step-1 → step-2 → step-3
  Next:     <next step from mode file>

Resume? [Y]es / [r]estart / [c]ancel
```

- **Resume** → load decisions/artifacts, jump to the step after `current_step`.
- **Restart** → `checkpoint:clear`, start from the beginning.
- **Cancel** → abort; leave the checkpoint untouched.

## Replay

- **Decisions** — before every `AskUserQuestion`, reuse `phases[<phase>].decisions[<key>]` if present; else ask and `checkpoint:write` the answer.
- **Artifacts** — before creating any issue/branch/file, reuse an existing reference in `phases[<phase>].artifacts` if present; else create and `checkpoint:write`.

## Step Boundary

After each step, `checkpoint:write` with `step` = the next step's label (or `"done"` after the final step), plus decisions and artifacts produced in the step just completed.

## On Completion

Write final state with `current_step = "done"`, `current_phase = "done"`. If the stage terminates the workflow (e.g. `feature:release`, `bugfix:release`), `checkpoint:clear` **all** run-keys for the same sprint/issue; otherwise leave the checkpoint in place.
