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
- **GitHub is the source of truth.** No Jira, no Notion — every artifact is an issue; state changes by label, not chat.
- **Design lives in code, not Figma.** Mockups are Storybook surface stories committed to the frontend repo — built from your real components, reviewed as PRs, and read by implementation agents as the pixel-level reference. No design-tool drift: the mockup and the app share one component library.

```mermaid
flowchart LR
    subgraph ORCH["This Repo · Orchestrator"]
        direction TB
        ISSUES["GitHub Issues · Labels · Milestones<br/>requirements · stories · TDDs<br/>designs · bugs"]
        FLOWS["Workflow Commands<br/>/feature · /bugfix · /refactor"]
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
  <img src="docs/images/workflow-tour.gif" alt="Animated tour through the workflow artifacts: requirement issue, user story, TDD, refactor spec, Storybook surface mockups, design tokens, and a full bug lifecycle" width="640">
</p>

---

## 🚀 Quick Start

**Prerequisites:** Claude Code CLI, GitHub CLI (`gh`), and the code repo(s) you want agents to work on.

**Option A — dedicated orchestrator repo (recommended):**

1. Click **Use this template** → create your orchestrator repo (e.g. `myproduct-hub`). Its issues become your requirements, stories, and bugs.
2. Clone it next to your code repos:

```bash
ls            # myproduct-api/  myproduct-web/
gh repo clone <you>/myproduct-hub
cd myproduct-hub && claude
```

**Option B — embed in an existing repo:**

```bash
git clone https://github.com/simpscal/sapiens-dtj.git
cp -r sapiens-dtj/.claude /path/to/your/project/
```

Either way, run `/setup` (pick **All**) to:

- Generate `.claude/skills/project-config/SKILL.md` — registers codebases, detects tech stack, configures migration detection.
- Generate `PRODUCT.md` — captures vision, value proposition, business model, goals, and strategic direction.
- Create GitHub labels (`requirement`, `user-story`, `bug`, etc.). Safe to re-run.

Then kick off a sprint:

```
/feature:requirement:create "Next feature on the backlog"
```

> [!TIP]
> Not sure which command to run? Use `/help-flows` — it asks your intent and prints the exact command to copy-paste.

> [!NOTE]
> Non-disruptive. Only `.claude/` and `PRODUCT.md` are added. Existing issues, PRs, and branches stay untouched.

---

## ⚡ Commands

Each workflow is a set of **navigators**. Run the entry command — the navigator asks which mode (create / regenerate / etc.) and resolves arguments interactively.

### 🆕 `/feature` — Sprint feature lifecycle

| Command | Run by | What it does |
|---------|--------|-------------|
| `/feature:requirement` | PO | Create or amend a requirement. Create auto-provisions a sprint milestone. |
| `/feature:stories` | BA | Decompose requirement into stories, or regenerate them after a scope delta (requirement change or user input). |
| `/feature:design` | Designer | Compose or regenerate per-surface Storybook stories via the ui-design agent (story change or user input). |
| `/feature:technical-design` | Tech Lead | Author or regenerate the sprint TDD (story change or user input). |
| `/feature:implement <story_issue>` | Dev | Implement one story — fresh or revisit (delta-only) based on prior implementation. |
| `/feature:pre-release <sprint_number>` | Release Mgr | Readiness gate, migration check, create release PRs (sprint → main), post sprint summary. |
| `/feature:release <sprint_number>` | Release Mgr | Merge release PRs, delete story branches, label + close all sprint issues. |

### 🐛 `/bugfix` — Bug lifecycle (production and development)

| Command | Run by | What it does |
|---------|--------|-------------|
| `/bugfix:report [description]` | PO | Clarify bug interactively, classify source (production / development), open tracker issue. |
| `/bugfix:story <bug_issue>` | BA | Author Acceptance Criteria on the bug issue. |
| `/bugfix:implement <bug_issue>` | Dev | Investigate root cause (draft + approve gate), then fix — fresh or revisit. |
| `/bugfix:pre-release <bug_issue>` | Release Mgr | Readiness gate, migration check (production), post bug summary. |
| `/bugfix:release <bug_issue>` | Release Mgr | Merge bugfix PRs, label `bug-fixed`, close issue. |

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
| `/setup` | Pick **All** (full setup) or individual: project-config, labels, product. |

### 🧭 `/help-flows` — Workflow picker

| Command | What it does |
|---------|-------------|
| `/help-flows` | Asks intent, prints exact next command to copy-paste. |
| `/help-flows <intent>` | Free-text intent (e.g. `i want to fix a bug`); resolves to one command. |
| `/help-flows all` | Prints full cheat sheet of every stage. |

---

## 🔄 Workflows

<details>
<summary><strong>Feature Development</strong> — the standard sprint cycle</summary>

Story branches merge to **staging** for verification, then to the **sprint branch** on pass. Sprint branch stays clean.

```mermaid
flowchart TD
    A(["/feature:requirement:create &lt;description&gt;"]) --> B["Requirement Issue\n`requirement`\n+ Sprint Milestone"]
    B --> G1{Gate 1\nPO Review}
    G1 -->|Approve| C(["/feature:stories:create"])
    C --> D["[Story] + [Tech] Issues\nunder Sprint Milestone"]
    D --> G2{Gate 2\nPO Reviews Stories}
    G2 -->|Approve| E1(["/feature:design:create"])
    E1 --> F1["Storybook Surface Stories"]
    F1 --> E2(["/feature:technical-design:create"])
    E2 --> F2["TDD Issue"]
    F2 --> G3{Gate 3\nPO Reviews TDD + Design}
    G3 -->|Approve| H(["/feature:implement &lt;story&gt;"])
    H --> I["PR: story → staging\n`implemented`"]
    I --> G4{Gate 4\nCode Review}
    G4 -->|Approved| I2["Merge to staging"]
    I2 --> G5{Gate 5\nHuman verifies on staging}
    G5 -->|Pass| QP2["Merge story branch → sprint"]
    QP2 --> MORE{More stories?}
    MORE -->|Yes| H
    MORE -->|No| PRE(["/feature:pre-release &lt;N&gt;"])
    G5 -->|Regression| FIX(["/feature:stories:regenerate (user input)\n→ /feature:implement &lt;story&gt;"])
    FIX --> G5
    PRE --> PRE1["Readiness gate\nMigration check\nCreate release PRs\nPost sprint summary"]
    PRE1 --> G6{Gate 6\nReview Release PRs}
    G6 -->|Approved| REL(["/feature:release &lt;N&gt;"])
    REL --> REL1["Merge release PRs\nDelete story branches\nLabel + close all issues"]
    REL1 --> L([Sprint Shipped])
