# Issue: Technical Story

`[Tech]` issues carry the `user-story` label; title prefix discriminates from `[Story]`. ACs are developer-verifiable (build passes, schema applies, primitive matches contract) — never user-observable. See `acceptance-criteria.md` for AC format.

## OUTPUT FORMAT

```
## Scope
<one-sentence description of the foundational work>

<Acceptance Criteria + Notes from acceptance-criteria.md>

---
Part of #tdd_issue
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `scope_summary` | yes | One sentence — what gets built (e.g. `Add notes table + indexes`, `Add shared <Editor> primitive`) |
| `acceptance_criteria` | yes | Developer-verifiable only — see `acceptance-criteria.md` |
| `notes` | no | Edge cases; `Depends on: #<tech-issue>`; `Required by: #<user-story>` (back-filled after persistence) |
| `tdd_issue` | yes | Format as `#id` (e.g. `#42`) |
