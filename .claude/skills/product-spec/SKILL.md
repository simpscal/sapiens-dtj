---
name: product-spec
description: Use when creating, amending, or editing `PRODUCT.md` — the foundational product context document covering Vision, Core Value Proposition, Business Model, Business Goals, Target Users, Product Boundaries, and Strategic Direction. Pairs with downstream skills (`user-stories` and `technical-design` reference Boundaries and Goals). Do NOT use for: PRDs, feature specs, roadmaps, OKRs, or any document that changes more than quarterly. Does not touch external systems; the caller owns all orchestration.
tools: Read, Write, Edit, AskUserQuestion
---

# PRODUCT.md Authoring

## Mode Detection

| `PRODUCT.md` present? | Intent verb in the request | Mode |
|-----------------------|----------------------------|------|
| no | create / set up / generate / init / draft | **Create** |
| yes | create / generate / regenerate | Confirm: **Skip** (default) or **Regenerate** |
| yes | rewrite / overhaul / start over | Confirm: **Skip** (default) or **Overwrite** |
| yes | amend / update / change / edit / revise | **Amend** |
| yes | read-only ("what's our vision?", "show me the boundaries") | Summarise; do not modify |

Both destructive ops (Regenerate, Overwrite) require confirmation; Skip is the default.

## Create

Confirm `PRODUCT.md` absent (or Regenerate/Overwrite chosen). Interview through the Question Bank in canonical section order, one `AskUserQuestion` each, applying Specificity Tests with follow-ups. Surface any out-of-canon content (offer a bottom section or omit). Run a consistency pass over all answers, resolve contradictions, then author `PRODUCT.md` at the repo root per File Structure with concrete content. Confirm with path + one-line summary per section.

## Amend

Read `PRODUCT.md` (absent → stop: ``No `PRODUCT.md` found. Create it first.``). Capture the full baseline verbatim — every section, subsection, and non-canonical content; non-targeted sections are preserved byte-for-byte. Determine target section(s) from the arg via Section Argument Map, else ask which. Offer cascade revisits (not forced):

- Vision → Core Value Proposition, Strategic Direction
- Target Users → Core Value Proposition, Product Boundaries
- Business Model → Business Goals, Strategic Direction

Interview the targeted section(s), apply Specificity Tests, run a consistency pass against the untouched baseline, then rewrite per Apply Rules and overwrite `PRODUCT.md`. Confirm the section(s) updated.

## Specificity Tests

Apply after every interview answer; on failure ask a focused follow-up.

**General (all sections):** could a new hire read this section alone and act consistently with it? If they'd need to ask "what did they really mean?", it fails.

| Section | Test |
|---------|------|
| Vision | Names a specific user, problem, and outcome. "Help people be more productive" fails; "Help engineering managers run 1:1s that surface blockers earlier" passes. |
| Core Value Proposition | Names the alternative being chosen against. "Faster checkout" fails; "Faster checkout than Shopify's default for stores with >10k SKUs" passes. |
| Business Model | Names who pays, what for, and roughly how much. Vague free-tier descriptions fail. |
| Business Goals | Each goal measurable or observable. "Improve user experience" fails; "Reduce time-to-first-value from 12 minutes to under 5" passes. |
| Target Users | Primary user is a single role with named pain points, not a demographic. "Millennials" fails; "Solo founders in their first year, juggling sales and product" passes. |
| Product Boundaries | In/Out of Scope each have a concrete example. "Various integrations" fails; "Stripe, Slack, Linear at launch — no Salesforce, no Microsoft stack" passes. |
| Strategic Direction | Names 1–2 priorities and one explicit non-priority. "Grow the platform" fails; "Q3: depth in analytics over breadth of integrations. Not chasing mobile parity this year." passes. |

After three failed follow-ups, offer to mark the section `Not yet defined` rather than write something vague.

## Contract

### File Structure

Pure markdown — no frontmatter, no version field. Seven canonical sections in immutable order:

```markdown
# Product Context

## Vision

{vision statement — one clear paragraph}

## Core Value Proposition

{single clearest reason a customer chooses this product over alternatives — one sentence or short paragraph}

## Business Model

{how the product makes money — one short paragraph}

## Business Goals

{each goal as a bullet point}

## Target Users

### Primary: {primary persona name or role}

{description of role, key needs, and pain points}

### Secondary: {secondary persona name or role}

{description — omit this subsection entirely if no secondary users were identified}

## Product Boundaries

### In Scope

{each in-scope capability as a bullet point}

### Out of Scope

{each exclusion as a bullet point — or "Not specified" if none given}

## Strategic Direction

{strategic direction as a paragraph; name 1–2 priorities and at least one explicit non-priority}
```

Non-canonical user-added sections, if any, appear at the bottom and are preserved untouched on amend.

### Section Argument Map

| Argument | Section |
|----------|---------|
| `vision` | Vision |
| `value` or `proposition` | Core Value Proposition |
| `model` | Business Model |
| `goals` | Business Goals |
| `users` | Target Users |
| `boundaries` | Product Boundaries |
| `strategy` or `direction` | Strategic Direction |
| `all` | All sections |
| Comma-separated list (e.g. `vision,value`) | Multiple sections |

### Interview Question Bank

Create asks each verbatim; Amend prefixes "the updated" or "now" where natural.

| Section | Question |
|---------|----------|
| Vision | "What is the product vision? Describe the problem it solves, for whom, and the core value it delivers." |
| Core Value Proposition | "What is the core value proposition? The single clearest reason a customer chooses this product over alternatives — name the alternative." |
| Business Model | "What is the business model? How does the product make money — who pays, what for, and roughly what's the price shape?" |
| Business Goals | "What are the 3–5 key business goals? List them as short, action-oriented, measurable statements (e.g. 'Grow monthly active users to 50k', 'Reduce average checkout time below 30s')." |
| Target Users | "Who are the target users? Describe the primary user as a specific role with named pain points. Include a secondary user if applicable." |
| Product Boundaries | "What is explicitly in scope for this product at launch? What is explicitly out of scope — even if it might seem like an obvious fit?" |
| Strategic Direction | "What is the current strategic direction? Name the 1–2 priorities for the next quarter or two, and at least one explicit non-priority — something you're choosing not to pursue." |

### Apply Rules

- **Create** writes the file end-to-end using File Structure. Every section gets concrete content — no placeholders, `{…}` braces, or "TBD".
- **Amend** edits only targeted section(s); every non-targeted section preserved byte-for-byte (headings, paragraphs, bullets, subsections, non-canonical sections at the bottom). Target `all` → rewrite all seven canonical sections, preserve non-canonical. Single section → rewrite only its body (and subsections), leave the heading unchanged.
- Specificity Test failing after three follow-ups and the user agrees → write `Not yet defined.` as the section body.

## Constraints

- Section order is immutable — seven sections in the File Structure order.
- Section headings match canonical names exactly.
- `### Secondary:` omitted entirely when no secondary user exists — no empty heading.
- `### Out of Scope` falls back to `Not specified` only when asked and explicitly given none.
- `PRODUCT.md` is pure markdown — no YAML frontmatter, `version` field, or metadata block.
- Never invent content — every body comes from interview answers or confirmed README-seeded suggestions.
- Never write placeholder braces (`{...}`) or "TBD" into the final file.
- Never silently overwrite an existing `PRODUCT.md` — always confirm.
- Never write skill-adjacent files (`ROADMAP.md`, etc.) — surface the suggestion, let the caller route.
- Filesystem: write only `PRODUCT.md`.
