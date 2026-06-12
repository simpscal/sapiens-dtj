---
name: feature:refactor
description: Natural-language entry point for an in-sprint refactor — say what you want and it runs the proper /feature:refactor:* sub-command. For refactors scoped to an active sprint; ships on the sprint branch.
argument-hint: "[plain English — e.g. 'tidy the dashboard data layer', 'implement 51']"
tools: Read, Bash, AskUserQuestion
---

# /feature:refactor — In-Sprint Refactor Router

Resolve `$ARGUMENTS` → one sub-command. For a refactor scoped to an **active sprint** — lives on the sprint branch, closes with the sprint at `/feature:release`. **Standalone** refactor shipped to `main` → use `/refactor`.

## Interpret Intent

Resolve `$ARGUMENTS` → stage + args. Number in text = refactor issue#; else infer the single in-flight in-sprint refactor from board / `.claude/state` via `github` skill.

| Your words contain… | Run |
|---|---|
| spec / plan / scope / new refactor / clean up / tidy / restructure / tech debt *(a description, no existing issue)* | `/feature:refactor:spec <description>` |
| implement / do / apply / carry out | `/feature:refactor:implement <issue#> [intent]` |
| merge *(land the refactor on the sprint branch)* | `/feature:merge <issue#>` |

Land: `/feature:merge <issue#>` → sprint branch. Closes with sprint at `/feature:release`. No per-refactor pre-release/release.

Empty input or unclear stage → ask **one** `AskUserQuestion` for the stage (fold in issue# if it can't be inferred) → run resolved command.

Echo before running: `▶ /feature:refactor:<stage> <args>`.
