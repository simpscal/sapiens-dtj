# PR: Bug Fix

## OUTPUT FORMAT

```
## Root Cause
<1 sentence: why the bug occurred>

## Fix
<1–2 sentences: what was changed and why it resolves the root cause>

## Acceptance Criteria
- [x] <AC verbatim from issue>

## Risk
<Low / Medium / High — rationale from Dev Investigation>

Refs [#<parent_issue>](<parent_issue_url>)
```

---

## FIELDS

| Field | Required | Notes |
|-------|----------|-------|
| `root_cause` | yes | 1 sentence from Dev Investigation comment — plain language, no file paths |
| `fix` | yes | 1–2 sentences describing what changed and why it fixes the root cause |
| `acceptance_criteria` | yes | Copied verbatim from issue, all checked `[x]` |
| `risk` | yes | Low / Medium / High + rationale from Dev Investigation comment |
| `parent_issue` | yes | Parent bug issue number (no `#`) — rendered inside link text |
| `parent_issue_url` | yes | Full GitHub URL of parent issue — fetch via `gh issue view <N> --json url -q .url`. No auto-close |
