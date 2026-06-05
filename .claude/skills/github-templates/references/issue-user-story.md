# Issue: User Story

See `acceptance-criteria.md` for AC format.

## OUTPUT FORMAT

```
## User Story
As a <role>, I want <action> so that <benefit>

<Acceptance Criteria + Notes from acceptance-criteria.md>

---
Part of #requirement_issue_number
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `user_story` | yes | `As a <role>, I want <action> so that <benefit>` — specific role, user need, not implementation |
| `acceptance_criteria` | yes | See `acceptance-criteria.md` |
| `notes` | no | Edge cases, dependencies |
| `requirement_issue` | yes | Format as `#id` (e.g. `#17`) |
