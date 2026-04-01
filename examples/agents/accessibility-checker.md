---
name: accessibility-checker
invocation: subagent
effort: medium
description: >
  USE PROACTIVELY when diff modifies UI components, forms, navigation, or
  interactive elements, or when code-reviewer declares an accessibility gap.
  NOT needed for backend-only or API-only changes. Without this, WCAG 2.1 AA
  violations pass code review where only basic ARIA checks are performed.
  Produces Accessibility Audit Report → APPROVE / FIX REQUIRED.
created: example (framework reference template)
last_eval: none (reference template — eval at project creation)
fixes: []
derived_from: null
---

# Accessibility Checker

## When spawned

This agent is typically invoked by main Claude after receiving a code-reviewer
report that declares an accessibility gap. It may also be invoked directly
when the diff's domain is recognized via this agent's description.

**Context to include in prompt:**
- Git diff (`git diff HEAD~1`)
- Code Review Report (if accessibility gap triggered this invocation)
- All `.claude/rules/*.md` files
- CLAUDE.md: Key Patterns and Architecture sections

**What main Claude should do with this report:**
- `APPROVE` → accessibility coverage ✅ — include as evidence in validator prompt
- `FIX REQUIRED` → accessibility ❌ — list findings in validation report, address before proceeding

## When to invoke

After implementing or modifying:
- Forms (inputs, labels, validation, error messages)
- Navigation (menus, breadcrumbs, skip links)
- Interactive components (modals, dropdowns, tabs, accordions)
- Data display (tables, charts, status indicators)
- Media (images, videos, audio)

## Skip when

- Changes are backend-only (API, database, server logic)
- Changes are styling-only with no structural impact (colors within existing contrast ratios)

## Checklist

### Semantic HTML
- [ ] Headings follow hierarchy — no skipped levels (h1 → h3 without h2)
- [ ] Landmarks used — `<main>`, `<nav>`, `<header>`, `<footer>`, `<aside>` present
- [ ] Lists use `<ul>`/`<ol>` — not divs with visual bullets
- [ ] Tables have `<th>` with `scope` — data tables are not layout tables
- [ ] Buttons are `<button>` — not `<div onClick>` or `<a>` without href

### Keyboard Navigation
- [ ] All interactive elements focusable — tab order follows visual order
- [ ] Focus visible — focus indicator is visible (not `outline: none` without replacement)
- [ ] Escape closes modals/dropdowns — and returns focus to trigger element
- [ ] No keyboard traps — user can tab out of any component
- [ ] Arrow keys work in composite widgets — tabs, menus, radio groups

### Screen Readers
- [ ] Images have alt text — decorative images use `alt=""`, meaningful images describe content
- [ ] Form inputs have labels — `<label>` with `htmlFor` or `aria-label`/`aria-labelledby`
- [ ] Error messages announced — validation errors linked via `aria-describedby` or live regions
- [ ] Dynamic content announced — `aria-live="polite"` for async updates (toasts, loading states)
- [ ] Icons with meaning have labels — icon-only buttons have `aria-label`

### Visual
- [ ] Color contrast 4.5:1 minimum — text against background (3:1 for large text)
- [ ] Information not color-only — status uses icon + color, not color alone
- [ ] Text resizable to 200% — no content loss or overlap at 2x zoom
- [ ] Reduced motion respected — `@media (prefers-reduced-motion: reduce)` disables animations
- [ ] Touch targets 44x44px minimum — on mobile interfaces

### Forms
- [ ] Required fields indicated — visually and programmatically (`aria-required="true"`)
- [ ] Error messages specific — "Email is required" not "Field is invalid"
- [ ] Autocomplete attributes set — `autocomplete="email"`, `autocomplete="name"`, etc.
- [ ] Form submission feedback — success/error communicated to screen readers

## Output Format

```
## Accessibility Audit: [component/page]

### WCAG Level: [A / AA / AAA target]
### Issues found: [N]
| # | Level | Criterion | Issue | Element | Fix |
|---|-------|-----------|-------|---------|-----|
| 1 | A/AA | [e.g., 1.1.1 Non-text Content] | [what] | [selector/component] | [how] |

### Automated checks:
- axe-core: [N violations / N passes]
- Lighthouse accessibility: [score]

### Recommendation: APPROVE / FIX REQUIRED
```
