---
name: diff-pattern-extractor
invocation: inline
effort: medium
description: >
  Extracts patterns from session git diffs into Known Bug Patterns and Architecture
  Patterns. MUST run at end of every session (first end-of-session item). This is how
  the project gets smarter session over session — without it, every bug is fixed once
  and forgotten.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 5
---

# Diff-based Pattern Extractor

## When to run
At the END of every session, BEFORE updating project.md (first end-of-session action).

## Process

### 1. Review git diff
Run `git diff --stat` and `git log --oneline` for this session's commits. For each non-trivial fix or implementation change:

### 2. Ask three questions per change

| Question | Classification | Action |
|----------|---------------|--------|
| **Bug fixed — could this recur?** | FIX | Add CORRECT pattern to code-reviewer Known Bug Patterns with efficacy tracking: `[added: sN \| triggered: never \| false-positive: 0]` |
| **Mistake corrected mid-task?** | FIX | Add a check that catches the WRONG approach |
| **Structural decision worth preserving?** | CAPTURED | Add to code-reviewer Architecture Patterns |

### 3. Cap management (Known Bug Patterns)
- **Max 20 patterns** in code-reviewer
- At 15+: aggressively promote related patterns to rules files (3+ from same domain → `rules/[domain]-rules.md`)
- Rules files have no limit
- Remove patterns enforced by linting or tests
- Use efficacy data: no `triggered` history → remove first; frequent `triggered` → promote

### 4. Update efficacy tracking
Review the Code Review Report from this session. For each Known Bug Pattern listed under "Known Bug Patterns triggered":
- Append current session to the pattern's `triggered` field
- If a pattern was flagged but was a false positive: increment `false-positive`

### 5. Log evolutions
For each pattern added/modified, log: `"[FIX/DERIVED/CAPTURED]: [component] — [what changed and why]"`
