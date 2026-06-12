---
name: technical-design
description: Use when writing, revising, or reviewing a Technical Design Document (TDD) for a feature, epic, or set of user stories. Pairs with the `user-stories` skill — typically run after stories exist. Probes the codebase to ground decisions in existing patterns, produces a design across backend/frontend/infrastructure, and decomposes foundational work into `[Tech]` stories. Do NOT use for product scope decisions (caller owns those), PRDs, user-facing story authoring (use `user-stories`), or pure code review. Does not touch external systems; the caller owns all orchestration.
tools: Read, Edit, Write, Glob, Grep, Bash, AskUserQuestion, Agent
---

# Technical Design Expertise

## Workflow

Resolve in-scope roles → probe each role's codebase → fold in design context if supplied (Design context) → run Discovery (answer from probe findings; unresolvable items become blockers) → surface blockers in one message before drafting → draft the canonical sections in order → decompose foundational work into `[Tech]` stories → validate against Output Rules and Constraints. For revisions, also classify scope impact per story (Scope Classification).

## In-scope Resolution

| Role | In scope when stories or context imply… |
|------|-----------------------------------------|
| `backend` | persisted data, new API contract, new event, background job, auth/authz rule, server-side computation |
| `frontend` | user-facing surface, page, component, interaction, client-side state/persistence |
| `infrastructure` | new cloud resource, queue, cache, third-party integration, IaC module change, environment config |

A role not in scope → mark its sections `N/A — out of scope`, do not omit.

## Per-role Probe Briefs

Read `CLAUDE.md` (+ any role-scoped equivalent) before probing. Probe until you can answer the Discovery categories for in-scope roles:

- Located closest existing analogue for each new component.
- Identified convention to follow or diverge from.
- Named where each new piece lives.

Unresolved item -> Discovery blocker. Don't probe indefinitely.

| Role | What to explore |
|------|-----------------|
| `backend` | Existing entities, models, DB tables; command/query handlers, services, repositories; API controllers/routes; auth/authz patterns. Record file paths, names, conventions, gaps. |
| `frontend` | Existing pages, routes, feature folders; components; API client calls/hooks; state slices/query keys. Shared primitives/components/tokens — exist or closest analogue. Record file paths, names, conventions, gaps. |
| `infrastructure` | Existing modules/resources for the implied capability; config to extend. Record resource names, types, conventions, gaps. |

## Design context

Caller-supplied design context (Storybook surface stories) grounds frontend component + scope decisions.

**placeholder** blocks within stories = existing areas the sprint doesn't change (artifacts from `ui-design` agent, not new scope). Ignore them -> derive no components, data models, API surface, or `[Tech]` stories from placeholder regions. Design only the changed/new areas.

## Discovery Categories

Answer from codebase context first; only unresolvable items become blockers. When surfacing a blocker, state what you inferred -> targeted answer.

| Category | Decisions |
|----------|-----------|
| Data ownership | New table vs extend? Which service/DB owns? Shared? |
| Auth & authorisation | Roles/permissions? Resource or role level? |
| API surface | New endpoints or extend? REST or event-driven? Versioning? |
| Integration boundaries | External services? Contract ownership? |
| NFRs | Latency/throughput targets? Data volume? SLA? |
| Real-time vs async | Live updates, webhooks, polling, batch? |
| Migration & compatibility | Data to migrate? Destructive schema? Backward compat? |
| Infrastructure constraints | Cloud/region/cost limits? |
| Rollout | Feature flag? Gradual? Rollback trigger? |
| Cross-team | Blocking/blocked? Shared contracts? |

## Canonical Sections

Cover every area in this order. Write `N/A — <reason>` where inapplicable. Use ASCII art for all diagrams.

