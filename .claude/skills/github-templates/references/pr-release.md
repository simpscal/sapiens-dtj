# PR: Release

## OUTPUT FORMAT

```
## Sprint N — Release PR

Merges all Sprint N stories into main.

## Stories
- Closes #<N> — <title>

## Migration notes
<If migrations:>
⚠️ EF Core migrations detected — apply before or after deploy:
  dotnet ef database update

  Files:
  - <migration file path>

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
| `stories` | yes | All milestone stories, `- Closes #N — <title>` with em dash, sorted by issue number ascending |
| `migrations` | yes | Warning block above (with file paths) or `No database migrations in this sprint.` — detected by `**/Migrations/*.cs` |
