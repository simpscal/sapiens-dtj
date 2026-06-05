# PR: Revert

## OUTPUT FORMAT

```
## Summary

Reverts the implementation of story <story_number> — <story_title>.

The story was removed from the requirement scope and the implementation must be undone.

## Reverts

- Original PR: <original_pr>
- Merge commit: `<merge_commit>`

## Acceptance Criteria

- [ ] All changes introduced by <original_pr> are absent from the sprint branch after merge

Closes <story_number>
```

---

## FIELDS

| Field | Req | Notes |
|-------|-----|-------|
| `story_number` | yes | `#N` format |
| `story_title` | yes | Verbatim from issue title — strip `[Story]` prefix |
| `original_pr` | yes | `#N` format |
| `merge_commit` | yes | Full SHA from `mergeCommitSha` |