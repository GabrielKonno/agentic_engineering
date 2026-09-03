---
name: commit
invocation: user
effort: low
description: >
  Safe commit workflow with staging verification. Run before any non-trivial commit to prevent
  bundling unrelated files. Shows staged state, detects intent mismatches, groups logical commits,
  and writes conventional messages. USE when committing any change — especially after multi-file
  sessions where unrelated files may have accumulated in staging.
created: framework-v2.2.1 (pre-validated)
derived_from: 'commit_hygiene "Before every commit" — section of docs/agentic_engineering_framework.md in the FRAMEWORK repo; lineage only, NOT shipped to projects, do not attempt to resolve a project path'
---

# Commit

## When to run
Before any non-trivial commit, or whenever `git status` might have surprises.

## Process

### Step 1 — Show staging state

**ALWAYS SHOW the user exactly which files are staged and which are not, before anything else.**
Run `git status` and show the user exactly which files are staged, unstaged, and untracked.

### Step 2 — Verify intent
For each staged file, confirm it belongs to the current commit's intent.
- If ALL staged files match → proceed to Step 3
- If ANY staged file does NOT match → STOP. List the mismatched files, unstage them with
  `git restore --staged <file>`, and ask user to confirm before proceeding.

### Step 3 — Group logical commits
If staged files span multiple unrelated concerns, propose splitting into separate commits.
Ask user to confirm the grouping before committing.

### Step 4 — Draft commit message
Write a conventional commit message following the project's existing style:
- Format: `type(scope): short description`
- Types: feat, fix, chore, docs, refactor, style, test
- **ALWAYS BE SPECIFIC:** "Fix checkout total ignoring applied discounts", NEVER "Fix a bug"
- Include WHY when non-obvious

### Step 5 — Commit
Run `git commit` with the drafted message, ending with:
  Co-Authored-By: Claude <noreply@anthropic.com>

### Step 6 — Verify

**ALWAYS VERIFY the commit landed and REPORT it — `commit: [hash] [subject]` or
`NOT committed — [reason]`. NEVER emit nothing.**
Run `git log --oneline -3` and show user the result to confirm the commit landed correctly.
