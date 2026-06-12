# 🆕 Feature Workflow

Story branches merge to **staging** for verification, then to the **sprint branch** on pass. Sprint branch stays clean.

```mermaid
flowchart TD
    A(["/feature requirement create"]) --> B["Requirement issue"]
    B --> G1{Gate 1\nPO review}
    G1 -->|Approve| C(["/feature stories create"])
    C --> D["Story + Tech issues"]
    D --> G2{Gate 2\nReview stories}
    G2 -->|Approve| E1(["/feature design create"])
    E1 --> F1["Storybook stories"]
    F1 --> E2(["/feature technical-design create"])
    E2 --> F2["TDD issue"]
    F2 --> G3{Gate 3\nReview TDD + design}
    G3 -->|Approve| H(["/feature implement"])
    H --> I["PR: story → staging"]
    I --> G4{Gate 4\nCode review}
    G4 -->|Approve| I2["Merge to staging"]
    I2 --> G5{Gate 5\nVerify on staging}
    G5 -->|Pass| QP2["Merge → sprint"]
    QP2 --> MORE{More stories?}
    MORE -->|Yes| H
    MORE -->|No| PRE(["/feature pre-release"])
    G5 -->|Regression| FIX(["/feature implement\n(user input)"])
    FIX --> G5
    PRE --> PRE1["Release PRs\nsprint → main"]
    PRE1 --> G6{Gate 6\nReview release PRs}
    G6 -->|Approve| REL(["/feature release"])
    REL --> REL1["Merge + close all"]
    REL1 --> L([Sprint shipped])
```

## Phases

| Command | Run by | What it does |
|---------|--------|-------------|
| `/feature requirement` | PO | Create or amend a requirement. Create auto-provisions a board Sprint. |
| `/feature stories` | BA | Decompose requirement into stories, or regenerate them after a scope delta (requirement change or user input). |
| `/feature design` | Designer | Compose or regenerate per-surface Storybook stories via the ui-design agent (story change or user input). |
| `/feature technical-design` | Tech Lead | Author or regenerate the sprint TDD (story change or user input). |
| `/feature implement <story_issue>` | Dev | Implement one story — fresh or revisit (delta-only) based on prior implementation. |
| `/feature pre-release <sprint_number>` | Release Mgr | Readiness gate, migration check, create release PRs (sprint → main), post sprint summary. |
| `/feature release <sprint_number>` | Release Mgr | Merge release PRs, delete story branches, mark all sprint issues Done + close. |

## Mid-sprint changes

A change to an upstream artifact cascades downstream through stories, design, TDD, dev, and QA incrementally.

```mermaid
flowchart TD
    A1(["/feature requirement amend"]) --> B["Requirement updated"]
    B --> C(["/feature stories regenerate"])
    A2(["/feature stories regenerate"]) --> D
    C --> D["Change plan"]
    D --> G1{Gate 1\nApprove plan}
    G1 -->|Approve| E["Update / create / close stories"]
    E --> F{UI changes?}
    F -->|Yes| FA(["/feature design regenerate"])
    FA --> FA2["Storybook updated"]
    FA2 --> T
    F -->|No| T{Tech changes?}
    T -->|Yes| TA(["/feature technical-design regenerate"])
    TA --> TA2["TDD updated"]
    TA2 --> H(["/feature implement"])
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

## In-sprint bugs & refactors

Bugs surfaced and refactors needed *during* a sprint ride the **sprint branch** alongside stories.

### 🐛 In-sprint bugs

A bug found while building the sprint.

```mermaid
flowchart TD
    A(["/feature bugfix report"]) --> B["Bug issue\n+ originating story"]
    B --> G1{Gate 1\nReview bug}
    G1 -->|Approve| C(["/feature bugfix story"])
    C --> D["Acceptance criteria"]
    D --> G2{Gate 2\nReview ACs}
    G2 -->|Approve| H(["/feature bugfix implement"])
    H --> INV["Investigation\n+ approve gate"]
    INV --> I["Fix PR → sprint"]
    I --> G3{Gate 3\nCode review}
    G3 -->|Approve| M(["/feature merge"])
    M --> M1["Squash-merge → sprint"]
    M1 --> K([Lands on sprint\ncloses at /feature release])
    G3 -->|Still broken| FIX(["/feature bugfix implement\n(user input)"])
    FIX --> G3
```

| Command | Run by | What it does |
|---------|--------|-------------|
| `/feature bugfix report [description]` | PO | Clarify the bug interactively, resolve the originating story, open the dev bug issue on the sprint. |
| `/feature bugfix story <bug_issue>` | BA | Author Acceptance Criteria on the bug issue. |
| `/feature bugfix implement <bug_issue>` | Dev | Investigate root cause (draft + approve gate), then fix on the sprint branch — fresh or revisit. |
| `/feature merge <bug_issue>` | Dev | Squash-merge the reviewed fix PRs into the sprint branch. |

### 🧹 In-sprint refactors

Tech-debt cleanup scoped to the sprint, no user-visible behavior change.

```mermaid
flowchart TD
    A(["/feature refactor spec"]) --> B["Discovery dialog"]
    B --> C["Codebase exploration\n(sprint branch)"]
    C --> D["Refactor issue\non the sprint"]
    D --> G1{Gate 1\nReview spec}
    G1 -->|Approve| H(["/feature refactor implement"])
    H --> I["Branch from sprint"]
    I --> J["PR: refactor → sprint"]
    J --> G2{Gate 2\nCode review}
    G2 -->|Approve| M(["/feature merge"])
    M --> M1["Squash-merge → sprint"]
    M1 --> L([Lands on sprint\ncloses at /feature release])
```

| Command | Run by | What it does |
|---------|--------|-------------|
| `/feature refactor spec [description]` | Tech Lead | Draft an in-sprint refactor spec — discovery, sprint-branch exploration, draft + approve gate, file on the sprint. Create-only (no amend). |
| `/feature refactor implement <refactor_issue>` | Dev | Implement the spec on the sprint branch — preserves observable behaviour. |
| `/feature merge <refactor_issue>` | Dev | Squash-merge the reviewed refactor PRs into the sprint branch. |
