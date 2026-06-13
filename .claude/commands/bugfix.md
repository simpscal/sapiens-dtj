---
name: bugfix
description: Natural-language entry point for the bugfix workflow — say what you want and it runs the proper /bugfix:* sub-command.
argument-hint: "[plain English — 'login 500s' → 'ACs for 26' → 'fix 26' → 'ready? 26' → 'close 26']"
tools: Read, Bash, AskUserQuestion
---

# /bugfix — Bugfix Workflow Router

Resolve `$ARGUMENTS` → one bugfix sub-command. Normal gates apply (not autonomous `/auto`). Full A→Z autonomous run → `/auto`.

For **production** bugs (shipped to `main`). Bug found during sprint development → use `/feature:bugfix`.

## Interpret Intent

Resolve `$ARGUMENTS` → stage + args. Number in text = bug issue#; else infer the single in-flight bug from board / `.claude/state` via `github` skill.

| Your words contain… | Run |
|---|---|
| report / new bug / it's broken / error / crash / 500 *(a description, no existing issue)* | `/bugfix:report <description>` |
| story / ACs / acceptance criteria / reproduce steps *(for an existing bug)* | `/bugfix:story <bug#>` |
| fix / implement / patch / resolve | `/bugfix:implement <bug#> [intent]` |
| pre-release / readiness / ready to ship / verify | `/bugfix:pre-release <bug#>` |
| release / close / done / ship | `/bugfix:release <bug#>` |

Empty input or unclear stage → ask **one** `AskUserQuestion` for the stage (fold in bug# if it can't be inferred) → run resolved command.

Echo before running: `▶ /bugfix:<stage> <args>`.
