# PR: Design System

## OUTPUT FORMAT

```
## Summary
<1-2 sentences: what changed in the design system and why>

## Design Direction
- **Atmosphere:** <atmosphere summary>
- **Layout pattern:** <layout pattern>

Refs [#<requirement_issue>](<requirement_issue_url>)
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `summary` | yes | 1-2 sentences: what changed + why |
| `atmosphere` | yes | From `$DESIGN_INTENT.atmosphere` |
| `layout_pattern` | yes | From `$DESIGN_INTENT.layout_pattern` |
| `requirement_issue` | yes | Parent requirement issue number (no `#`) |
| `requirement_issue_url` | yes | Full GitHub URL of parent issue |
