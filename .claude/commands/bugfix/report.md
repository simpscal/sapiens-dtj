---
name: bugfix:report
description: File a bug issue (production or development). Gathers what / steps / expected / actual / severity, classifies source, then creates the issue.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Bugfix Report

`$ARGUMENTS` (optional) carries a free-text bug description.

## Workflow
1. Resume Check
2. Gather Bug Details
3. Classify Bug Source
4. Create Issue
5. Report
6. Next Step

## Resume Check

Look up resume state (`workflow = bugfix`, `run_key = report-new`).

If state exists, ask via `AskUserQuestion`:

- **Resume** — jump past completed steps; replay stored decisions and artifacts.
- **Restart** — clear state; start from **Gather Bug Details**.
- **Cancel** — abort; leave state untouched.

## Gather Bug Details

Parse the raw description for already-answered fields:

- **What is broken?** — clear description of the defective behaviour.
- **Steps to reproduce** — numbered list to trigger the bug.
- **Expected behaviour** — what should happen.
- **Actual behaviour** — what actually happens.
- **Severity** — critical / high / medium / low.

If any fields are missing, ask via `AskUserQuestion` for all missing fields in a single message. If all fields are present, skip and proceed.

## Classify Bug Source

Ask via `AskUserQuestion`: "Production bug or development bug found during a sprint?"

- **Production** — bug found in production.
- **Development** — bug found during sprint development.

Hold `$BUG_SOURCE`.

If **Development**:

1. Auto-detect active sprint: via the `github` skill, resolve the active sprint → `$SPRINT_N`. If none found, halt: `⛔ No sprint on the board. File as a production bug or run /feature:requirement:create first.`
2. Via the `github` skill, list sprint items with `user-story` label. Ask via `AskUserQuestion`: "Which story did this bug originate from?" Present the list for selection → `$ORIGINATING_STORY`.

## Create Issue

Via the `github` skill, create an issue conditional on `$BUG_SOURCE`:

**Production:**

- **Title**: `[Bug] <concise description of what is broken>`
- **Labels**: `["bug"]`
- **Body**: render the `issue-bug-report` template via the `github-templates` skill with `{description, steps, expected, actual, severity}`.
- **Board**: via **Register Issue on Board** — Type `Bug`, Status `Todo`. No Sprint.

**Development:**

- **Title**: `[Dev Bug] <concise description of what is broken>`
- **Labels**: `["bug"]`
- **Body**: render the `issue-bug-report` template via the `github-templates` skill with `{description, steps, expected, actual, severity, originating_story: $ORIGINATING_STORY}`.
- **Board**: via **Register Issue on Board** — Type `Bug`, Status `Todo`, Sprint `Sprint $SPRINT_N`.

## Report

Output the issue number and title.

## Next Step

Bug issue filed. Print the next command:

- `/bugfix:story <bug_issue>` — author the acceptance criteria
