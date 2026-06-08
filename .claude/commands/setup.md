---
name: setup
description: One-off project setup navigator — pick mode (all / project-config / labels / board / product / design), run resume check, then dispatch to the mode file.
tools: Read, AskUserQuestion, Bash
---

# Setup — Navigator

## Workflow
1. Pick Mode
2. Resume Check
3. Dispatch

## Pick Mode

Ask via `AskUserQuestion`. Hold as `$MODE`:

- **All** — run full first-time setup (project-config → labels → board → product) in sequence.
- **Project Config** — generate `.claude/skills/project-config/SKILL.md` (codebases, tech stack, migration rules).
- **Labels** — create GitHub labels from the project label set.
- **Board** — provision the GitHub Project board (Status / Type / Sprint fields).
- **Product** — generate `PRODUCT.md` at the repo root.

## Resume Check

Map `$MODE` to run key:

| Mode | run_key |
|------|---------|
| All | `all` |
| Project Config | `project-config` |
| Labels | `labels` |
| Board | `board` |
| Product | `product` |

Look up resume state (`workflow = setup`, `run_key = <mapped key>`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from the first step of the mode file.
- **Cancel** — abort; leave state untouched.

## Dispatch

**Single mode** (`project-config` / `labels` / `board` / `product` / `design`):
Read `setup/<$MODE>.md` and follow it from its first step.

**All mode**:
Read and follow each subcommand in sequence:
1. `setup/project-config.md`
2. `setup/labels.md`
3. `setup/board.md`
4. `setup/product.md`

Each subcommand runs from its first step. If a subcommand exits early (artifact exists and user chose Skip), proceed to the next. After all four complete, output a summary of which artifacts were written vs. skipped. If all four exit early, output: `All artifacts already exist — nothing to generate.`
