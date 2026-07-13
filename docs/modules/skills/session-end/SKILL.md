---
name: session-end
invocation: user
effort: medium
description: >
  MUST run at the end of every implementation session. Orchestrates pattern
  extraction, session log, project/pendencias/config/rules updates in priority
  order. Without this, the next session starts with stale context and lost patterns.
created: framework-v2.1.0 (pre-validated)
derived_from: session_protocol "At the END of every session"
---

# Session End

## When to run

At the **end of every implementation session**, before the conversation closes.

Evolution classification and approval boundaries: see `.claude/rules/evolution-policy.md`.

## Session archetype branch (run FIRST)

Before executing the steps below, identify this session's archetype (see
`.claude/rules/session-rules.md` → Session archetypes). It determines which steps are
legitimately "N/A" versus required:

- **`implementation`** (default) — run ALL steps below as written.
- **`investigation`** — SKIP step 1 (no app diff to mine). Run steps 2-6; route findings to
  pendencias.md as tasks.
- **`framework-maintenance`** — SKIP step 1's app-code mining. Instead, for each agent/skill/rule
  edited, log the change classified as FIX/DERIVED/CAPTURED, and re-verify counts/activation
  chains. Run steps 2, 3, 6.
- **`ops`** — SKIP step 1. Update ops-rules + metrics.md (if present), log any incident +
  reconciliation outcome, then run steps 2, 3, 6.

A step skipped because the archetype makes it inapplicable is correct — not a shortcut. Do NOT
mark a step ⏭️ that the archetype actually requires.

## Process (in priority order)

**CRITICAL — load contracts before executing.** For every step below that references a `SKILL.md`, READ that file into context BEFORE executing the step. Do NOT execute sub-skills from memory — each skill's file contains requirements that are easy to forget or misremember (e.g., "move full metadata verbatim", "write BEFORE the other updater runs", specific field schemas). The file is the contract; your recollection is not.

### 1. Extract patterns from diff

Invoke `.claude/agents/diff-pattern-extractor.md` as subagent. Scans git diff, adds to Known Bug Patterns / Architecture Patterns. Isolated context.

### 2. Create session log + Update project.md

READ `.claude/skills/session-log-creator/SKILL.md` into context, THEN execute its process. Creates the detailed record in `.claude/logs/`.

READ `.claude/skills/project-md-updater/SKILL.md` into context, THEN execute its process. Writes index row referencing the log + PRD version + phase status.

### 3. Update pendencias.md

READ `.claude/skills/pendencias-updater/SKILL.md` into context, THEN execute its process. Moves completed tasks to `done_tasks.md` (full metadata, verbatim — never a summary) and adds new discoveries.

### 4. Update CLAUDE.md

READ `.claude/skills/config-file-updater/SKILL.md` into context, THEN execute its process. Updates module status, patterns, File Map when changed.

### 5. Update rules/agents/skills/PRD

READ `.claude/skills/rules-agents-updater/SKILL.md` into context, THEN execute its process. Creates rules files, updates agents with discoveries.

### 6. Self-verification

After steps 2–3, verify output integrity — defense in depth against summarizing what should be moved verbatim:

- **Session log:** `.claude/logs/[filename].md` exists and contains sections `## Tasks completed`, `## Validation Summary`, `## Files changed`.
- **project.md:** Progress Log table has a new row referencing the log filename from step 2.
- **done_tasks.md:** For each task completed this session, the entry contains ALL of: `**Context:**`, `**State:**`, `**Constraints:**`, `**Complexity:**`, `**Changes:**`, and at least one `[x]` criterion. A summary-line-only entry is a bug — redo step 3.
- **pendencias.md:** The tasks moved to done_tasks.md are no longer present in pendencias.md (no orphans in both files).
- **Drafts sweep (only if `.claude/skills/skill-gate/` exists):** `.claude/drafts/` contains no orphans — every remaining draft is either mid-review (marker set, cycle ≤ 3) or already tracked as a pendency. A draft with neither is a silent leak: register it in pendencias.md now ("draft [name] — resume or discard").

If any check fails, fix it in the same session — do NOT defer.

## Priority and context limits

Items 1-3 are the critical minimum. Items 4-5 can be deferred if context window is low.

**Item 6 (self-verification) MUST always run — never defer it.** It is fast and catches consistency bugs that would compound across sessions.

If severely limited: do at minimum items 2, 3, and 6 (session log + pendencias + verification), commit, and tell the user to start fresh.
