---
name: design-theme
description: Use when creating, amending, or editing `DESIGN_THEME.md`. Owns the design-theme document — the binding, concrete design system consumed by the ui-design agent — Design Principles, Color Tokens, Typography, Spacing & Shape, Core Components, Layout Patterns, Imagery & Iconography, States & Feedback, Applying This System to New Pages.
tools: Read, Write, AskUserQuestion, WebSearch, WebFetch
---

# DESIGN_THEME.md Authoring

`DESIGN_THEME.md` = concrete design system, not a mood board — real token values (hex, px), a named type scale, a catalog of reusable components. Opinionated: a reviewer can call any surface on-theme or off. Theme is the source of truth for values — never scan a codebase.

Stack-agnostic — describe components by anatomy, variants, reuse; never by framework, library, or file path.

## Mode Detection

| `DESIGN_THEME.md` present? | Intent verb in the request | Mode |
|----------------------------|----------------------------|------|
| no | create / set up / generate / init / draft | **Create** |
| yes | create / generate / regenerate | Confirm: **Skip** (default) or **Regenerate** |
| yes | rewrite / overhaul / start over | Confirm: **Skip** (default) or **Overwrite** |
| yes | amend / update / change / edit / revise | **Amend** |
| yes | read-only ("what's our accent?", "show the component catalog") | Summarise; do not modify |

## Create

Confirm `DESIGN_THEME.md` absent (or Regenerate/Overwrite chosen). Then:

1. **Source selection** — ask via `AskUserQuestion` → `$SOURCE`:
   - **From a reference screen** — user supplies one or more screenshots / a link to a designed surface; derive the whole system from it (principles, tokens, type, components).
   - **Clone from existing product(s)** — user names 1–3 reference products (e.g. Linear, Stripe, DoorDash), optionally which aspects to take from each.
   - **From scratch** — interview only, no seeding.
2. **Reference/clone research** — reference screen → read it directly and extract concrete values (dominant accent, ink levels, radii, type weights, the repeating component shapes). Clone → per product, research its design language via `WebSearch` / `WebFetch` (design-system docs, brand guidelines, teardowns). Draft every section as concrete values + named components, not adjectives.
3. **Interview** — one `AskUserQuestion` per section in canonical order, seeded per `$SOURCE` ("derived from the reference: … — confirm / edit" or Question Bank verbatim). Apply Specificity Tests with follow-ups.
4. **Consistency pass** — resolve contradictions across sections (principles vs token usage vs component variants vs states); multiple sources → resolve clashes explicitly with the user.
5. **Write** `DESIGN_THEME.md` at the repo root per File Structure. Header = `# {Product} Design System` + a one-line italic design-intent subtitle; when derived, fold the provenance into that subtitle (`derived from the meal-detail reference screen`).
6. **Confirm** — path + one-line summary per section.

## Amend

Read `DESIGN_THEME.md` (absent → stop: ``No `DESIGN_THEME.md` found. Create it first.``). Capture the full baseline verbatim — every section, subtitle, non-canonical content; non-targeted sections preserved byte-for-byte. Determine target section(s) from the arg via Section Argument Map, else ask which. Accept free-text deltas (e.g. a forwarded divergence report from the ui-design agent). Offer cascade revisits (not forced):

- Design Principles → Color Tokens, Core Components, States & Feedback
- Color Tokens → States & Feedback, Core Components
- Spacing & Shape → Core Components, Layout Patterns
- Core Components → Layout Patterns, Applying This System to New Pages

Interview targeted section(s) → Specificity Tests → consistency pass against untouched baseline → rewrite per Apply Rules → overwrite `DESIGN_THEME.md` → confirm section(s) updated.

## Specificity Tests

Apply after every interview answer; on failure ask a focused follow-up.

**General (all sections):** could an AI designer who has never seen the app produce a surface a reviewer recognizes as on-theme? Every rule must be checkable — a reviewer can point at a screen and say pass/fail. Concrete over adjectival: a value, a threshold, or a named component beats a mood word.

