---
name: setup:project-config
description: Generate `.claude/skills/project-config/SKILL.md` — gather codebases, detect tech stack, configure migration rules, write the skill file.
tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

# Setup — Project Config

## Workflow
1. Existence Check
2. Gather Codebase Names and Paths
3. Detect Tech Stack
4. Detect Component Inventory
5. Gather Migration Detection
6. Write the project-config Skill
7. Confirm
8. Next Step

## Existence Check

Check for `.claude/skills/project-config/SKILL.md`. Exists → ask via `AskUserQuestion`:

- **Skip** — keep untouched. Exit: `project-config skill already exists — no changes made.`
- **Regenerate** — overwrite.

Default option: Skip.

## Gather Codebase Names and Paths

Ask via `AskUserQuestion` for each codebase — all in one call, separate questions:

1. **API / backend** — name + path (e.g. `api` at `../my-api`).
2. **Web / frontend** — name + path (e.g. `web` at `../my-web`).
3. **Infrastructure** — name + path (e.g. `infrastructure` at `../my-api/terraform`). User may skip.

Parse name + path for each. Omit any the user skips.

## Detect Tech Stack

Per codebase path, detect the stack:

- `package.json` — Node.js / framework (check `dependencies` + `devDependencies` for Next.js, React, Vue, Express, NestJS, etc.).
- `*.csproj` or `*.sln` — .NET (check `TargetFramework`, check for EF Core packages).
- `requirements.txt` / `pyproject.toml` / `setup.py` — Python (Django, FastAPI, Flask, etc.).
- `pom.xml` — Java/Spring.
- `go.mod` — Go.
- `Gemfile` — Ruby/Rails.
- `Cargo.toml` — Rust.
- `pubspec.yaml` — Flutter/Dart.
- `build.gradle` — Kotlin/Java.
- `*.tf` + `versions.tf` — Terraform (check provider + resource types for AWS/GCP/Azure, note version constraint).

Resolve the path relative to the repo root. Inspect via `Glob` + `Read`. Compose a one-line summary per codebase (e.g. `Next.js 14 frontend with TypeScript`, `ASP.NET Core 8 REST API with EF Core`).

## Detect Component Inventory

Per frontend-framework codebase (React, Vue, Angular, Svelte, etc.), scan for the shared component directory:

- Look for directories commonly named `src/components/`, `src/ui/`, `components/`, `app/components/`, or equivalent.
- Check for a UI library (shadcn/ui, Radix, Chakra, Vuetify, etc.) — its output directory is typically the component directory.
- Multiple candidates → pick the one with the most `.tsx` / `.vue` / `.svelte` component files.

Hold the directory as `$COMPONENT_DIRS` — one entry per frontend codebase (codebase name → relative component directory path). Omit non-frontend codebases.

Then build `$COMPONENT_TABLE` — per frontend codebase in `$COMPONENT_DIRS`:

1. List all component files (`.tsx` / `.vue` / `.svelte`) in the detected directory (top-level only, skip subdirectories).
2. Per file, scan `export` statements → exported names (components, hooks, variant helpers, interfaces).
3. Infer a short purpose from name, props, underlying library (e.g. "Checkbox input (Radix)", "Content carousel (Embla)").
4. Hold as rows: `| {filename} | {exports} | {purpose} |`.

## Gather Migration Detection

Ask via `AskUserQuestion`:

> "Does any codebase run database migrations that should be detected in PRs? If yes, describe how (e.g. 'EF Core migrations live in the backend codebase at paths containing `/Migrations/`. Filter changed files for `/Migrations/` case-insensitively.'). If no, reply 'none'."

## Write the project-config Skill

Write `.claude/skills/project-config/SKILL.md` with the collected data. Copy frontmatter verbatim.

```markdown
---
name: project-config
description: Use to look up project-specific codebase paths, component inventory paths, and migration-detection rules. Auto-invoke whenever a workflow needs a codebase path (api, web, infrastructure), the component directory, or PR migration detection. Single source of truth — never hardcode any of these.
tools: Read
---

## Codebases

| Name | Path | Summary |
|------|------|---------|
{one row per codebase: | {name} | `{path}` | {summary} |}

## Component Inventory

Shared components live in `{codebase_name}` → `{component_dir}`.

| File | Export(s) | Purpose |
|------|-----------|---------|
{one row per component file from $COMPONENT_TABLE}

Feature, page, layout, and admin components live in their respective directories and are discoverable by reading the codebase.

{Omit this section entirely if $COMPONENT_DIRS is empty.}

## Migration Detection

{user's migration detection description, or "No migration detection configured." if none}
```

## Confirm

Output: `project-config skill written to .claude/skills/project-config/SKILL.md` with a summary of registered codebases.

## Next Step

project-config skill written. Next:

- `/setup provision the board`