# 🐛 Bugfix Workflow

Production bug lifecycle.

## Flow

```mermaid
flowchart TD
    A(["/bugfix report"]) --> CLS{Classify source}
    CLS -->|Production| B["Bug issue"]
    B --> G1{Gate 1\nReview bug}
    G1 -->|Approve| C(["/bugfix story"])
    C --> D["Acceptance criteria"]
    D --> G2{Gate 2\nReview ACs}
    G2 -->|Approve| H(["/bugfix implement"])
    H --> INV["Investigation\n+ approve gate"]
    INV --> I["Fix PR → staging"]
    I --> G3{Gate 3\nCode review}
    G3 -->|Merged| I2["Merge to staging"]
    I2 --> G4{Gate 4\nVerify on staging}
    G4 -->|Pass| PRE(["/bugfix pre-release"])
    PRE --> PRE1["Readiness + migration check"]
    PRE1 --> G5{Gate 5\nReview fix PRs}
    G5 -->|Approve| J(["/bugfix release"])
    J --> J1["Merge + close"]
    J1 --> K([Bug fixed])
    G4 -->|Still broken| FIX(["/bugfix implement\n(user input)"])
    FIX --> G4
```

## Phases

| Command | Run by | What it does |
|---------|--------|-------------|
| `/bugfix report [description]` | PO | Clarify bug interactively, open the production bug issue. |
| `/bugfix story <bug_issue>` | BA | Author Acceptance Criteria on the bug issue. |
| `/bugfix implement <bug_issue>` | Dev | Investigate root cause (draft + approve gate), then fix — fresh or revisit. |
| `/bugfix pre-release <bug_issue>` | Release Mgr | Readiness gate, migration check (production), post bug summary. |
| `/bugfix release <bug_issue>` | Release Mgr | Merge bugfix PRs, mark Done on the board, close issue. |
