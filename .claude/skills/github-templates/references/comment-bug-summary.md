# Comment: Bug Summary

## OUTPUT FORMAT

```
## Bug Closed ✓

**Issue**: #N — <title>
**Closed**: YYYY-MM-DD

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
| `closed_date` | yes | `YYYY-MM-DD` |
| `migrations` | yes | Warning phrase above or `None` — detected by `**/Migrations/*.cs` in merged backend PR |
