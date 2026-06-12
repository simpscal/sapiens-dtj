---
name: bugfix:report
description: File a production bug issue. Gathers what / steps / expected / actual / severity, then creates the issue.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Bugfix Report

`$ARGUMENTS` (optional) carries a free-text bug description.

Bug found during sprint development → use `/feature:bugfix:report` (attaches to the active sprint).

## Workflow
1. Resume Check
2. Gather Bug Details
3. Create Issue
4. Report
5. Next Step

## Resume Check

Look up resume state (`workflow = bugfix`, `run_key = report-new`). Exists → ask via `AskUserQuestion`:

- **Resume** → skip completed steps; replay stored decisions + artifacts.
- **Restart** → clear state; start from **Gather Bug Details**.
- **Cancel** → abort; leave state untouched.

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

- **Title**: `[Bug] <concise description of what is broken>`
- **Labels**: `["bug"]`
- **Body**: `issue-bug-report` template (via `github-templates` skill) with `{description, steps, expected, actual, severity}`.
- **Board**: **Register Issue on Board** — Type `Bug`, Status `Todo`. No Sprint.

## Report

Output the issue number + title.

## Next Step

Bug issue filed. Next:

- `/bugfix add acceptance criteria to the bug`