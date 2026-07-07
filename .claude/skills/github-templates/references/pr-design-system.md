# PR: Design System

## OUTPUT FORMAT

```
## Summary
<1-2 sentences: what was conformed/authored and why — tokens follow DESIGN_THEME.md, Storybook stories authored>

## Tokens
- **<role>** — <old> → <new>

## Component Refactor
- **<Component>** — <change>

## Token Stories
Colors · Borders · Typography · Elevation · Radius

## Component Stories
- **<Category>** — <count>
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `summary` | yes | 1-2 sentences: what changed + why (tokens conformed to `DESIGN_THEME.md`, component kit refactored, stories authored) |
| `tokens_changed` | yes | One row per adjusted token role — role + old → new value |
| `components_refactored` | yes | One row per refactored component — component + change. Zero refactors → omit the section |
| `token_stories` | yes | The five token stories authored/refreshed |
| `component_categories` | yes | One row per category — category + story count |
