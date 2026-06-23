---
name: refactor
description: Natural-language entry point for the refactor workflow — say what you want and it runs the proper /refactor:* sub-command.
argument-hint: "['tidy payment module', 'implement 51', 'ready? 51', 'close 51']"
tools: Read, Bash, AskUserQuestion
---

# /refactor — Refactor Workflow Router

Resolve `$ARGUMENTS` → one refactor sub-command. Normal gates apply (not autonomous `/auto`). Full A→Z autonomous run → `/auto`.

For **standalone** refactors (shipped to `main`). Refactor scoped to an active sprint → use `/feature:refactor`.

## Interpret Intent

Resolve `$ARGUMENTS` → stage + args. Number in text = refactor issue#; else infer the single in-flight refactor from board / `.claude/state` via `github` skill.

| Your words contain… | Run |
|---|---|
| spec / plan / scope / new refactor / clean up / tidy / restructure / tech debt *(a description, no existing issue)* | `/refactor:spec:create <description>` |
| amend / revise / update the spec *(+ findings)* | `/refactor:spec:amend <issue#> <delta>` |
| implement / do / apply / carry out | `/refactor:implement <issue#> [intent]` |
| pre-release / readiness / ready | `/refactor:pre-release <issue#>` |
| release / close / done / ship | `/refactor:release <issue#>` |

Empty input or unclear stage → ask **one** `AskUserQuestion` for the stage (fold in issue# if it can't be inferred) → run resolved command.

Echo before running: `▶ /refactor:<stage> <args>`.
