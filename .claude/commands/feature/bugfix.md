---
name: feature:bugfix
description: Natural-language entry point for an in-sprint bug — say what you want and it runs the proper /feature:bugfix:* sub-command. For bugs found during sprint development; ships on the sprint branch.
argument-hint: "[plain English — e.g. 'topbar overflows on the new dashboard', 'write ACs for 42', 'fix 42']"
tools: Read, Bash, AskUserQuestion
---

# /feature:bugfix — In-Sprint Bugfix Router

Resolve `$ARGUMENTS` → one sub-command. For a bug found in **sprint development** — fix lives on the sprint branch, closes with the sprint at `/feature:release`. Production bug shipped to `main` → use `/bugfix`.

## Interpret Intent

Resolve `$ARGUMENTS` → stage + args. Number in text = bug issue#; else infer the single in-flight in-sprint bug from board / `.claude/state` via `github` skill.

| Your words contain… | Run |
|---|---|
| report / new bug / it's broken / error / crash / 500 *(a description, no existing issue)* | `/feature:bugfix:report <description>` |
| story / ACs / acceptance criteria / reproduce steps *(for an existing bug)* | `/feature:bugfix:story <bug#>` |
| fix / implement / patch / resolve | `/feature:bugfix:implement <bug#> [intent]` |
| merge *(land the fix on the sprint branch)* | `/feature:merge <bug#>` |

Land: `/feature:merge <bug#>` → sprint branch. Closes with sprint at `/feature:release`. No per-bug pre-release/release.

Empty input or unclear stage → ask **one** `AskUserQuestion` for the stage (fold in bug# if it can't be inferred) → run resolved command.

Echo before running: `▶ /feature:bugfix:<stage> <args>`.
