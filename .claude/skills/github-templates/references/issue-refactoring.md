# Issue: Refactoring Task

## OUTPUT FORMAT

````
## Refactoring Task

### Problem Statement
- <one concrete pain point — tech debt, tight coupling, performance, maintainability, cost>
- <next pain point>

### Motivation
<what this unlocks or improves>

### Scope
- <file / module / layer>

### Technical Approach

> Group order is mandatory: **Pre-flight → Infrastructure → Backend → Frontend → Verification & Cleanup**. Skip any group whose codebase is not affected. Within Pre-flight and Verification & Cleanup, cross-cutting steps run once.

**Pre-flight** (cross-cutting, run once):
1. <step>

**Infrastructure** (`<infra path>`):
1. <step>

**Backend** (`<backend repo>`):
1. <step>

**Frontend** (`<frontend repo>`):
1. <step>

**Verification & Cleanup** (cross-cutting, run after all codebase groups finish):
1. <step>

### Trade-offs
- **Wins**: <what the chosen approach buys>
- **Costs**: <what the team will live with — boilerplate, indirection, runtime, maintenance/drift>

### Migration Plan
- **Data migration**: <schema / data / state to migrate, or none>
- **Cutover**:
```sql
<forward DDL>
```
- **Rollback**:
```sql
<reverse DDL>
```

### Affected Codebases
- <backend | frontend | infrastructure>

### Definition of Done
- [ ] All existing tests pass
- [ ] No user-visible behavior change
- [ ] <additional specific DoD item>
````

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `problem_statement` | yes | Bullet list — one pain point per bullet |
| `motivation` | yes | what improves or becomes possible |
| `scope` | yes | Bullet list of specific files, modules, or layers |
| `technical_approach` | yes | Steps under the fixed subheadings shown, in that order; skip unaffected groups; numbering resets per group |
| `trade_offs` | yes | Bullets — **Wins**, **Costs** |
| `migration` | yes | **Data migration** bullet + fenced ```sql **Cutover** + **Rollback** DDL — or the single bullet `N/A — no data migration required` |
| `affected_codebases` | yes | `backend` \| `frontend` \| `infrastructure` — one per line |
| `definition_of_done` | yes | Always include "All existing tests pass" and "No user-visible behavior change"; add specifics |