| # | Field | Define |
|---|-------|--------|
| 1 | `high_level_diagram` | Services, databases, caches, third-party — label new vs existing |
| 2 | `data_models` | Entities, relationships, indexes — ERD or schema |
| 3 | `api_spec` | Method, route, auth, request/response, status codes |
| 4 | `event_schemas` | Topic, structure, producer, consumer — or `N/A` |
| 5 | `happy_path` | sequence diagram. Participants must be high-level system modules only: actors (e.g. Customer, Admin) and major system boundaries (e.g. Web, API, Database, External Service). Omit all implementation details — internal libraries, state managers, hooks, query clients, and sub-components must not appear as participants. |
| 6 | `unhappy_path` | Key failure scenario and system response |
| 7 | `components_design` | **Backend** + **Frontend** sub-sections. High-level actors only (e.g. endpoint, validator, handler, specification, repository; page, UI sub-component, API client, model layer) — one-phrase responsibility each, tagged `[NEW]`/`[MODIFIED]`/existing; interconnections shown via ASCII box-and-arrow diagram. No code-level details: no method signatures, class members, validation rules, query keys, hooks wiring, or prop/state specifics. Design decisions (contracts, ordering guarantees, where a responsibility lives) go as terse notes next to the diagram. |
| 8 | `infrastructure_design` | Cloud resources added/modified; IaC changes. `None` if unchanged. |
| 9 | `tech_stack` | New languages/frameworks/libraries/infra only |
| 10 | `security` | Auth, authz, encryption at rest and in transit |
| 11 | `scalability` | Throughput/latency targets, query design, caching, async |
| 12 | `failure_modes` | Min 2 rows: Scenario, Impact, Mitigation |
| 13 | `migration` | Data migration, cutover, rollback — or `N/A` |
| 14 | `monitoring` | Key metrics, alert thresholds |
| 15 | `technical_stories` | Table: Title, Scope, Required by, Key ACs |

## Technical Story Decomposition

Emit one `[Tech]` story per discrete piece of foundational work satisfying **all**:

- Enables user stories but not user-observable on its own.
- Developer-verifiable completion condition (build passes, migration runs, primitive matches contract, endpoint returns documented shape).
- Can't split further into independently-shippable items.

Qualifies: shared component/design primitive, schema migration, IaC module, auth middleware, new event topic + producer scaffold, shared API client.
Doesn't qualify (fold into owning user story): single endpoint for one story, single page's local state, copy changes, one-off validation rules.

`[Tech]` ACs developer-verifiable only — never user-observable. Link dependent user stories via `required_by_titles`.

## Scope Classification (revisions only)

When revising, compare the revised TDD against each user story (ignore `[Tech]` stories). Emit a classification table at the end of the revised TDD.

| Classification | Condition | Action |
|----------------|-----------|--------|
| `additive` | Adds new behaviour; existing implementation remains valid | Flag for incremental work; no rework |
| `breaking` | Conflicts with existing implementation | Surface affected files/endpoints; caller decides regenerate vs migrate |
| `structural` | Requires full revisit; treat affected files as blank slate | List affected files; recommend story regeneration |
| `unaffected` | Story not touched | Note and move on |

## Technical-story Spec

```yaml
- title: "[Tech] <work item>"
  scope_summary: "<one sentence>"
  acceptance_criteria:
    - "<developer-verifiable AC>"
  notes:
    edge_cases: ["<text>", ...]
    references: [{label: "<text>", url: "<url>"}, ...]
    depends_on_titles: ["<title>", ...]
  required_by_titles: ["<user-story title>", ...]
```

## Output Rules

- Follow Canonical Sections order — never reorder.
- Make risks + trade-offs explicit. Rejected an alternative under the current design -> say why in one line. Never narrate a prior version's approach as a rejected alternative.
- Revised TDD = clean snapshot of the current target design, never a diff against a prior version. Every section in present tense. No change-narration ("previously/now/changed from", "no longer references", "New in this revision", changelog prose), no superseded/prior-version decisions carried forward. Old-code removal = `[Tech]` story scope, not a design section. Distinct from the codebase-relative `[NEW]`/`[MODIFIED]`/existing actor tags in Components Design — those stay.
- Tables for contracts, schemas, failure modes; ASCII art for diagrams.
- Terse + direct — fewest words per idea, no filler or restated context. Bullets/numbered lists over long paragraphs.
- Components Design at actor level only — high-level actors + interconnections. Implementation specifics (signatures, members, query keys, state wiring) never appear anywhere in the TDD.
- Ground every decision in codebase context — cite file paths, existing components, conventions. Justify any divergence.

## Constraints

- Never invent scope — run Discovery; do not assume product behaviour the caller hasn't specified.
- Never decide product scope — surface as a blocker if missing.
- Never add user-observable behaviour to `[Tech]` story ACs.
- Never touch GitHub or external systems.
- Filesystem: this skill's directory and in-scope codebase paths only.
