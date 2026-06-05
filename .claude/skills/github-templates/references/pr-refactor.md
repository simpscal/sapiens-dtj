# PR: Refactor

## OUTPUT FORMAT

```
## Refactor

### Problem
<1 sentence: why this refactor was needed>

Refs [#<parent_issue>](<parent_issue_url>)
```

---

## FIELDS

| Field | Required | Notes |
|-------|----------|-------|
| `problem` | yes | 1 sentence — plain language, no file paths |
| `parent_issue` | yes | Parent refactoring task issue number (no `#`) — rendered inside link text |
| `parent_issue_url` | yes | Full GitHub URL of parent issue — fetch via `gh issue view <N> --json url -q .url`. No auto-close |
