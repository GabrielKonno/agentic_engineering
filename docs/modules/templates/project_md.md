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

[For each phase from Build Order:]

### Phase 1 — [Name] ⏳

**Objective:** [what it delivers]
**Modules:** [list]
**Completion criteria:**
1. [verifiable criterion]
2. [verifiable criterion]

[Repeat with detail from PRD: features, business rules, flows]

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

*Last updated: [date]*
```
