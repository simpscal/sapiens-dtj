# Comment: Refactor Summary

## OUTPUT FORMAT

```
## Refactor Pre-release ✓

**Issue**: #N — <title>
**Date**: YYYY-MM-DD

### Migrations
<⚠️ Migration detected — run the cutover script (from the PR body) manually against production after deploy. | None>

---
> ⏸ Human gate: If a migration is present, run its cutover script from the PR body manually against production after deploy.
```

Omit `---` separator and human gate entirely when no migrations.

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `issue` | yes | `#N — <title>` — em dash `—`, exact GitHub title |
| `date` | yes | `YYYY-MM-DD` |
| `migrations` | yes | Warning phrase above or `None` — set when the refactor PR introduces a migration whose cutover script must be run by hand on production |
