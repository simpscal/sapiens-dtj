---
name: github-templates
description: Use to format GitHub issue bodies, PR descriptions, and issue/PR comments via the project's template library. Pairs with `github` (issue ops), `git` (PR ops), and `dispatch-agents` (completion comments). Do NOT use for: freeform markdown, README content, or any document outside the issue/PR/comment surface.
tools: Read, Glob
---

# GitHub Templates

`render_template(name, fields)` is a convention, not a runtime function — shorthand for "look up the named template's reference file, fill in the fields per its spec, use the resulting markdown." The lookup-and-fill happens inside the agent.

## Workflow

1. Resolve the name against the Template Index. Unknown → stop: "Unknown template `<name>`. Known templates: <list>." No fuzzy-matching.
2. Read the reference file (path in the index) — authoritative for structure and field spec.
3. Validate fields per Field Conventions. Missing required → stop and list them. Extra fields → drop silently.
4. Render by filling fields per the reference. Return the markdown string; do not write to disk.

## Field Conventions

| Type | Spec notation | Render behaviour |
|------|---------------|------------------|
| `string` | `summary: string` | Inserted verbatim |
| `string?` | `description: string?` | Optional; whole section omitted if absent |
| `list<string>` | `changes: list<string>` | Bullet list, one item per line |
| `list<string>?` | `acceptance_criteria: list<string>?` | Optional; whole section omitted if absent |
| `issue_ref` | `closes: issue_ref` | Validated against `#N` format |
| `issue_ref?` | `depends_on: issue_ref?` | Optional |
| `list<issue_ref>` | `related: list<issue_ref>` | Validated; rendered comma-separated |
| `enum<a\|b\|c>` | `severity: enum<low\|medium\|high>` | Validated against allowed values |

Rules:

- Required field with no value → stop with a clear error listing the missing field(s).
- Optional field (`?`) with no value → omit the section entirely; no empty headings or placeholders.
- List with zero items → treat as absent (omit the section).
- Field values inserted verbatim — the caller handles markdown escaping within values.

## Template Index

| Template | `render_template()` name | Reference file |
|----------|--------------------------|----------------|
| Issue: User Story | `issue-user-story` | `references/issue-user-story.md` |
| Issue: Requirement | `issue-requirement` | `references/issue-requirement.md` |
| Issue: Bug Report | `issue-bug-report` | `references/issue-bug-report.md` |
| Issue: TDD | `issue-technical-design` | `references/issue-technical-design.md` |
| Acceptance Criteria | `acceptance-criteria` | `references/acceptance-criteria.md` |
| PR: Story | `pr-story` | `references/pr-story.md` |
| PR: Bug Fix | `pr-bug` | `references/pr-bug.md` |
| PR: Revert | `pr-revert` | `references/pr-revert.md` |
| PR: Release | `pr-release` | `references/pr-release.md` |
| PR: Design System | `pr-design-system` | `references/pr-design-system.md` |
| Comment: Sprint Summary | `comment-sprint-summary` | `references/comment-sprint-summary.md` |
| Comment: Dev Investigation | `comment-dev-investigation` | `references/comment-dev-investigation.md` |
| Comment: Bug Summary | `comment-bug-summary` | `references/comment-bug-summary.md` |
| Comment: Refactor Summary | `comment-refactor-summary` | `references/comment-refactor-summary.md` |
| Comment: Design Hub | `comment-design-hub` | `references/comment-design-hub.md` |
| Comment: Design Complete | `comment-design-complete` | `references/comment-design-complete.md` |
| Issue: Technical Story | `issue-technical-story` | `references/issue-technical-story.md` |
| PR: Refactor | `pr-refactor` | `references/pr-refactor.md` |

### Removed Templates

When a template is removed, add a row here with the replacement so old names get a clear migration path.

| Removed name | Replacement | Notes |
|--------------|-------------|-------|
| `issue-redesign-brief` | `issue-requirement` | Redesign now uses the same workflow as feature requirements |
| `comment-redesign-hub` | — | Redesign workflow removed |

## Reference File Format

Every file under `references/` follows this shape:

```markdown
# <Template name>

## Purpose

One-line description of when this template is used.

## Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| summary | string | yes | One-line summary of the change |
| changes | list<string> | yes | Per-file change descriptions |
| closes | issue_ref | yes | Issue number this PR closes |
| test_command | string? | no | Test command if applicable |

## Template

\`\`\`markdown
## Summary

{summary}

## Changes

{changes}

## How to verify

{test_command?}
{manual_verification?}

Closes {closes}
\`\`\`
```

Field markers in the template body:

- `{field}` — required; render verbatim.
- `{field?}` — optional; if absent, the line is omitted entirely (including surrounding whitespace).
- `{field}` for a list field — rendered as a bullet list.

## Constraints

- Never read template reference files outside `references/`.
- Never invent fields not in the reference spec.
- Never emit empty sections, placeholder text, or `{field}` markers in the output.
- Never write to disk — return the string; the caller decides what to do with it.
- Never fuzzy-match template names — exact match against the index or error.
- Reference files are the single source of truth; if this skill's body conflicts with a reference file, the reference file wins.
