# PR: Release

## OUTPUT FORMAT

```
## Sprint N — Release PR

Merges all Sprint N stories into main.

## Stories
- Closes #<N> — <title>

## Migration notes
<If migrations — list each migration's scripts inline, in apply order:>
⚠️ Migration detected — run the cutover script(s) below manually against production after deploy.

**<migration name>** — from the sprint TDD Migration Plan

_Up (cutover):_
<cutover SQL, fenced as ```sql>

_Down (rollback):_
<rollback SQL, fenced as ```sql>

<If no migrations:>
No database migrations in this sprint.

## Checklist
- [ ] All story PRs merged into sprint branch
- [ ] Migration scripts reviewed (if any)
- [ ] Lint and tests pass on sprint branch
- [ ] QA sign-off
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `sprint` | yes | e.g. `Sprint 5` — used in title and description |
| `stories` | yes | All sprint stories, `- Closes #N — <title>` with em dash, sorted by issue number ascending |
| `migrations` | yes | Warning block above with each migration's cutover + rollback SQL listed inline (in apply order), sourced from the sprint TDD's Migration Plan, or `No database migrations in this sprint.` — presence detection rule from the `project-config` skill |
