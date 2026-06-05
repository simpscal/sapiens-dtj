# Issue: Bug Report

## OUTPUT FORMAT

```
## Bug Report

### Description
<1-2 sentences, user impact, understandable to non-technical>

### Steps to Reproduce
1. <step>
2. <step>

### Expected Behaviour
<what should happen>

### Actual Behaviour
<what actually happens>

### Severity
<critical | high | medium | low>

### Originating Story
#<originating_story_number>
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `description` | yes | 1-2 sentences, user impact — no class names or stack traces |
| `steps` | yes | 2-15 numbered steps, chronological, include preconditions |
| `expected` | yes | 1-2 sentences — what should happen |
| `actual` | yes | 1-3 sentences — what does happen; may include error messages |
| `severity` | yes | `critical` (data loss/security/all users) \| `high` (core feature broken) \| `medium` (workaround exists) \| `low` (cosmetic) |
| `originating_story` | no | Issue number (no `#`). Present only for development bugs. Omit entire `### Originating Story` section for production bugs. |
