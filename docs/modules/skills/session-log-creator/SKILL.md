---
name: session-log-creator
invocation: inline
effort: medium
description: >
  Creates a permanent session log file at end of every session. More verbose than
  project.md entry — includes reasoning, alternatives, errors, and full git output.
  MUST run alongside project-md-updater at end of every session. Without logs,
  debugging "why was this decided?" requires re-reading all session entries.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 1 (log subsection)
---

# Session Log Creator

## When to run
At the END of every session, alongside or immediately after project-md-updater.

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

### 2. Write log file

Save to `.claude/logs/[filename]`:

```markdown
# Session [N] — [date]

## Summary
[1-2 sentences: goal and outcome]

## Tasks completed
- [task]: [approach, key decisions]

## Decisions made (and why)
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
- Logs are NOT read by AI in normal sessions (human reference only)
- Logs are a permanent record even when project.md entries are archived
- More verbose than project.md entries — include reasoning, alternatives, error messages
