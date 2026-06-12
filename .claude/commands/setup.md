---
name: setup
description: One-off project setup navigator — pick mode (all / project-config / board / product / design), run resume check, then dispatch to the mode file.
tools: Read, AskUserQuestion, Bash
---

# Setup — Navigator

## Workflow
1. Pick Mode
2. Resume Check
3. Dispatch

## Pick Mode

Ask via `AskUserQuestion` → `$MODE`:

- **All** — full first-time setup (project-config → board → product) in sequence.
- **Project Config** — generate `.claude/skills/project-config/SKILL.md` (codebases, tech stack, migration rules).
- **Board** — create GitHub labels, then provision the GitHub Project board (Status / Type / Sprint fields).
- **Product** — generate `PRODUCT.md` at the repo root.

## Resume Check

Map `$MODE` → run key:

| Mode | run_key |
|------|---------|
| All | `all` |
| Project Config | `project-config` |
| Labels | `labels` |
| Board | `board` |
| Product | `product` |

Look up resume state (`workflow = setup`, `run_key = <mapped key>`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from mode file's first step.
- **Cancel** → abort; leave state untouched.

## Dispatch

**Single mode** (`project-config` / `board` / `product` / `design`): read `setup/<$MODE>.md` → follow from first step.

**All mode** — read + follow each in sequence:
1. `setup/project-config.md`
2. `setup/board.md`
3. `setup/product.md`

Each runs from its first step. Subcommand exits early (artifact exists, user chose Skip) → proceed to next. After all three → output a summary of artifacts written vs skipped. All three exit early → output `All artifacts already exist — nothing to generate.`
