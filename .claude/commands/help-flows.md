---
name: help-flows
description: Pick a workflow stage and get the exact command to run.
argument-hint: "[free-text intent | 'all' for full cheat sheet]"
tools: AskUserQuestion
---

# /help-flows — Workflow Picker

## Workflow
1. Branch on `$ARGUMENTS`
2. Ask Intent
3. Resolve Stage to Command
4. Output

## Branch on `$ARGUMENTS`

| Argument | Action |
|---|---|
| `all` _or_ `cheatsheet` | Skip to **Cheat Sheet** at bottom and print verbatim. Stop. |
| _free text_ (e.g. "I need to fix a bug in login") | Treat as intent. Skip **Ask Intent**. Go to **Resolve Stage to Command** and infer the matching stage from the **Stage Map** below. If ambiguous, fall back to **Ask Intent**. |
| _empty_ | Go to **Ask Intent**. |

## Ask Intent

Ask via `AskUserQuestion` (single, `multiSelect=false`): `What do you want to do?`

Options (label → stage id):

- **Start a new feature** → `feature-start`
- **Continue current sprint** → `feature-continue`
- **Change requirement mid-sprint** → `feature-change`
- **Amend ACs on one story** → `feature-amend-ac`
- **Merge a reviewed story's PRs** → `feature-merge`
- **Production bug — fix it** → `bugfix-start`
- **Development bug — fix it** → `devbug-start`
- **Continue a bug fix** → `bugfix-continue`
- **Refactor** → `refactor-start`
- **Amend a refactor spec** → `refactor-amend`
- **Pre-release a sprint** → `pre-release-sprint`
- **Pre-release a bug fix** → `pre-release-bugfix`
- **Pre-release a refactor** → `pre-release-refactor`
- **Release a sprint** → `release-sprint`
- **Release a bug fix** → `release-bugfix`
- **Release a refactor** → `release-refactor`
- **Project setup (all or individual)** → `setup`
- **Show full cheat sheet** → `all`

If user picks `all`, jump to **Cheat Sheet**.

## Resolve Stage to Command

Look up the chosen stage in the **Stage Map**. For each placeholder, ask via `AskUserQuestion`. Skip args already supplied in `$ARGUMENTS`.

**Stage Map**:

| Stage id | Required args | Command template |
|---|---|---|
| `feature-start` | `<description>` | `/feature:requirement:create <description>` |
| `feature-continue` | _(see sub-stages)_ | Ask: which sub-stage — stories / design / technical-design / implement. Map to `/feature:stories:create <req#>`, `/feature:design:create <sprint>`, `/feature:technical-design:create <sprint>`, `/feature:implement <story#>`. |
| `feature-change` | `<req#>`, `<delta>` | `/feature:requirement:amend <req#> <delta>` _then suggest follow-ups:_ `/feature:stories:regenerate <req#>`, `/feature:design:regenerate <sprint>`, `/feature:technical-design:regenerate <sprint>`, `/feature:implement <story#>`. |
| `feature-merge` | `<story#>` | `/feature:merge <story#>` _(after PR review approved — repeat per story)_ |
| `pre-release-sprint` | `<sprint>` | `/feature:pre-release <sprint>` |
| `pre-release-bugfix` | `<bug#>` | `/bugfix:pre-release <bug#>` |
| `pre-release-refactor` | `<refactor#>` | `/refactor:pre-release <refactor#>` |
| `release-sprint` | `<sprint>` | `/feature:release <sprint>` |
| `release-bugfix` | `<bug#>` | `/bugfix:release <bug#>` |
| `release-refactor` | `<refactor#>` | `/refactor:release <refactor#>` |
| `bugfix-start` | `[description]` | `/bugfix:report <description>` _(select "Production" when prompted)_ |
| `devbug-start` | `[description]` | `/bugfix:report <description>` _(select "Development" when prompted)_ |
| `bugfix-continue` | _(see sub-stages)_ | Ask: which sub-stage — story / implement. Map to `/bugfix:story <bug#>`, `/bugfix:implement <bug#>`. |
| `refactor-start` | _(none)_ | `/refactor:spec:create` _then:_ `/refactor:implement <refactor#>` |
| `refactor-amend` | `<refactor#>` | `/refactor:spec:amend <refactor#>` |
| `setup` | _(none)_ | `/setup` _(navigator — pick all / project-config / labels / product / design)_ |

## Output

Print exactly:

```
👉 Run: <resolved command>
```

If a follow-up command is part of the flow, add one line per follow-up:

```
↳ Next: <follow-up command>
```

Then stop. No extra prose, no execution.

---

## Cheat Sheet

### 🆕 Feature (Sprint)

1. `/feature:requirement:create <description>`
2. `/feature:stories:create <requirement_issue>`
3. `/feature:design:create <sprint>` _(compose Storybook surface stories for UI stories)_
4. `/feature:technical-design:create <sprint>`
5. `/feature:implement <story_issue>` _(repeat per story)_
6. `/feature:merge <story_issue>` _(after PR review approved — repeat per story)_
7. `/feature:pre-release <sprint>`
8. `/feature:release <sprint>`

### 🔁 Requirement Change (within Feature)

1. `/feature:requirement:amend <requirement_issue> <delta>`
2. `/feature:stories:regenerate <requirement_issue>`
3. `/feature:design:regenerate <sprint>` _(if web stories changed)_
4. `/feature:technical-design:regenerate <sprint>`
5. `/feature:implement <story_issue>`

### 🐛 Bugfix (Production Bug)

1. `/bugfix:report [description]` _(select "Production" when prompted)_
2. `/bugfix:story <bug_issue>`
3. `/bugfix:implement <bug_issue>`
4. `/bugfix:pre-release <bug_issue>`
5. `/bugfix:release <bug_issue>`

### 🐛 Bugfix (Development Bug)

1. `/bugfix:report [description]` _(select "Development" when prompted)_
2. `/bugfix:story <bug_issue>`
3. `/bugfix:implement <bug_issue>`
4. `/bugfix:pre-release <bug_issue>`
5. `/bugfix:release <bug_issue>`

### 🚀 Prerelease + Release

- `/feature:pre-release <sprint_number>` — readiness gate for feature sprint
- `/feature:release <sprint_number>` — close a feature sprint
- `/bugfix:pre-release <bug_issue>` — readiness gate for bug fix
- `/bugfix:release <bug_issue>` — close a bug (production or development)
- `/refactor:pre-release <refactor_issue>` — readiness gate for refactor
- `/refactor:release <refactor_issue>` — close a refactor task

### 🧹 Refactor

1. `/refactor:spec:create`
2. `/refactor:implement <refactor_issue>`
3. `/refactor:spec:amend <refactor_issue>` _(if spec needs revision)_
4. `/refactor:pre-release <refactor_issue>`
5. `/refactor:release <refactor_issue>`

### 🛠 Setup (one-off utility)

- `/setup` — navigator (pick mode or run all)
- `/setup:project-config` — codebases, tech stack, migration rules
- `/setup:labels` — GitHub labels
- `/setup:product` — PRODUCT.md

---

## Constraints

- Never **execute** the resolved command — just print it.
- Never invent stages or commands not in the Stage Map.
- If user-supplied args already match required slots, do not re-ask.
- One `AskUserQuestion` call may batch multiple needed args as separate questions.
