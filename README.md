<div align="center">

# Sapiens-DTJ

**Sapiens Do The Job.**

**A GitHub-native, human-gated AI workflow for Claude Code — AI agents execute the work; sapiens gate every step: requirements, stories, designs, code review, release.**

[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-workflow-D97757?style=for-the-badge&logo=anthropic&logoColor=white)](https://claude.com/claude-code)

</div>

---

## 🤔 Why This Exists

AI can 10x a team — but only if everyone uses it the same way. Without that, you get:

- **Inconsistent output.** Same feature, three architectures. Each team member prompts differently, gets different results. Productivity gains cancel out in review and rework.
- **Context scattered everywhere.** Requirements in Notion, designs in Figma, decisions in Slack, state in someone's head. AI can't read any of it. Humans waste time bridging tools.
- **No single source of truth.** When artifacts live across five platforms, nobody knows what's current. Work gets duplicated, decisions get reversed, context gets lost between sessions.

## 🧭 How It Works

- **Orchestrator, not a codebase.** Stories, sprints, designs, TDDs, and bugs live here as issues. Agents check out your real code repos (API, web, infra), registered once via `/setup`.
- **GitHub is the source of truth.** No Jira, no Notion — every artifact is an issue; lifecycle state lives on a GitHub Project board (Status field), not in chat.
- **Design lives in code, not Figma.** Mockups are Storybook surface stories committed to the frontend repo — built from your real components, reviewed as PRs, and read by implementation agents as the pixel-level reference. No design-tool drift: the mockup and the app share one component library.

```mermaid
flowchart LR
    subgraph ORCH["This Repo · Orchestrator"]
        direction TB
        ISSUES["GitHub Issues · Labels · Project Board<br/>requirements · stories · TDDs<br/>designs · bugs · backlog"]
        FLOWS["Workflow Commands<br/>/backlog · /feature · /bugfix · /refactor"]
    end

    subgraph TARGETS["Your Code Repos"]
        direction TB
        BE["Backend repo<br/>API"]
        FE["Frontend repo<br/>Web"]
        IN["Infrastructure repo<br/>Terraform · SAM · etc."]
    end

    ORCH ==>|"branch · implement · commit · open PR · merge"| TARGETS
    TARGETS -.->|"read codebase context"| ORCH
```

<p align="center">
  <img src="docs/images/workflow-tour.gif" alt="Video tour through the workflow: project board in Table and Kanban views, a completed user story with acceptance criteria, design tokens, and Storybook surface mockups" width="640">
</p>

---

## 🚀 Quick Start

> **Prerequisites:** [Claude Code CLI](https://claude.com/claude-code) · [GitHub CLI (`gh`)](https://cli.github.com) · the code repo(s) you want agents to work on.

### 1. Get the workflow

**Option A — dedicated orchestrator repo (recommended).** Click **Use this template** → create your orchestrator repo (e.g. `myproduct-hub`) — its issues become your requirements, stories, and bugs. Clone it next to your code repos:

```bash
ls            # myproduct-api/  myproduct-web/
gh repo clone <you>/myproduct-hub
cd myproduct-hub && claude
```

**Option B — embed in an existing repo.** Copy `.claude/` into your project:

```bash
git clone https://github.com/simpscal/sapiens-dtj.git
cp -r sapiens-dtj/.claude /path/to/your/project/
```

### 2. Run setup

Inside Claude Code, run `/setup` and pick **All**. It generates:

| Artifact | Purpose |
|----------|---------|
| `.claude/skills/project-config/SKILL.md` | Registers codebases, detects tech stack, configures migration detection |
| `PRODUCT.md` | Captures vision, value proposition, business model, goals, strategic direction |
| GitHub labels | `requirement`, `user-story`, `bug`, etc. — safe to re-run |
| GitHub Project board | Status / Type / Sprint fields — the workflow's tracking surface; safe to re-run |

### 3. Kick off your first sprint

```
/feature:requirement:create "Next feature on the backlog"
```

> [!TIP]
> Not sure which command to run? `/help-flows` asks your intent and prints the exact command to copy-paste.

> [!NOTE]
> Non-disruptive. Only `.claude/` and `PRODUCT.md` are added. Existing issues, PRs, and branches stay untouched.

---

## 🔄 Workflows

<details>
<summary><strong>Feature Development</strong> — the standard sprint cycle</summary>

Story branches merge to **staging** for verification, then to the **sprint branch** on pass. Sprint branch stays clean.

```mermaid
flowchart TD
    A(["/feature:requirement:create"]) --> B["Requirement issue"]
    B --> G1{Gate 1\nPO review}
    G1 -->|Approve| C(["/feature:stories:create"])
    C --> D["Story + Tech issues"]
    D --> G2{Gate 2\nReview stories}
    G2 -->|Approve| E1(["/feature:design:create"])
    E1 --> F1["Storybook stories"]
    F1 --> E2(["/feature:technical-design:create"])
    E2 --> F2["TDD issue"]
    F2 --> G3{Gate 3\nReview TDD + design}
    G3 -->|Approve| H(["/feature:implement"])
    H --> I["PR: story → staging"]
    I --> G4{Gate 4\nCode review}
    G4 -->|Approve| I2["Merge to staging"]
    I2 --> G5{Gate 5\nVerify on staging}
    G5 -->|Pass| QP2["Merge → sprint"]
    QP2 --> MORE{More stories?}
    MORE -->|Yes| H
    MORE -->|No| PRE(["/feature:pre-release"])
    G5 -->|Regression| FIX(["/feature:implement\n(user input)"])
    FIX --> G5
    PRE --> PRE1["Release PRs\nsprint → main"]
    PRE1 --> G6{Gate 6\nReview release PRs}
    G6 -->|Approve| REL(["/feature:release"])
    REL --> REL1["Merge + close all"]
    REL1 --> L([Sprint shipped])
```

</details>

<details>
<summary><strong>Bugfix (Production)</strong> — bugs found in production</summary>

Independent of sprint cycle. Fix PRs hit **staging** for verification, then `main`.

```mermaid
flowchart TD
    A(["/bugfix:report"]) --> CLS{Classify source}
    CLS -->|Production| B["Bug issue"]
    B --> G1{Gate 1\nReview bug}
    G1 -->|Approve| C(["/bugfix:story"])
    C --> D["Acceptance criteria"]
    D --> G2{Gate 2\nReview ACs}
    G2 -->|Approve| H(["/bugfix:implement"])
    H --> INV["Investigation\n+ approve gate"]
    INV --> I["Fix PR → staging"]
    I --> G3{Gate 3\nCode review}
    G3 -->|Merged| I2["Merge to staging"]
    I2 --> G4{Gate 4\nVerify on staging}
    G4 -->|Pass| PRE(["/bugfix:pre-release"])
    PRE --> PRE1["Readiness + migration check"]
    PRE1 --> G5{Gate 5\nReview fix PRs}
    G5 -->|Approve| J(["/bugfix:release"])
    J --> J1["Merge + close"]
    J1 --> K([Bug fixed])
    G4 -->|Still broken| FIX(["/bugfix:implement\n(user input)"])
    FIX --> G4
```

</details>

<details>
<summary><strong>Bugfix (Development)</strong> — bugs found during sprint work</summary>

Part of sprint cycle. Fix PRs target the **sprint branch**. Dev bugs block sprint release until closed.

```mermaid
flowchart TD
    A(["/bugfix:report"]) --> CLS{Classify source}
    CLS -->|Development| B["Bug issue\n+ originating story"]
    B --> G1{Gate 1\nReview bug}
    G1 -->|Approve| C(["/bugfix:story"])
    C --> D["Acceptance criteria"]
    D --> G2{Gate 2\nReview ACs}
    G2 -->|Approve| H(["/bugfix:implement"])
    H --> INV["Investigation\n+ approve gate"]
    INV --> I["Fix PR → sprint"]
    I --> G3{Gate 3\nCode review}
    G3 -->|Approve| PRE(["/bugfix:pre-release"])
    PRE --> PRE1["Readiness check"]
    PRE1 --> G4{Gate 4\nReview fix PRs}
    G4 -->|Approve| J(["/bugfix:release"])
    J --> J1["Merge + close"]
    J1 --> K([Bug fixed\nrelease unblocked])
    G3 -->|Still broken| FIX(["/bugfix:implement\n(user input)"])
    FIX --> G3
```

</details>

<details>
<summary><strong>Upstream Change</strong> — requirement or story shifts mid-sprint</summary>

A change to an upstream artifact cascades downstream through stories, design, TDD, dev, and QA incrementally. Two entry points — a requirement-level scope shift or an AC-level story amendment — converge on the same regenerate-and-cascade path. All stages of `/feature` — no separate workflow.

```mermaid
flowchart TD
    A1(["/feature:requirement:amend"]) --> B["Requirement updated"]
    B --> C(["/feature:stories:regenerate"])
    A2(["/feature:stories:regenerate"]) --> D
    C --> D["Change plan"]
    D --> G1{Gate 1\nApprove plan}
    G1 -->|Approve| E["Update / create / close stories"]
    E --> F{UI changes?}
    F -->|Yes| FA(["/feature:design:regenerate"])
    FA --> FA2["Storybook updated"]
    FA2 --> T
    F -->|No| T{Tech changes?}
    T -->|Yes| TA(["/feature:technical-design:regenerate"])
    TA --> TA2["TDD updated"]
    TA2 --> H(["/feature:implement"])
    T -->|No| H
    H --> I["Revisit PR → staging"]
```

**When to amend design and TDD:**

| Change type | Design | TDD |
|-------------|--------|-----|
| New UI surface or interaction | Yes | Maybe |
| Changed layout, component, or visual state | Yes | Maybe |
| New API endpoint or data model | No | Yes |
| Changed business logic or backend behaviour | No | Yes |
| UI + backend change together | Yes | Yes |
| Copy/label wording only | No | No |

</details>

<details>
<summary><strong>Refactoring</strong> — tech-debt and structural cleanup</summary>

No sprint, no separate verification stage. Branch from `main`, PR to `main`. DoD requires existing tests pass and no user-visible behavior change.

```mermaid
flowchart TD
    A(["/refactor:spec:create"]) --> B["Discovery dialog"]
    B --> C["Codebase exploration"]
    C --> D["Refactor issue"]
    D --> G1{Gate 1\nReview spec}
    G1 -->|Approve| H(["/refactor:implement"])
    H --> I["Branch from main"]
    I --> J["PR: refactor → main"]
    J --> G2{Gate 2\nCode review}
    G2 -->|Approve| PRE(["/refactor:pre-release"])
    PRE --> PRE1["Readiness + migration check"]
    PRE1 --> G3{Gate 3\nReview refactor PRs}
    G3 -->|Approve| REL(["/refactor:release"])
    REL --> REL1["Merge + close"]
    REL1 --> L([Refactor shipped])
```

</details>

---

## ⚡ Commands

Each workflow is a set of **navigators**. Run the entry command — the navigator asks which mode (create / regenerate / etc.) and resolves arguments interactively.

### 🗂 `/backlog` — Pre-sprint capture

| Command | Run by | What it does |
|---------|--------|-------------|
| `/backlog:add [free text]` | Anyone | Quick-capture an idea, refactor, or production bug as a board draft (title + type + notes) — without touching the current sprint. |
| `/backlog:list` | Anyone | Show backlog drafts grouped by type (Feature / Refactor / Bug). |
| `/backlog:promote` | PO / Tech Lead | Promote a draft into its typed flow — feature requirement, refactor spec, or bug report — with full templates and approval gates; the draft is removed once the issue exists. |

### 🆕 `/feature` — Sprint feature lifecycle

| Command | Run by | What it does |
|---------|--------|-------------|
| `/feature:requirement` | PO | Create or amend a requirement. Create auto-provisions a board Sprint. |
| `/feature:stories` | BA | Decompose requirement into stories, or regenerate them after a scope delta (requirement change or user input). |
| `/feature:design` | Designer | Compose or regenerate per-surface Storybook stories via the ui-design agent (story change or user input). |
| `/feature:technical-design` | Tech Lead | Author or regenerate the sprint TDD (story change or user input). |
| `/feature:implement <story_issue>` | Dev | Implement one story — fresh or revisit (delta-only) based on prior implementation. |
| `/feature:pre-release <sprint_number>` | Release Mgr | Readiness gate, migration check, create release PRs (sprint → main), post sprint summary. |
| `/feature:release <sprint_number>` | Release Mgr | Merge release PRs, delete story branches, mark all sprint issues Done + close. |

### 🐛 `/bugfix` — Bug lifecycle (production and development)

| Command | Run by | What it does |
|---------|--------|-------------|
| `/bugfix:report [description]` | PO | Clarify bug interactively, classify source (production / development), open tracker issue. |
| `/bugfix:story <bug_issue>` | BA | Author Acceptance Criteria on the bug issue. |
| `/bugfix:implement <bug_issue>` | Dev | Investigate root cause (draft + approve gate), then fix — fresh or revisit. |
| `/bugfix:pre-release <bug_issue>` | Release Mgr | Readiness gate, migration check (production), post bug summary. |
| `/bugfix:release <bug_issue>` | Release Mgr | Merge bugfix PRs, mark Done on the board, close issue. |

> **Production bugs** branch from `main`, PR to `main`. **Development bugs** branch from the sprint branch, PR to the sprint branch, and block sprint release until closed.

### 🧹 `/refactor` — Tech-debt and structural cleanup

| Command | Run by | What it does |
|---------|--------|-------------|
| `/refactor:spec` | Tech Lead | Create or amend a refactor spec (draft + approve gate). |
| `/refactor:implement <refactor_issue>` | Dev | Implement the spec — preserves observable behaviour. |
| `/refactor:pre-release <refactor_issue>` | Release Mgr | Readiness gate, migration check, post summary. |
| `/refactor:release <refactor_issue>` | Release Mgr | Merge refactor PRs, close issue. |

### 🛠 `/setup` — One-off setup

| Command | What it does |
|---------|-------------|
| `/setup` | Pick **All** (full setup) or individual: project-config, labels, board, product. |

### 🧭 `/help-flows` — Workflow picker

| Command | What it does |
|---------|-------------|
| `/help-flows` | Asks intent, prints exact next command to copy-paste. |
| `/help-flows <intent>` | Free-text intent (e.g. `i want to fix a bug`); resolves to one command. |
| `/help-flows all` | Prints full cheat sheet of every stage. |

---

## 📋 Tracking Model

**Labels** classify what an issue is; the **GitHub Project board** tracks where it sits in the pipeline.

### 📦 Artifact Types (labels)

What the issue is. Set once on creation.

| | Label | Artifact |
|---|-------|---------|
| ![](https://placehold.co/15x15/e4e669/e4e669.png) | `requirement` | PO requirement created via `/feature:requirement:create` |
| ![](https://placehold.co/15x15/c2e0c6/c2e0c6.png) | `user-story` | Story created via `/feature:stories` |
| ![](https://placehold.co/15x15/d73a4a/d73a4a.png) | `bug` | Bug reported via `/bugfix:report`; source from title prefix (`[Bug]` production, `[Dev Bug]` development) |
| ![](https://placehold.co/15x15/1d76db/1d76db.png) | `refactoring` | Refactor spec created via `/refactor:spec:create` |
| ![](https://placehold.co/15x15/fef2c0/fef2c0.png) | `requirement-updated` | Informational marker — requirement changed mid-sprint; follow with `/feature:stories:regenerate` |

### 🔁 Board Status (Project field)

Where an item sits in the pipeline. Commands move it as work progresses.

| Status | Meaning | What happens next |
|--------|---------|------------------|
| `Backlog` | Captured draft via `/backlog:add` — not yet planned | `/backlog:promote` |
| `Todo` | Issue filed, not started | implement command |
| `In Progress` | Dev is currently implementing | — |
| `Implemented` | PRs open / merged to staging, awaiting verification | Human merges branch → sprint, or amend ACs then re-implement |
| `Done` | Released and closed | — |