| Section | Test |
|---------|------|
| Design Principles | Each principle has a memorable name + an app-wide rule that discriminates. "Clean and modern" fails; "Appetite-first: photography wins the hierarchy, chrome stays neutral" passes. |
| Color Tokens | Every token has a concrete value + a bounded usage, plus one rule capping the accent. "Use brand colors tastefully" fails; "`accent-primary #E8352F` on price + final CTA only; one loudest red per screen" passes. |
| Typography | Named family + a scale mapping each style → size/weight/tracking/usage. "Clear hierarchy" fails; "Display 32–40 Bold for dish names; Price 15–16 Bold always accent" passes. |
| Spacing & Shape | Base grid unit + radius scale + a rule giving each border style a meaning + an elevation stance. "Breathing room" fails; "8px grid; card radius 20–24; dashed border = optional only; single soft shadow on floating panels" passes. |
| Core Components | Each named component states anatomy + variant states + an explicit reuse list. "Nice buttons" fails; "Segmented Choice: pill row, single-select, active = black fill; reused for size / spice / time-slot / payment" passes. |
| Layout Patterns | The app-wide grid + desktop zone split + section-header pattern + mobile collapse rule. "Responsive" fails; "desktop two-zone 65–70 / 30–35 persistent panel; mobile → bottom sheet" passes. |
| Imagery & Iconography | Photography direction + an icon spec (stroke, caps, size). "Nice photos" fails; "top-down natural light, circular plate, no busy backgrounds; icons 1.5px thin-line rounded caps, 20px nav" passes. |
| States & Feedback | Hover / selected / disabled deltas + semantic color rules for values. "Good feedback" fails; "hover darken 8%; selected = black fill; discounts red `-`-prefixed; free = green, never red" passes. |
| Applying This System to New Pages | A decision checklist mapping screen questions → which components to reuse. "Stay consistent" fails; a numbered "browsing list → chips + card rows" checklist passes. |

After three failed follow-ups, offer to mark the section `Not yet defined` rather than write something vague.

## Contract

### File Structure

Pure markdown — no frontmatter, no version field. Header is `# {Product} Design System` followed by a one-line italic design-intent subtitle. Nine canonical sections in immutable order, numbered as below:

```markdown
# {Product} Design System
*{one-line design language intent; when derived, name the reference here}*

---

## 1. Design Principles

{4–6 named principles, each a bolded name + an app-wide rule — e.g. "**Appetite-first**: photography wins the hierarchy, chrome stays neutral"}

---

## 2. Color Tokens

| Token | Hex (approx) | Usage |
|---|---|---|
{every semantic token → concrete value → bounded usage — canvas, surface, subtle, accent + hover, ink primary/secondary/tertiary, borders, success, inverse}

**Rule of thumb:** {one sentence capping the accent — e.g. only one loudest red per screen}

---

## 3. Typography

**Family:** {named family or class}

| Style | Size | Weight | Tracking | Usage |
|---|---|---|---|---|
{Display, H2, Label/Eyebrow, Body, Meta, Price, Button Label → size range, weight, tracking, usage}

---

## 4. Spacing & Shape

{bullets: base grid unit; card + pill radius scale; thumbnail crop rule; border-weight rule giving dashed/solid distinct meaning; elevation stance (one soft shadow, floating panels only) + layering order}

---

## 5. Core Components

{one `###` sub-block per reusable component — Navigation Tabs, Filter Chips, Segmented Choice, Icon Toggle Grid, Quantity Stepper, contextual Primary CTA, Final CTA, List Row, Recommendation Card, Summary Panel, Promo/Tag Pill. Each: anatomy + variant states + explicit reuse list.}

---

## 6. Layout Patterns

{bullets: top-nav-bar composition; desktop main/side zone split with ratios; section-header pattern; mobile collapse rule}

---

## 7. Imagery & Iconography

