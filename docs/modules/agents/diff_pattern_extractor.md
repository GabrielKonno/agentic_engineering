---
name: diff-pattern-extractor
description: >
  MUST run at end of every session (item 1, before all other end-of-session steps) —
  invoked as subagent. Extracts bug + architecture patterns from git diff into
  code-reviewer.md. Without this, every bug is fixed once and forgotten.
tools: Read, Edit, Bash, Glob, Grep
effort: medium
invocation: subagent
receives: no extra context needed — reads git diff and .claude/agents/code-reviewer.md autonomously
produces: summary of patterns added/modified/removed, with FIX/DERIVED/CAPTURED classification for each
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 1
---

# Diff-based Pattern Extractor

## Process

### 1. Review git diff
Run `git diff --stat` and `git log --oneline` for this session's commits. For each non-trivial fix or implementation change:

### 2. Ask three questions per change

| Question | Classification | Action |
|----------|---------------|--------|
| **Bug fixed — could this recur?** | FIX | Add CORRECT pattern to code-reviewer Known Bug Patterns with efficacy tracking: `[added: sN \| triggered: never \| false-positive: 0]` |
| **Mistake corrected mid-task?** | FIX | Add a check that catches the WRONG approach |
| **Structural decision worth preserving?** | CAPTURED | Add to code-reviewer Architecture Patterns |

### 3. Cap management — EXECUTE, don't suggest

**Max 20 patterns** in code-reviewer. When count reaches **18+, you MUST act** — do not
leave "cap management notes" for the next session. Execute the changes yourself:

**Step A — Identify candidates** (in priority order):
1. **Remove by inactivity:** `triggered: never` after 15+ sessions since `added:`
2. **Remove by enforcement:** patterns now enforced by linting, TypeScript, or existing rules files
3. **Promote by domain:** 2+ related patterns from the same domain → consolidate into `rules/[domain]-rules.md`

**Step B — Execute promotion/removal:**
1. Use Glob to find the target rules file (e.g. `.claude/rules/[domain]-rules.md`)
2. Read the target rules file
3. Add a new section with the promoted content (consolidated, not copy-pasted verbatim)
4. In code-reviewer.md, replace each promoted/removed pattern with a comment:
   `<!-- Promoted sN: [pattern] → [rules file] -->` or `<!-- Removed sN: [pattern] — [reason] -->`
5. Use Grep to count remaining patterns — verify final count is **≤ 16** (leave buffer for next session)

If no matching rules file exists for the domain, note it in the output — the rules-agents-updater (session-end item 5) will create the file.

**Step C — Report in output** (see Output section below).

Rules files have no cap. Promotion preserves knowledge while freeing code-reviewer context.

### 4. Update efficacy tracking
Review the Code Review Report from this session. For each Known Bug Pattern listed under "Known Bug Patterns triggered":
- Append current session to the pattern's `triggered` field
- If a pattern was flagged but was a false positive: increment `false-positive`

### 5. Log evolutions
For each pattern added/modified, log: `"[FIX/DERIVED/CAPTURED]: [component] — [what changed and why]"`

## Output

Return to the main agent:
```
## Diff Pattern Extraction Result
- Patterns added: [N] — [list with FIX/DERIVED/CAPTURED classification]
- Patterns modified: [N] — [list]
- Patterns removed: [N] — [list with reason]
- Efficacy updates: [list sessions appended to triggered/false-positive fields, or "none"]
- Cap status: [N]/20 Known Bug Patterns
- Cap management: [actions taken] or "not needed (N/20)"
```

If cap management was executed, include details:
```
### Cap management executed:
- Promoted: [pattern] → [rules file] "[section]"
- Removed: [pattern] — [reason]
- Final count: [N]/20
```

If no patterns extracted: return "No extractable patterns in this session's diff."
