---
name: session-log-creator
invocation: inline
effort: medium
description: >
  Creates a permanent session log file at end of every session. This is the primary
  detailed record — includes reasoning, alternatives, errors, and full git output.
  MUST run at end of every session, BEFORE project-md-updater (which references the
  log filename in the project.md index row). Without logs, debugging "why was this
  decided?" requires re-reading all session context.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 2
---

# Session Log Creator

## When to run
At the END of every session, BEFORE project-md-updater (the project-md-updater needs the log filename to reference in the index row).

## Process

### 1. Generate filename
**Format:** `YYYYMMDD_sN_[slug]_[commit].md`
- `YYYYMMDD` — date
- `sN` — session number
- `[slug]` — 2-4 word kebab-case summary of session
- `[commit]` — 7-char short hash of last commit

Example: `20260326_s12_financial-closing-sprint_a3f7b2c.md`

Get commit hash: `git log --oneline -1 | cut -d' ' -f1`

Or run: `bash .claude/skills/session-log-creator/scripts/create-log.sh [session_number] [slug]`
(Scripts require bash — Git Bash on Windows, native on macOS/Linux. If unavailable, the AI executes the equivalent steps manually.)

### 2. Write log file

Save to `.claude/logs/[filename]`:

```markdown
# Session [N] — [date]

## Summary
[1-2 sentences: goal and outcome. Be specific — include what was the plan, was it
achieved, and what is the project state now. This may be read by the AI in future
sessions when investigating past decisions.]

## Tasks completed
- [task]: [approach, key decisions]

## Decisions made (and why)
[Include enough context for future reference: what was decided, what alternatives were
considered, what trade-offs drove the choice, and any constraints. This section is the
primary record of decision reasoning — the Architectural Decisions table in project.md
captures the WHAT, this section captures the WHY in detail.]
- [decision]: [reasoning, alternatives, trade-offs]

## Bugs found and fixed
- [bug]: [root cause, fix, pattern added?]

## Discoveries
- [unexpected findings: missing API, schema issue, security finding]

## Files changed
[git diff --stat]

## Commits
[git log --oneline for this session]

## Evolutions applied
- [FIX/DERIVED/CAPTURED]: [component] — [what changed and why]

## PRD version: v[X.X.X]
## Next session should: [specific next step]
```

### 3. Rules
- Logs are **append-only** — never edit old logs
- Logs are the **primary detailed record** — project.md Progress Log is a concise index only
- Logs are **NOT read at session start** — the relevant decisions are already propagated to
  the documents loaded at session start (Architectural Decisions table, CLAUDE.md Key Patterns,
  rules files) by the end-of-session skills
- Logs are **read on-demand** when:
  - The AI needs to investigate a past decision or debug a recurring issue
  - The human explicitly asks ("what happened in session 12?" → read the log)
  - The prd-sync-checker or other skill needs historical context
- All reasoning, alternatives, error messages, and implementation context lives HERE,
  not in project.md
