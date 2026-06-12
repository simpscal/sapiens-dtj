---
name: feature
description: Natural-language entry point for the feature workflow — say what you want and it runs the proper /feature:* sub-command.
argument-hint: "[plain English — e.g. 'start checkout revamp', 'write the stories', 'implement 42', 'ship sprint 3']"
tools: Read, Bash, AskUserQuestion
---

# /feature — Feature Workflow Router

Resolve `$ARGUMENTS` → one feature sub-command. Normal gates apply (not autonomous `/auto`). Full A→Z autonomous run → `/auto`.

## Interpret Intent

Resolve `$ARGUMENTS` → stage + args. Number in text = story#/sprint#/requirement#; else infer target from board (active sprint, its requirement) via `github` skill.

| Your words contain… | Run |
|---|---|
| start / new feature / requirement / kick off / build *(a description of new work)* | `/feature:requirement:create <description>` |
| change / amend / adjust the requirement *(+ delta)* | `/feature:requirement:amend <req#> <delta>` |
| stories / break down / decompose / acceptance criteria | `/feature:stories <req#>` *(navigator — create or regenerate)* |
| design / screens / UI / storybook / surfaces | `/feature:design <sprint>` *(navigator)* |
| technical design / TDD / architecture / tech stories | `/feature:technical-design <sprint>` *(navigator)* |
| implement / build / code *(a story)* | `/feature:implement <story#> [intent]` |
| bug / broken / error *(found during this sprint)* | `/feature:bugfix <intent>` *(router — report / story / implement)* |
| refactor / clean up / tidy / tech debt *(within this sprint)* | `/feature:refactor <intent>` *(router — spec / implement)* |
| merge *(a story, in-sprint bug, or in-sprint refactor)* | `/feature:merge <issue#>` |
| pre-release / prepare release / readiness / ready to ship | `/feature:pre-release <sprint>` |
| release / ship / close / finish the sprint | `/feature:release <sprint>` |

Empty input or unclear stage → ask **one** `AskUserQuestion` for the stage (fold in target# if it can't be inferred) → run resolved command.

Echo before running: `▶ /feature:<stage> <args>`.
