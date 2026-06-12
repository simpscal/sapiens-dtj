# 🧹 Refactor Workflow

Tech-debt and structural cleanup, no user-visible behavior change.

## Flow

```mermaid
flowchart TD
    A(["/refactor spec create"]) --> B["Discovery dialog"]
    B --> C["Codebase exploration"]
    C --> D["Refactor issue"]
    D --> G1{Gate 1\nReview spec}
    G1 -->|Approve| H(["/refactor implement"])
    H --> I["Branch from main"]
    I --> J["PR: refactor → main"]
    J --> G2{Gate 2\nCode review}
    G2 -->|Approve| PRE(["/refactor pre-release"])
    PRE --> PRE1["Readiness + migration check"]
    PRE1 --> G3{Gate 3\nReview refactor PRs}
    G3 -->|Approve| REL(["/refactor release"])
    REL --> REL1["Merge + close"]
    REL1 --> L([Refactor shipped])
```

## Phases

| Command | Run by | What it does |
|---------|--------|-------------|
| `/refactor spec` | Tech Lead | Create or amend a refactor spec (draft + approve gate). |
| `/refactor implement <refactor_issue>` | Dev | Implement the spec — preserves observable behaviour. |
| `/refactor pre-release <refactor_issue>` | Release Mgr | Readiness gate, migration check, post summary. |
| `/refactor release <refactor_issue>` | Release Mgr | Merge refactor PRs, close issue. |