```

</details>

<details>
<summary><strong>Bugfix (Production)</strong> — bugs found in production</summary>

Independent of sprint cycle. Fix PRs hit **staging** for verification, then `main`.

```mermaid
flowchart TD
    A(["/bugfix:report [description]"]) --> CLS{"Classify source"}
    CLS -->|Production| B["Bug Issue\n`bug`\n(title `[Bug]`)"]
    B --> G1{Gate 1\nPO Reviews Bug}
    G1 -->|Approve| C(["/bugfix:story &lt;issue&gt;"])
    C --> D["Acceptance Criteria\non bug issue"]
    D --> G2{Gate 2\nPO Reviews ACs}
    G2 -->|Approve| H(["/bugfix:implement &lt;issue&gt;"])
    H --> INV["Investigation draft\n+ approve gate"]
    INV --> I["Fix PR → staging\n`implemented`"]
    I --> G3{Gate 3\nCode Review}
    G3 -->|Merged| I2["Merged to staging"]
    I2 --> G4{Gate 4\nHuman verifies on staging}
    G4 -->|Pass| PRE(["/bugfix:pre-release &lt;issue&gt;"])
    PRE --> PRE1["Readiness gate\nMigration check\nPost bug summary"]
    PRE1 --> G5{Gate 5\nReview bugfix PRs}
    G5 -->|Approved| J(["/bugfix:release &lt;issue&gt;"])
    J --> J1["Merge bugfix PRs\nLabel bug-fixed\nClose issue"]
    J1 --> K([Bug Fixed])
    G4 -->|Still broken| FIX(["/bugfix:story &lt;bug&gt; (amend ACs)\n→ /bugfix:implement &lt;bug&gt;"])
    FIX --> G4
```

</details>

<details>
<summary><strong>Bugfix (Development)</strong> — bugs found during sprint work</summary>

Part of sprint cycle. Fix PRs target the **sprint branch**. Dev bugs block sprint release until closed.

```mermaid
flowchart TD
    A(["/bugfix:report [description]"]) --> CLS{"Classify source"}
    CLS -->|Development| B["Bug Issue\n`bug`\n(title `[Dev Bug]`)\n+ Sprint Milestone\n+ Originating Story"]
    B --> G1{Gate 1\nPO Reviews Bug}
    G1 -->|Approve| C(["/bugfix:story &lt;issue&gt;"])
    C --> D["Acceptance Criteria\non bug issue"]
    D --> G2{Gate 2\nPO Reviews ACs}
    G2 -->|Approve| H(["/bugfix:implement &lt;issue&gt;"])
    H --> INV["Investigation draft\n+ approve gate"]
    INV --> I["Fix PR → sprint branch\n`implemented`"]
    I --> G3{Gate 3\nCode Review}
    G3 -->|Approved| PRE(["/bugfix:pre-release &lt;issue&gt;"])
    PRE --> PRE1["Readiness gate\nPost bug summary"]
    PRE1 --> G4{Gate 4\nReview bugfix PRs}
    G4 -->|Approved| J(["/bugfix:release &lt;issue&gt;"])
    J --> J1["Merge bugfix PRs\nLabel bug-fixed\nClose issue"]
    J1 --> K([Bug Fixed\nSprint release unblocked])
    G3 -->|Still broken| FIX(["/bugfix:story &lt;bug&gt; (amend ACs)\n→ /bugfix:implement &lt;bug&gt;"])
    FIX --> G3
