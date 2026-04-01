---
name: session-log-creator
invocation: inline
effort: medium
description: >
  Creates a permanent session log file at end of every session. Primary detailed
  record — includes reasoning, alternatives, errors, and full git output. MUST run
  BEFORE project-md-updater (which references the log filename). Without logs,
  debugging past decisions requires re-reading all session context.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 2
---

# Session Log Creator

## When to run
At the END of every session, BEFORE project-md-updater (needs log filename for index row).

## Process

### 1. Generate filename

**Format:** `YYYYMMDD_sN_slug.md`
- `YYYYMMDD` — date
- `sN` — session number
- `slug` — 2-4 word kebab-case summary

Example: `20260326_s12_financial-closing-sprint.md`

### 2. Write log file

Save to `.claude/logs/[filename]`:

```markdown
# Session [N] — [date]

## Summary
[1-2 sentences: goal, outcome, project state now.]

## Tasks completed
- [task]: [approach, key decisions]

## Validation Summary

### [Task name]
- **Complexity:** routine | logic-heavy | architecture/security
- **Route:** inline checklist | subagent chain
- **Subagents:** [inline checklist | code-reviewer → validator | code-reviewer → security-reviewer → validator | etc.]
- **Specialists spawned:** [none | list with gap that triggered them]
- **Result:**
  - Build: ✅  Tests: ✅  Review: ✅  Security: ⏭️  UI: ⏭️  Migration: ⏭️
- **Retries:** 0 | [N — brief reason for each ❌ → fix cycle]
- **Human verification:** [none | list of MANUAL: criteria]
- **Key findings:** [none | non-trivial findings from reviewers, even if overall ✅]

[Repeat for each task validated in this session]

## Decisions made (and why)
- [decision]: [reasoning, alternatives, trade-offs]

## Bugs found and fixed
- [bug]: [root cause, fix, pattern added?]

## Discoveries
- [unexpected findings]

## Files changed
[git diff --stat]

## Commits
[git log --oneline for this session]

## Evolutions applied
- [FIX/DERIVED/CAPTURED]: [component] — [what changed and why]

## PRD version: v[X.X.X]
## Next session should: [specific next step]
```

**Validation Summary notes:**
- Include one entry per task that went through validation (Phase B of validation-orchestrator)
- For routine tasks (Route 1), "Subagents" is "inline checklist" and "Specialists" is "none"
- For tasks skipped without validation (e.g., documentation-only, config changes), omit the entry
- The Result line uses the same ✅/❌/⏭️ convention as the validation report (⏭️ = not applicable)
- "Key findings" captures reviewer observations worth noting even when the task passed — these inform future Known Bug Patterns and post-mortems

## Rules
- Logs are **append-only** — never edit old logs
- Logs are the **primary detailed record** — project.md Progress Log is a concise index only
- Logs are **NOT read at session start** — relevant decisions are propagated to loaded documents by end-of-session skills
- Logs are **read on-demand** when investigating past decisions or debugging recurring issues
