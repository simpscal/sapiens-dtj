# PR: Designs

## OUTPUT FORMAT

```
## Summary
<1-2 sentences: which surfaces were designed/updated and why>

## Surfaces
- **<Surface name>** — <one-line layout; states covered>

## Component changes
<!-- omit this whole section when component_changes is empty -->
- **<Component name>** (<new | modified>) — <one-line what changed>

Refs [#<requirement_issue>](<requirement_issue_url>)
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `summary` | yes | 1-2 sentences: which surfaces + why |
| `surfaces` | yes | One row per composed surface — name + layout + states covered |
| `component_changes` | no | One row per shared component authored/extended — name + new\|modified + summary. Empty → omit the whole section |
| `requirement_issue` | yes | Parent requirement issue number (no `#`) |
| `requirement_issue_url` | yes | Full GitHub URL of parent issue |
