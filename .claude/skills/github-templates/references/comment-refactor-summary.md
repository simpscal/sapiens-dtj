# Comment: Refactor Summary

## OUTPUT FORMAT

```
## Refactor Pre-release ✓

**Issue**: #N — <title>
**Date**: YYYY-MM-DD

### Migrations
<⚠️ EF Core migrations detected — apply on production after deploy. | None>

---
> ⏸ Human gate: If migrations are present, run them on production after deploy.
```

Omit `---` separator and human gate entirely when no migrations.

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `issue` | yes | `#N — <title>` — em dash `—`, exact GitHub title |
| `date` | yes | `YYYY-MM-DD` |
| `migrations` | yes | Warning phrase above or `None` — detected by `**/Migrations/*.cs` in the refactor backend PR |
