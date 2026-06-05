# Issue: Refactoring Task

## OUTPUT FORMAT

```
## Refactoring Task

### Problem Statement
- <one concrete pain point — tech debt, tight coupling, performance, maintainability, cost>
- <next pain point>

### Motivation
<what this unlocks or improves once complete>

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

### Affected Codebases
- <backend | frontend | infrastructure>

### Definition of Done
- [ ] All existing tests pass
- [ ] No user-visible behavior change
- [ ] <additional specific DoD item>
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `problem_statement` | yes | Bullet list — direct, one pain point per bullet, specific and technical (no prose paragraphs) |
| `motivation` | yes | 1–2 sentences — what improves or becomes possible |
| `scope` | yes | Bullet list of specific files, modules, or layers |
| `technical_approach` | yes | Group steps under fixed subheadings — Pre-flight, Infrastructure, Backend, Frontend, Verification & Cleanup — in that order. Skip groups whose codebase is not affected. Number steps within each group (`1.` resets per group). |
| `affected_codebases` | yes | `backend` \| `frontend` \| `infrastructure` — one per line |
| `definition_of_done` | yes | Always include "All existing tests pass" and "No user-visible behavior change"; add specifics |
