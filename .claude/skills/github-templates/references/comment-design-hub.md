# Comment: Design Hub

## OUTPUT FORMAT

```
## Design Navigation

### Storybook
[View in Storybook](<storybook URL or local dev instructions>)

### Surfaces
| Surface | Route | Storybook Story |
|---------|-------|-----------------|
| <name>  | <route> | [<story file>](<blob URL>) |
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `storybook` | yes | URL to the running Storybook instance or instructions to run locally |
| `surfaces` | yes | Table: per row, surface name + route + story blob URL |

Posted on the sprint's scope-of-record issue (the requirement issue) — navigation hub for the sprint's design artifacts. Implementers follow the per-surface links to read the Storybook stories before writing code.