{photography direction; icon spec — stroke, caps, monochrome, sizes}

---

## 8. States & Feedback

{hover / selected / disabled deltas; semantic value rules — discount/negative, free/positive; motion stance — duration/easing, what animates, what never, reduced-motion}

---

## 9. Applying This System to New Pages

{numbered decision checklist: screen question → components to reuse; final rule pinning the single red final action}
```

Optional bottom sections, only when defined: `## Accessibility Baseline` (only when exceeding the WCAG AA default). Non-canonical user-added sections appear at the bottom and are preserved untouched on amend.

### Section Argument Map

| Argument | Section |
|----------|---------|
| `principles` | Design Principles |
| `color`, `colors`, or `tokens` | Color Tokens |
| `typography` or `type` | Typography |
| `spacing` or `shape` | Spacing & Shape |
| `components` | Core Components |
| `layout` | Layout Patterns |
| `imagery`, `icons`, or `iconography` | Imagery & Iconography |
| `states` or `feedback` | States & Feedback |
| `applying` or `new-pages` | Applying This System to New Pages |
| `all` | All sections |
| Comma-separated list (e.g. `color,components`) | Multiple sections |

### Interview Question Bank

Create asks each verbatim; Amend prefixes "the updated" or "now" where natural. Reference/clone seeds each with the drafted content instead.

| Section | Question |
|---------|----------|
| Design Principles | "What 4–6 named principles govern the whole app? Each = a memorable name + one app-wide rule (e.g. 'Appetite-first: photography wins the hierarchy')." |
| Color Tokens | "What are the color tokens? Per token: a concrete value and a bounded usage. What single rule caps the accent color?" |
| Typography | "What type family, and what's the scale? Map each style (Display, H2, Eyebrow, Body, Meta, Price, Button) to size, weight, tracking, usage." |
| Spacing & Shape | "What's the base grid unit and radius scale? What does each border style mean, and what's the elevation stance?" |
| Core Components | "What are the reusable components? Per component: anatomy, variant states, and the list of surfaces that reuse it." |
| Layout Patterns | "What's the app-wide grid? Top-nav composition, desktop main/side zone split with ratios, section-header pattern, mobile collapse rule." |
| Imagery & Iconography | "What's the photography direction and the icon spec (stroke, caps, monochrome, sizes)?" |
| States & Feedback | "What are the hover / selected / disabled deltas, the value color rules (discount, free), and the motion stance?" |
| Applying This System to New Pages | "Give the decision checklist a designer runs for a new screen — screen question → components to reuse — ending with the single-red-final-action rule." |

### Apply Rules

- **Create** writes the file end-to-end via File Structure. Every section gets concrete content — no placeholders, `{…}` braces, "TBD".
- **Amend** edits only targeted section(s); non-targeted sections preserved byte-for-byte (headings, tables, bullets, subtitle, bottom non-canonical sections). Target `all` → rewrite all nine canonical sections, preserve non-canonical. Single section → rewrite only its body, leave heading + number unchanged.
- Specificity Test failing after three follow-ups + user agrees → write `Not yet defined.` as the section body.

## Constraints

- Section order is immutable — nine numbered sections in the File Structure order.
- Section headings match canonical names (and numbers) exactly.
- Color Tokens and Typography and Spacing carry **concrete values** (hex, px ranges, grid units); Core Components and States reference tokens by semantic name (`accent-primary`, `ink-secondary`), never re-spell the hex.
- Zero stack coupling — no framework, library, or file-path assumptions; components are described by anatomy + behavior, never implementation.
- `DESIGN_THEME.md` is pure markdown — no YAML frontmatter, `version` field, or metadata block.
- Never invent content — every value/component comes from interview answers, a supplied reference, or confirmed clone research.
- Never write placeholder braces (`{...}`) or "TBD" into the final file.
- Never silently overwrite an existing `DESIGN_THEME.md` — always confirm.
- Filesystem: write only `DESIGN_THEME.md`.
