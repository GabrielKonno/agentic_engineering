# Template: project.md

> Create at `.claude/phases/project.md`

```markdown
# [Name] — Handoff Document

> **Purpose:** Entry point for every session. Read to understand where the project is, what has been decided, and what is next. Update at the end of every session.

## Overview

[Summarize PRD sections 1.1, 1.2, 1.3 in 2-3 paragraphs]

**Stack:** [from PRD section 5]
**Repository:** [if exists]
**Deploy:** [strategy]
**Database:** [provider]
**PRD version:** v1.0.0
**Risk profile:** [prototype | internal-tool | production | production-financial] — set at bootstrap; governs which ceremonies apply (see `.claude/rules/session-rules.md` → Risk profile & ceremony tiers)

---

## Architectural Decisions (defined — do not reopen)

| Decision | Choice | Reason |
|----------|--------|--------|
| [stack decisions] | [choice] | [reason from PRD] |

---

## Module Relationships

[ASCII diagram derived from PRD module dependencies:]

```
Module A ──→ Module B ──→ Module C
                │
                └──→ Module D
```

[List cross-module flows identified in PRD:]
- [Module A] creates data that [Module B] consumes
- [Module C] generates transactions in [Module D]

---

## Project Phases

For each phase from Build Order, ALWAYS include:
1. **Phase header** with objective, modules list, and completion criteria
2. **Module Breakdown** — for every module in the phase, include:
   - Module name and status indicator (⏳ / ✅)
   - 1-line objective
   - Key features (bullet list with concrete details: component names, data values, dimensions, IDs)
   - Key business rules that affect implementation (not all — only the ones an implementor needs to recall without reading the full PRD)
   - Integration points with other modules (cross-references)

The Module Breakdown is what makes project.md useful as a session entry point.
Without it, every session must re-read the full PRD to understand module scope.

### Phase 1 — [Name] ⏳

**Objective:** [what it delivers]
**Modules:** [list]
**Completion criteria:**
1. [verifiable criterion]
2. [verifiable criterion]

#### Module Breakdown

**[Module 3.X — Name]** ⏳
- [1-line objective]
- Key features: [F1] ..., [F2] ..., [F3] ...
- Key business rules: [BR1] ..., [BR2] ...
- Integration points: depends on [Module Y], consumed by [Module Z]

**[Module 3.Y — Name]** ⏳
- [repeat same structure]

---

## Progress Log

> Concise index. Detailed session records live in `.claude/logs/`.
> Decisions are reflected in the Architectural Decisions table and CLAUDE.md.

| Session | Date | Summary | Log |
|---------|------|---------|-----|
| 0 (Bootstrap) | [date] | PRD analyzed, docs + agents created, stack confirmed | — |

<!-- MODEL SWITCH markers (if any) appear below as full blocks. They are temporary —
     removed when the continuation session resolves and replaced by a normal index row. -->

---

## Domain Signals

> Tracks domain-specific logic and repeated processes across sessions.
> When a domain reaches 2+ sessions, `rules-agents-updater` evaluates
> whether to create a rules file (logic) or skill (process).

| Domain | Sessions | Type | Status |
|--------|----------|------|--------|

<!-- Rows added by project-md-updater. Status: "active" or "→ .claude/rules/[file].md" -->

---

## Validation Post-Mortem Ledger

> Profile: `internal-tool`+ (omit for `prototype`).
> One row per escape — a bug the owner found in a task that had validated ✅.
> Appended by the `validation-orchestrator` post-mortem (NOT just the prose fix).
> Purpose: make a RECURRING class of escape visible. When the same root-cause class
> appears 2+ times, the codebase-audit / framework-audit must treat it as a class with
> no owner and propose a systemic fix — not another one-off patch.

| Session | Escape (symptom) | Step that should have caught it | Root-cause class | Routed to (systemic fix) | Recurring? |
|---------|------------------|---------------------------------|------------------|--------------------------|------------|

<!-- Root-cause class values (stable vocabulary, so recurrence is detectable):
     weak-criterion | partial-verification | tool-silenced-error | review-missed-pattern |
     test-not-written | subagent-context-incomplete | spec-authoring-bug | ai-judgment-limit -->

---

*Last updated: [date]*
```
