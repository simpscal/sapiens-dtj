---
name: setup
description: Natural-language entry point for project setup — say what you want and it routes to the right phase. Full setup runs all phases in sequence.
argument-hint: "['set up everything', 'project config', 'provision the board', 'generate PRODUCT.md', 'design system']"
tools: Read, AskUserQuestion
---

# /setup — Setup Workflow Router

Resolve `$ARGUMENTS` → one setup phase (or the full sequence). Execute the existing `setup/<phase>.md` workflow inline.

## Interpret Intent

Resolve `$ARGUMENTS` → phase:

| Your words contain… | Run |
|---|---|
| all / everything / full setup / from scratch / initialize / bootstrap | **all** *(sequence — see Dispatch)* |
| project config / codebases / stack / migration rules | `project-config` |
| board / labels / project board / github project / tracking | `board` |
| product / PRODUCT.md / vision / value prop / target users | `product` |
| design system / theme / DESIGN_THEME / tokens / storybook / component stories / style guide / visual / UI direction / atmosphere | `design-system` |

Empty input or unclear phase → ask **one** `AskUserQuestion` (All / Project Config / Board / Product / Design System) → resolve.

Echo before running: `▶ /setup <phase>` (or `▶ /setup all`).

## Dispatch

For each phase: read `.claude/commands/setup/<phase>.md`, execute its workflow from the first step, interview the user via `AskUserQuestion` exactly as the file directs.

**Single phase** → run the resolved phase → report the artifact written or skipped.

**All** → run phases **one at a time, in order**, finishing each before the next:

1. `project-config`
2. `board`
3. `product`
4. `design-system`

Sequence respects ordering — config first; product before design-system so the theme's atmosphere can draw on product context; design-system last — it generates the theme, then conforms the frontend to it. Each phase file carries its own existence-check gate (Skip / Regenerate), so re-running `all` skips completed artifacts and fills only the gaps.

## Summarize

After the run, output artifacts written vs skipped — one line per phase. All phases skipped in an `all` run → `All artifacts already exist — nothing to generate.`