```

</details>

<details>
<summary><strong>Requirements Change</strong> — scope shifts mid-sprint</summary>

Cascades through stories, design, TDD, dev, and QA incrementally. All stages of `/feature` — no separate workflow.

```mermaid
flowchart TD
    A(["/feature:requirement:amend &lt;N&gt; &lt;delta&gt;"]) --> B["Requirement updated\n`requirement-updated`"]
    B --> C(["/feature:stories:regenerate"])
    C --> D["Change Plan\nCovered / Updatable / New / Removed"]
    D --> G1{Gate 1\nPO Approves Change Plan}
    G1 -->|Approve| E1["Update existing stories"]
    G1 -->|Approve| E2["Create new stories"]
    G1 -->|Approve| E3["Close removed stories"]
    E1 & E2 & E3 --> F1(["/feature:design:regenerate"])
    F1 --> F2["Storybook stories updated"]
    F2 --> F3(["/feature:technical-design:regenerate"])
    F3 --> F4["TDD updated"]
    F4 --> H(["/feature:implement &lt;story&gt;"])
```

</details>

<details>
<summary><strong>Story Change</strong> — AC-level amendments</summary>

AC adjustments to one or more stories — not the full requirement. Runs `/feature:stories:regenerate` with the **User input** source.

```mermaid
flowchart TD
    A(["/feature:stories:regenerate\n(User input)"]) --> B["Change Plan\nAmend / Create / Remove"]
    B --> G1{Gate 1\nPO Approves Change Plan}
    G1 -->|Approve| C["Story ACs updated"]
    C --> D{UI changes?}
    D -->|Yes| E(["/feature:design:regenerate\n(User input)"])
    D -->|No| F{Tech design changes?}
    E --> E2["Storybook stories updated"]
    E2 --> F
    F -->|Yes| G(["/feature:technical-design:regenerate\n(User input)"])
    F -->|No| H(["/feature:implement &lt;story&gt;"])
    G --> G2["TDD updated"]
    G2 --> H
    H --> I["Revisit PR → staging\nHuman re-verifies"]
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
    A(["/refactor:spec:create"]) --> B["Discovery Dialog\nproblem · scope · codebases · DoD"]
    B --> C["Codebase Exploration\nparallel per affected codebase"]
    C --> D["Refactoring Issue\n`refactoring`"]
    D --> G1{Gate 1\nHuman Reviews Spec}
    G1 -->|Approve| H(["/refactor:implement &lt;issue&gt;"])
    H --> I["Branch from main\n`in-progress`"]
    I --> J["PR: refactor branch → main"]
    J --> G2{Gate 2\nCode Review}
    G2 -->|Approved| PRE(["/refactor:pre-release &lt;issue&gt;"])
    PRE --> PRE1["Readiness gate\nMigration check\nPost summary"]
    PRE1 --> G3{Gate 3\nReview refactor PRs}
    G3 -->|Approved| REL(["/refactor:release &lt;issue&gt;"])
    REL --> REL1["Merge refactor PRs\nClose issue"]
    REL1 --> L([Refactor Shipped])
```

</details>

---

## 🏷️ Labels

Two purposes: **artifact type** and **lifecycle state**.

### 📦 Artifact Types

What the issue is. Set once on creation.

| | Label | Artifact |
|---|-------|---------|
| ![](https://placehold.co/15x15/e4e669/e4e669.png) | `requirement` | PO requirement created via `/feature:requirement:create` |
| ![](https://placehold.co/15x15/c2e0c6/c2e0c6.png) | `user-story` | Story created via `/feature:stories` |
| ![](https://placehold.co/15x15/d73a4a/d73a4a.png) | `bug` | Bug reported via `/bugfix:report`; source from title prefix (`[Bug]` production, `[Dev Bug]` development) |
| ![](https://placehold.co/15x15/1d76db/1d76db.png) | `refactoring` | Refactor spec created via `/refactor:spec:create` |

### 🔁 Lifecycle States

Where a story or bug sits in the pipeline. Change as work progresses; tell agents what's next.

| | Label | Meaning | What happens next |
|---|-------|---------|------------------|
| ![](https://placehold.co/15x15/d93f0b/d93f0b.png) | `in-progress` | Dev is currently implementing | — |
| ![](https://placehold.co/15x15/0e8a16/0e8a16.png) | `implemented` | PR merged to staging, awaiting verification | Human merges branch → sprint, or amend ACs then re-implement |
| ![](https://placehold.co/15x15/fef2c0/fef2c0.png) | `requirement-updated` | Requirement changed mid-sprint | `/feature:stories:regenerate` |
| ![](https://placehold.co/15x15/006b75/006b75.png) | `sprint-completed` | Sprint closed by release command | — |
| ![](https://placehold.co/15x15/0e8a16/0e8a16.png) | `bug-fixed` | Bug closed after `/bugfix:release` | — |
