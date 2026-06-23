# Comment: Dev Investigation

## OUTPUT FORMAT

````
## Dev Investigation

**Complexity**: <S | M | L>

### Root Cause
- <plain English WHY the bug occurs — no file paths, class names, or layer names>

### Scope
<product area affected — no code locations>

### Fix Approach
[frontend | backend | devops | frontend + backend | ...]

- **<Action>** — <rationale>

### Risk
<Low — ... | Medium — migration required: ... | High — ...>

### Migration Plan
<Only when the fix needs a migration — per migration in apply order:>
**<migration name>**

_Up (cutover):_
```sql
<cutover DDL>
```

_Down (rollback):_
```sql
<rollback DDL>
```
````

Omit the `### Migration Plan` section entirely when no migration.

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `complexity` | yes | `S` (<4h, isolated) \| `M` (4-8h, one layer) \| `L` (>8h, cross-cutting) |
| `root_cause` | yes | Plain English WHY — no file paths, class names, or layer names; audience is non-technical |
| `scope` | yes | Product area affected — no code locations |
| `fix_approach` | yes | Opens with `[side]` tag; imperative bullets (Add/Update/Remove), no code snippets |
| `risk` | yes | `Low — ...` \| `Medium — migration required: ...` \| `High — ...` |
| `migration` | no | When the fix needs a migration: per migration in apply order, fenced ```sql Up (cutover) + Down (rollback) DDL. Omit the section when none |
