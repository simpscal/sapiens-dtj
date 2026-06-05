# Comment: Sprint Summary

## OUTPUT FORMAT

```
## Sprint Closed ✓

**Sprint**: Sprint N
**Closed**: YYYY-MM-DD

### Stories shipped
| Issue | Title |
|-------|-------|
| #N | <title> |

### Release PRs
| Codebase | PR |
|----------|----|
| backend | [#N](https://github.com/<owner>/<repo>/pull/N) |
| frontend | [#N](https://github.com/<owner>/<repo>/pull/N) |

### Migrations
<⚠️ EF Core migrations detected — see backend PR for details. | None>

---
> ⏸ Human gate: Review and merge the release PRs into main. If migrations are present, run them on production after deploy.
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `sprint` | yes | `Sprint N` — match milestone name exactly |
| `closed_date` | yes | `YYYY-MM-DD` |
| `stories` | yes | All milestone stories, sorted by issue number ascending, exact GitHub titles |
| `release_prs` | yes | Changed codebases only — codebase name, full PR link in `[#N](url)` format |
| `migrations` | yes | Warning phrase above or `None` — detected by `**/Migrations/*.cs` in backend changes |
