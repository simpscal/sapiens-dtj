---
name: feature:bugfix:report
description: File a development bug issue against the active sprint. Gathers what / steps / expected / actual / severity, resolves the sprint and originating story, then creates the issue.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Feature Bugfix — Report

`$ARGUMENTS` (optional) carries a free-text bug description.

Production bug shipped to `main` → use `/bugfix:report`.

## Workflow
1. Resume Check
2. Resolve Sprint
3. Gather Bug Details
4. Create Issue
5. Report
6. Next Step

## Resume Check

Look up resume state (`workflow = feature`, `run_key = bugfix-report-new`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Resolve Sprint**.
- **Cancel** → abort; leave state untouched.

## Resolve Sprint

Via `github` skill, resolve active sprint → `$SPRINT_N`. None → halt `⛔ No sprint on the board. File as a production bug with /bugfix:report, or run /feature:requirement:create first.`

Via `github` skill, list sprint items labelled `user-story` → ask via `AskUserQuestion` "Which story did this bug originate from?" → `$ORIGINATING_STORY`.

## Gather Bug Details

Parse the raw description for already-answered fields:

- **What is broken?** — the defective behaviour.
- **Steps to reproduce** — numbered list to trigger the bug.
- **Expected behaviour** — what should happen.
- **Actual behaviour** — what actually happens.
- **Severity** — critical / high / medium / low.

Missing fields → ask via `AskUserQuestion` (single message). All present → proceed.

## Create Issue

Via `github` skill, create the issue:

- **Title**: `[Dev Bug] <concise description of what is broken>`
- **Labels**: `["bug"]`
- **Body**: `issue-bug-report` template (via `github-templates` skill) with `{description, steps, expected, actual, severity, originating_story: $ORIGINATING_STORY}`.
- **Board**: **Register Issue on Board** — Type `Bug`, Status `Todo`, Sprint `Sprint $SPRINT_N`.

## Report

Output the issue number + title.

## Next Step

Dev bug filed on Sprint $SPRINT_N. Next:

- `/feature add acceptance criteria to the bug`