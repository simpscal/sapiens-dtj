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
<⚠️ Migration detected — run the cutover script from the backend PR body manually against production after deploy. | None>

---
> ⏸ Human gate: Review and merge the release PRs into main. If a migration is present, run its cutover script from the PR body manually against production after deploy.
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `sprint` | yes | `Sprint N` — match the board Sprint option name exactly |
| `closed_date` | yes | `YYYY-MM-DD` |
| `stories` | yes | All sprint stories, sorted by issue number ascending, exact GitHub titles |
| `release_prs` | yes | Changed codebases only — codebase name, full PR link in `[#N](url)` format |
| `migrations` | yes | Warning phrase above or `None` — set when backend changes introduce a migration whose cutover script must be run by hand on production (detection rule from the `project-config` skill) |
