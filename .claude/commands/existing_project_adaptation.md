# Existing Project Adaptation Session

This is an **existing project adaptation session** for project **$ARGUMENTS**.

**Project path:** `projects/$ARGUMENTS/`
**Framework root:** `.` (current directory — the agentic_engineering repository root)

## Authorized Operations

- Read and modify documentation files inside `projects/$ARGUMENTS/`
- Create missing documentation files inside `projects/$ARGUMENTS/`
- Copy examples and skills from the framework into the project
- Install MCPs and plugins for the project
- No application code will be written or modified — only documentation and configuration

## Rules

- All documents are written in English for consistency
- Conversational output (reports, questions, summaries) should be in Brazilian Portuguese
- Never modify files in `docs/` or `examples/` (framework read-only references)
- For every document that already exists: **DO NOT overwrite** — read it, identify what's missing, and add only the missing sections. Preserve all existing content, history, and patterns.

## Setup

Before starting the process:

**ALWAYS REFUSE, BY READING THE NAME BEFORE RUNNING ANY FENCE, a project name that is empty, starts
with `.`, or contains any character outside `[A-Za-z0-9._-]`** — tell the owner and stop. Every
fence in this command expands `projects/$ARGUMENTS` (most of them unquoted), so a space splits the path into stray
directories and a glob character matches other folders (`/audit` 2026-09-14 Y-8).
**NO FENCE CAN ENFORCE THIS.** `$ARGUMENTS` is substituted as TEXT before bash parses a fence, so a
`$(…)`, a backtick or a quote in the name EXECUTES, or breaks out of its quoting, in the first fence that contains it — a check inside that
fence runs too late. The BACKSTOP that opens EVERY writing fence of Steps 2.9–2.9b (forward reference, flagged) (the `case "$ARGUMENTS"`
line plus the existence check) covers the path classes only (`/audit` 2026-09-15 B-3). The same prose guard opens `bootstrap.md`.

1. Verify `projects/$ARGUMENTS/` exists. If not, stop and tell the user: "Project '$ARGUMENTS' not found in projects/. Use `/bootstrap $ARGUMENTS` for a new project or place the existing project in `projects/$ARGUMENTS/`."

Execute in order. Report results after each part.

---

## Process

This session reads the existing codebase and documentation, then upgrades everything to the current Agentic Engineering Framework version. NO application code will be written or modified. Only documentation and configuration.

---

### Step 0.5 — FRAMEWORK-clone freshness check (MANDATORY, before Phase 1 and before copying anything out of this repo)

```bash
git remote -v                                        # (a) EVERY remote — NEVER `head -1`: a fork's `upstream` is usually the second
git rev-parse --abbrev-ref @{upstream} 2>/dev/null   # (b) does THIS branch track one?
git fetch --prune && git status -sb | head -1        # (c) ahead/behind — `--prune`: a remote that dropped the branch reads `[gone]`, never a stale `...` (`/audit` 2026-09-19 C-7)
```

**Classify into exactly one of the SEVEN outcomes below — the table is exhaustive and its last row is the CATCH-ALL — the check FAILS CLOSED, never open:**

| Observation | Verdict |
|-------------|---------|
| (a) empty — no remote configured at all | `no remote — skipped`. Nothing to be behind; CONTINUE. |
| (a) lists an `upstream` remote (this clone is a FORK) | Compare against **`upstream`**, never `origin`: `git fetch --prune upstream && git rev-list --count HEAD..upstream/main` (`--prune`, or a deleted upstream `main` leaves a stale ref and the count reads `0` — `/audit` 2026-09-19 D-2) → **0 = `up to date`; anything else = RED, `behind upstream by N — STOPPED`**. On a fork `@{upstream}` points at the FORK's own `origin`, so the rows below would read GREEN while the clone is arbitrarily behind the real upstream. |
| (b) empty or errors — branch tracks nothing (or detached HEAD) | **RED — STOP.** `no upstream tracking — UNVERIFIABLE, STOPPED`. |
| (c) produced NO line — `git fetch` failed, so `&&` short-circuited | **RED — STOP.** `fetch failed — UNVERIFIABLE, STOPPED`. Re-run the two commands separately to see the error. |
| (c) branch line contains `behind` | **RED — STOP.** `behind by N commits — STOPPED`. |
| (c) branch line shows a `...` tracking segment and neither `behind` nor `[gone]` | `up to date`. CONTINUE. A `[gone]` segment — the remote dropped the branch, which `--prune` makes visible — falls to the CATCH-ALL (`/audit` 2026-09-19 C-7). |
| **anything else — any observation matching no row above** | **RED — STOP.** `unverifiable — STOPPED`. This CATCH-ALL is what makes the check fail CLOSED; without it an unmatched state is undefined rather than red (`/audit` 2026-09-02 K-1). |

**NEVER read a bare `## main` (no `...upstream` segment) as "up to date".** With a remote present
but no tracking branch, `git status -sb` prints the branch name alone — the command exits 0 having
compared against NOTHING. That is the third state `session_rules.md → Execution proof` requires to
fail CLOSED: *"the tool exited 0 and its summary is UNREADABLE → RED. 'I could not READ it' is
NEVER 'it is healthy'."* Verify the tracking segment is PRESENT before trusting the absence of
`behind`.

On any RED, **STOP and tell the owner** — this command keys migration decisions to the framework
version label, so a stale clone tells an upgraded project it is current while handing it an older
contract. Update or attach the upstream first (`git pull`,
`git fetch upstream && git merge upstream/main` on a fork, or
`git branch --set-upstream-to=origin/main`), then restart.

**ALWAYS REPORT one of the SEVEN verdict strings above — `up to date` / `behind by N commits —
STOPPED` / `no upstream tracking — UNVERIFIABLE, STOPPED` / `no remote — skipped` / `fetch failed — UNVERIFIABLE,
STOPPED` / `behind upstream by N — STOPPED` / `unverifiable — STOPPED`. NEVER emit nothing.** Phase 1's Step 1.0 below checks the PROJECT copy; this checks the FRAMEWORK copy.
Both, or neither is worth much.

---

### Phase 1 — Read Everything (DO NOT write anything yet)

Read the entire existing structure before making any changes. This is the most important phase — your understanding of the project determines the quality of every document you create or update.

**Step 1.0 — Freshness check of the PROJECT copy (MANDATORY before reading anything):**

If the project has a git remote, ALWAYS verify the local copy is current BEFORE analyzing it:

```bash
git -C projects/$ARGUMENTS remote -v                    # (a) has a remote?
git -C projects/$ARGUMENTS fetch --prune origin &&   git -C projects/$ARGUMENTS status -sb                # (b) ahead/behind — CHAINED, so a failed fetch prints nothing
```

**Classify with Step 0.5's table, which this check is the twin of — it FAILS CLOSED, never open
(`/audit` 2026-09-19 D-1):**

| Observation | Verdict |
|-------------|---------|
| (a) empty — no remote configured | `no remote — skipped`. Nothing to be behind; CONTINUE. |
| (b) produced NO line — the fetch failed, so `&&` short-circuited | **RED — STOP.** `project copy: fetch failed — UNVERIFIABLE, STOPPED`. |
| (b) branch line contains `behind` | **RED — STOP.** `project copy: behind by N commits — STOPPED`. |
| (b) branch line shows a `...` tracking segment and neither `behind` nor `[gone]` | `project copy: up to date`. CONTINUE. |
| **anything else — a bare `## main` with no tracking segment, `[gone]`, any unmatched state** | **RED — STOP.** `project copy: unverifiable — STOPPED`. The CATCH-ALL is what makes this fail closed; without it a failed fetch, a dropped branch and a copy with no tracking branch all read as "not behind". |

If the copy is BEHIND the remote: STOP and reconcile first (pull/reset per the owner's
instruction) — every conclusion drawn from a stale copy is invalid, and edits made on it
will conflict with the real history. Analyzing a snapshot that is N commits behind is the
adaptation-level equivalent of reviewing the wrong diff.
(Origin incident 2026-07-14: a compatibility validation ran against a project copy
334 commits behind its origin — the report was faithful to a month-old snapshot, and the
install had to be redone on the real base.)

**Step 1.1 — Read existing documentation:**

```bash
# Find all markdown docs
find projects/$ARGUMENTS -name "*.md" -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' | sort

# Read the main config file
cat projects/$ARGUMENTS/CLAUDE.md 2>/dev/null || echo "NO CONFIG FILE FOUND"

# Read project history
cat projects/$ARGUMENTS/.claude/phases/project.md 2>/dev/null

# Read backlog (may have non-standard names)
find projects/$ARGUMENTS/.claude/phases/ -name "*.md" -not -name "project.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all agents
find projects/$ARGUMENTS/.claude/agents/ -name "*.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all rules
find projects/$ARGUMENTS/.claude/rules/ -name "*.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done

# Read all skills
find projects/$ARGUMENTS/.claude/skills/ -name "*.md" -o -name "SKILL.md" 2>/dev/null | while read f; do echo "=== $f ==="; cat "$f"; done
```

**Step 1.2 — Read codebase structure:**

```bash
# Project structure
find projects/$ARGUMENTS -maxdepth 3 -type d -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' | head -60

# Config files (identify stack)
ls -la projects/$ARGUMENTS/package.json projects/$ARGUMENTS/tsconfig.json projects/$ARGUMENTS/next.config.* projects/$ARGUMENTS/nuxt.config.* projects/$ARGUMENTS/vite.config.* projects/$ARGUMENTS/manage.py projects/$ARGUMENTS/pyproject.toml projects/$ARGUMENTS/go.mod projects/$ARGUMENTS/Cargo.toml projects/$ARGUMENTS/Gemfile projects/$ARGUMENTS/docker-compose.yml projects/$ARGUMENTS/.env.example projects/$ARGUMENTS/.env.local 2>/dev/null

# Source file count by type
for ext in ts tsx js jsx py go rb java vue svelte; do
  count=$(find projects/$ARGUMENTS -name "*.$ext" -not -path '*/node_modules/*' -not -path '*/.next/*' 2>/dev/null | wc -l)
  [ "$count" -gt 0 ] && echo "$ext: $count files"
done

# Key architectural files (routes, models, schemas, migrations)
find projects/$ARGUMENTS -type f \( -name "schema.*" -o -name "route.*" -o -name "routes.*" -o -name "model.*" -o -name "models.*" -o -name "migration*" -o -name "middleware.*" \) -not -path '*/node_modules/*' 2>/dev/null | head -30

# Database schema if available
find projects/$ARGUMENTS -name "schema.prisma" -o -name "schema.sql" -o -name "models.py" -o -name "*.entity.ts" 2>/dev/null | head -10
```

**Step 1.3 — Read git history:**

```bash
# Recent history (last 20 commits)
cd projects/$ARGUMENTS && git log --oneline -20 2>/dev/null; cd -

# Contributors
cd projects/$ARGUMENTS && git shortlog -sn 2>/dev/null | head -5; cd -

# When was first and last commit?
cd projects/$ARGUMENTS && echo "First: $(git log --reverse --format='%ai' | head -1)" && echo "Last: $(git log --format='%ai' -1)" 2>/dev/null; cd -

# Bug fix patterns (for seeding Known Bug Patterns)
cd projects/$ARGUMENTS && git log --oneline --all 2>/dev/null | grep -iE "fix|bug|hotfix|patch|revert" | head -15; cd -
```

**Step 1.4 — Read existing PRD (if it exists):**

```bash
find projects/$ARGUMENTS -name "prd.md" -o -name "PRD.md" -o -name "prd_*.md" -o -name "requirements.md" 2>/dev/null
```

If found: read it. If not found: this is expected — we will create a retroactive PRD in Phase 3.

**Step 1.5 — Produce a reading report:**

Before proceeding, present a summary of everything you read:

```
## Reading Report

### Stack identified:
- Framework: [...]
- Database: [...]
- Auth: [...]
- Deploy: [...]

### Project maturity:
- First commit: [date]
- Total commits: [N]
- Source files: [N]
- Modules identified: [list]

### Existing framework docs:
- CLAUDE.md: [exists/missing] — [summary of content]
- Project-copy freshness (Step 1.0): `project copy: up to date` / `project copy: behind by N commits — STOPPED`
  (reconciled before analysis) / `no remote — skipped` / `project copy: fetch failed — UNVERIFIABLE, STOPPED` /
  `project copy: unverifiable — STOPPED` — ALL FIVE verdicts of Step 1.0's table, COPIED from it (Gate 4).
  ALWAYS report; the verdict had no slot anywhere (`/audit` M-53), and the two fail-closed verdicts had none
  until the table itself existed (`/audit` 2026-09-19 D-1)
- project.md: [exists/missing] — [N rows in Progress Log index, last session date]
- pendencias/backlog: [filename] — [N items in progress, N items done]
- Agents: [list with names]
- Rules: [list with names]
- Skills: [list with names]
- Process skills: [N of 12 installed] — [list missing: sprint-proposer, autonomous-loop, session-end, context-recovery, validation-orchestrator, project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator, cross-cutting-analysis, commit]
- Process agents: [N of 3 installed] — [list missing: prd-sync-checker, criteria-enforcer, diff-pattern-extractor]
- Session rules: [exists/missing] — .claude/rules/session-rules.md
- Evolution policy: [exists/missing] — .claude/rules/evolution-policy.md
- Component design: [exists/missing] — .claude/rules/component-design.md
- PRD: [exists/missing]

### What needs to be created:
- [ ] [list of missing documents]

### What needs to be upgraded:
- [ ] [list of existing docs that need updates]

### Observations:
- [anything unusual, non-standard naming, etc.]
```

**Wait for user confirmation before proceeding to Phase 2.**

---

### Phase 2 — Upgrade Existing Documents

For every document that already exists: **DO NOT overwrite.** Read it, identify what's missing compared to the current framework, and add only the missing sections. Preserve all existing content, history, and patterns.

**(This mandate belongs INSIDE Step 2.1 and is stated here only because the step's body is below; the twin keeps it inside its step — `/audit` 2026-09-04 R-12.)**
**When Step 2.1 writes the `**PRD:**` line from
`docs/modules/templates/claude_md.md`, ALWAYS DELETE the template's
`[or, when bootstrapped WITHOUT …]` bracket annotation** — it is authoring guidance, not project
content, and bootstrap's twin has carried this mandate all along while this command had none, so
an adapted project could ship the annotation verbatim (`/audit` 2026-09-03 P-21).
**ALWAYS REPORT — `PRD line: written, bracket removed` or `PRD line: already present, untouched`.**

**Step 2.1 — Upgrade CLAUDE.md:**

Compare the existing config file against this checklist. Add any missing section:

```
Required sections (compare against docs/modules/templates/claude_md.md — v2.29.0 slim orchestrator):
□ Project Overview (name, state, PRD reference, pending tasks reference, session logs)
□ Session Protocol (pointers to /sprint-proposer, /autonomous-loop, /session-end,
  /context-recovery, validation-orchestrator, session-rules.md — FIVE pointers plus the rules
  file; this line named three for two batches, `/audit` 2026-09-09 T-32)
□ Commands section
□ MCP Servers section
□ Skills & Agents section (auto-discovery note, no explicit listing)
□ Hooks section
□ Architecture section
□ Key Patterns section
□ Build Order section
□ Design System section
□ File Map section
□ Environment Variables section
□ Commit Hygiene section

**COUNT THE BOXES AGAINST THE TEMPLATE, NEVER AGAINST THIS LIST.** Mechanical self-check
(expected result stated): `grep -c '^## ' docs/modules/templates/claude_md.md` — **expected:
equal to the number of □ above.** The list stood at 12 while the template shipped 13, and the
missing one — `## Commit Hygiene` — appeared nowhere else in the repo, so no adapted project ever
gained it and no audit dimension looked for it (`/audit` 2026-09-09 T-32).
```

**Migration from v1.6.0 to v2.1.0:** If the CLAUDE.md contains inline Session Protocol (10 start steps, end steps, model switch protocol, validation failure post-mortem, sprint-approved mode, etc.), these should be REMOVED. All protocol logic now lives in process skills (sprint-proposer, session-end, context-recovery, validation-orchestrator) and session rules (.claude/rules/session-rules.md). Replace inline protocol sections with the slim Session Protocol pointers from the v2.1.0 template.

**Key additions likely missing from older versions:**

*v2.1.0 structural change:*
- CLAUDE.md is now a slim orchestrator (~90 lines). All protocol logic lives in skills and rules.
- Session Protocol section is 5 lines of pointers, not inline protocol steps.
- Skills & Agents section uses auto-discovery (no explicit listing).
- Session rules live in `.claude/rules/session-rules.md` (task limits, doc quality, reasoning depth, scripts convention).
- Evolution policy lives in `.claude/rules/evolution-policy.md` (FIX/DERIVED/CAPTURED classification, auto-evolution boundaries).
- If the existing CLAUDE.md has inline protocol sections, they should be replaced with pointers.

*Agent/skill infrastructure (verified in Steps 2.4-2.8):*
- **validator agent** (`.claude/agents/validator.md`) — mandatory, independent verification
- **arbitrator agent** (`.claude/agents/arbitrator.md`) — mandatory, conflict resolution
- **`invocation:` frontmatter** on all review/validation agents/skills (`subagent` or `inline`)
- **`model:` frontmatter** on every AGENT — mandatory and explicit, `inherit` included; FORBIDDEN on skills (`session-rules` → "Model by risk class"; the guard enforces both directions)
- **`receives:` / `produces:` frontmatter** on `invocation: subagent` agents/skills (I/O contract)
- **Lineage frontmatter** on all agents/skills (`created:`, `last_eval:`, `fixes:`, `derived_from:`)
- **Efficacy tracking** on Known Bug Patterns (`[added: sN | triggered: sN | false-positive: N]`)
- **"Known Bug Patterns triggered"** field in Code Review Report output format
- **"Evolutions applied"** section in session log template

*Process components (copied in Step 2.9):*
- 12 lifecycle process skills (`.claude/skills/`) + 3 process agents (`.claude/agents/`) + 3 core rules files (`.claude/rules/`), plus tier-gated audit skills + ops/budgets rules by risk profile (Step 2.9b)
- Without these, the skill pointers in CLAUDE.md are broken references

**For each addition, log:**
```
Added to CLAUDE.md: [section name] — [reason: missing from current version]
```

**Step 2.2 — Upgrade project.md:**

**This step OWNS the artifact that Step 4.1b's ARCHITECTURE concerns land in — it does NOT write
them.** Step 4.1b runs in Phase 4, after the PRD exists; this step runs in Phase 2, before it, so
it cannot receive anything and MUST NOT be told to. **Step 4.1b performs that write itself, by
reopening this artifact**, and reports the count. Do not add an architecture row here on the PRD's
behalf: two steps mandated to perform one write is how the count gets doubled or dropped
(`/audit` 2026-09-02 M-2, corrected 2026-09-03 N-21 — the receiver declarations contradicted Step
4.1b's own explicit statement that it performs the write).

**If it does NOT exist: CREATE it.** Read the template at `docs/modules/templates/project_md.md` and create `.claude/phases/project.md` exactly as
`/bootstrap` would, then run the upgrade checks BELOW against the file you just created. **NEVER assume the file exists** —
**several later steps read or write it**, and this command's own Reading Report has an
`[exists/missing]` slot for it. **DERIVE that set with the command below; NEVER type it here** —
the typed form stood two steps above an identical DERIVE mandate that Step 2.3 honours, and the
same list has been wrong four times by four mechanisms (`/audit` 2026-09-10 U-27; `/audit`
2026-09-02 K-11; consumers corrected twice — `N-24` removed a
justification naming two steps that read nothing here, and `P-36`'s sibling `P-19` then found the
REPLACEMENT list equally wrong, naming two more steps that touch neither file while omitting
`Step 2.9b`, which reads the risk profile from this file and writes back to it. **DERIVE the list
by parsing each Step's body for the filename; NEVER write it from reading** —
`/audit` 2026-09-03 P-19: 5.1 reads
`.claude/agents/`, `.claude/rules/` and `CLAUDE.md`, and 4.6.5 reads only `pendencias.md`).

Check for required sections:
```
□ Overview (stack, repo, deploy, database)
□ Architectural Decisions table
□ Module Relationships (ASCII diagram + cross-module flows)
□ Project Phases with completion criteria
□ Progress Log index table (session, date, summary, log reference)
□ `**PRD version:**` field (prd-sync-checker Check A compares against it — set after Phase 3)
```

**Do NOT modify existing Progress Log entries.** Add missing sections at the appropriate location.

If the Progress Log uses the old format (full session entry blocks), convert it to an index table during this adaptation. Extract session number, date, and 1-line summary from each block. Use `—` for the Log column (no log files exist for old sessions). Preserve old entries below the table as a legacy block.

**THE TWO RECORDS BELOW ARE SPECIFIED HERE AND WRITTEN IN STEP 4.2 — NEVER write them in this step.**
This step runs in Phase 2: the retroactive PRD the row announces does not exist until Phase 3, and
`.claude/logs/` is created by Step 4.2 (`/audit` 2026-09-14 W-17).

Add an adaptation row to the Progress Log index table:

```markdown
| Adaptation | [date] | Framework upgrade to v[current], retroactive PRD created | — |
```

Also create a session log in `.claude/logs/` with the detailed adaptation record:
```markdown
# Adaptation Session — [date]

## Summary
Upgraded project documentation to Agentic Engineering Framework v[current].

## What was done
- Added missing sections: [list]
- Created retroactive PRD from existing codebase analysis
- Verified: agents, rules, skills, phases structure

## Preserved
- [N] rows in Progress Log index
- [N] agents: [names]
- [N] rules: [names]
- [N] skills: [names]

## PRD version: v1.0.0 (retroactive — created from codebase analysis)
## Next session should: [first item from pendencias.md]
```

**Step 2.3 — Upgrade pendencias.md (or equivalent):**

**This step OWNS the artifact that Step 4.1b's WORK concerns land in — it does NOT write them.**
Step 4.1b runs in Phase 4, after the PRD exists; this step runs in Phase 2, before it, so it cannot
receive anything and MUST NOT be told to. **Step 4.1b performs that write itself, by reopening this
artifact**, and reports the count (`/audit` 2026-09-02 M-2, corrected 2026-09-03 N-21).

**If it does NOT exist: CREATE it.** Read the template at `docs/modules/templates/pendencias_md.md` and create `.claude/phases/pendencias.md` exactly as
`/bootstrap` would, then run the upgrade checks BELOW against the file you just created. **NEVER assume the file exists** —
**several later steps read or write it, and this command's own Reading Report has an
`[exists/missing]` slot for it** (`/audit` 2026-09-02 K-11; consumers corrected 2026-09-03 N-24 —
Step 5.1 does not read this file. The T-38 fix deleted this clause's PREDICATE and, with the old
list, the subject that bridged into the sentence below, leaving one clause ending in an em-dash
and the next opening mid-sentence — `/audit` 2026-09-10 U-17).

**DERIVE the consumer list; it is not written here.** Four successive attempts to enumerate it were wrong by four different mechanisms — reading, a fixed-line `sed`, a heading split that mis-attributed a PHASE-3 block, and one that named a step which never touches the file while omitting Phase 3, which names it three times (`/audit` 2026-09-04 Q-5, R-11). **The command:** split on the bold `**Step N**` headings AND the `### Phase N` headings, then report every section whose body contains the filename. **A list typed here will be wrong again.** Step 1.1 also reaches this file, but through a glob that never names it, so it is deliberately excluded from a list of NAMED consumers. (The fix for R-11 prepended this paragraph without deleting the one it replaced, leaving two contradictory rationales, two contradictory commands and a `.,` splice on one line — `/audit` 2026-09-09 T-38.)

**`done_tasks.md` — CREATE IT HERE TOO IF MISSING.** `pendencias-updater` moves completed tasks
into `.claude/phases/done_tasks.md`; bootstrap creates it unconditionally and calls it
load-bearing ("without it, the task lifecycle breaks silently"), while this command only CHECKED
for it in a Step 2.3 checklist item, leaving an adapted project with a skill pointing at nothing.
**ALWAYS create it when absent, with the same header bootstrap Step 4 writes, and ALWAYS REPORT
`done_tasks.md: [created | already present]`. NEVER emit nothing** (`/audit` 2026-09-03 N-48).

The file may have a non-standard name (e.g., `[nome-fora-do-padrao].md`). **Do NOT rename it** — update the reference in CLAUDE.md to point to the actual filename.

Check and upgrade:
```
□ Every task has Context, State, Constraints fields
□ Every task has Complexity classification (routine / logic-heavy / architecture-security)
□ Every task has acceptance criteria with BUILD:/VERIFY:/QUERY:/REVIEW:/MANUAL: tags
□ Criteria are at STRONG level (action + expected result + failure signal)
□ done_tasks.md exists (or legacy Done section — will be migrated by pendencias-updater)
□ Future Improvements section exists
□ The task-format legend carries the `origin:` field (`owner` / `discovered`)
□ Dependency mapping (depends:/parallel:) is optional but noted
□ Evolution classification (FIX/DERIVED/CAPTURED) noted for items that originated from bug fixes or pattern captures during codebase analysis
```

**ALWAYS ADD the `origin:` legend when it is missing** — copy its three lines from
`docs/modules/templates/pendencias_md.md`. `autonomous-loop` continuous mode reads a task with no
`origin:` line as `owner`, so a project without the legend admits every AI-filed task uncapped
(`/audit` 2026-09-14 X-4).

**For existing tasks without these fields:** Add them based on the task description and your understanding of the codebase. Mark additions with `← added during adaptation` so the user can review.

**Before Steps 2.4-2.8:** If `assets/examples/README.md` exists, read it for conventions (frontmatter fields, structure, output format, invocation types). Use these conventions when creating or upgrading any agent or skill.

**Step 2.4 — Upgrade code-reviewer agent/skill:**

**If it does NOT exist: CREATE it.** Read the template at `docs/modules/agents/code_reviewer.md` and create `.claude/agents/code-reviewer.md` exactly as
`/bootstrap` Step 7 would, then run the upgrade checks BELOW against the file you just created. **NEVER assume the file exists** — this command's own Reading Report carries an
`[exists/missing]` slot for it, and later steps read it without re-checking
(`/audit` 2026-09-02 K-11, M-10).

Check for:
```
□ Frontmatter with effort: medium
□ Frontmatter with invocation: subagent
□ Frontmatter with receives: and produces: fields (I/O contract)
□ Frontmatter with lineage fields: created:, last_eval:, fixes:, derived_from:
□ Input section (what the subagent reads when invoked)
□ Output section with "Known Bug Patterns triggered" field in report format
□ BOUNDARIES section (what NOT to read — anti-bias firewall)
□ Project Patterns section
□ Type Safety section
□ API / Data Mutation Patterns section
□ Performance section
□ Security section (references security-reviewer)
□ Architecture Patterns section (populated, not empty)
□ Known Bug Patterns section (populated from git history, with efficacy tracking metadata)
```

**Seed Known Bug Patterns from git history:**
If the Known Bug Patterns section is empty or sparse, analyze the git log fix commits (from Step 1.3) and the codebase to propose initial patterns:
```bash
# Read recent fix commits for pattern extraction
cd projects/$ARGUMENTS && git log --oneline --all | grep -iE "fix|bug|hotfix|patch" | head -10; cd -
```
For each fix: ask "could this recur?" If yes, add the CORRECT pattern (not the mistake) with efficacy tracking metadata: `[added: adaptation | triggered: never | false-positive: 0]`.

**Pre-select Coverage Gap Declarations:** Review the five optional gap sections (accessibility, performance, concurrency, visual regression, data integrity). Remove sections clearly irrelevant to this project's domain based on the codebase analysis from Step 1. Keep sections that match actual code patterns found (e.g., keep concurrency gap if project has database transactions with concurrent access; keep visual regression gap if the codebase has shared UI components or design tokens). When in doubt, keep — gaps are conditional and only activate when matching diffs appear.

**Step 2.5 — Upgrade security-reviewer:**

**If it does NOT exist: CREATE it.** Read the template at `docs/modules/agents/security_reviewer.md` and create `.claude/agents/security-reviewer.md` exactly as
`/bootstrap` Step 8 would, then run the upgrade checks BELOW against the file you just created. **NEVER assume the file exists** — this command's own Reading Report carries an
`[exists/missing]` slot for it, and later steps read it without re-checking
(`/audit` 2026-09-02 K-11, M-10).

Check frontmatter:
```
□ Frontmatter with effort: high
□ Frontmatter with invocation: subagent
□ Frontmatter with receives: and produces: fields (I/O contract)
□ Frontmatter with lineage fields: created:, last_eval:, fixes:, derived_from:
□ Input section (what the subagent reads when invoked)
□ Output section (report format the subagent produces)
□ BOUNDARIES section (what NOT to read — anti-bias firewall)
```

Compare against the full checklist (9 sections):
```
□ 1. Injection Prevention (SQL, XSS, Prompt, Command, LDAP/XML/NoSQL)
□ 2. Authentication and Authorization
□ 3. Data Protection (sensitive data, in transit, at rest)
□ 4. Input Validation
□ 5. API Security
□ 6. Dependency Security
□ 7. Security Headers
□ 8. Stack-Specific Security (delegation note to stack skill / Red Team)
□ 9. Red Team Thinking (5 questions)
```

Add missing sections. **Do NOT remove existing customizations** — they may contain project-specific security rules.

**Pre-select Coverage Gap Declarations:** Review the five optional gap sections (static analysis, secrets coverage, federation protocol, compliance, infrastructure security). Remove sections clearly irrelevant based on the codebase analysis from Step 1 (e.g., remove federation protocol gap if no OAuth/OIDC/SAML found in codebase). Keep sections that match actual tech stack. If the project handles personal data (PII, CPF, health, payment), ensure the Compliance Probe section is active and `.claude/rules/compliance-rules.md` is flagged for creation if absent.

**Step 2.6 — Verify Red Team / Blue Team:**

If they exist: verify they have `effort: high`, `invocation: subagent`, `receives:`, `produces:`, and lineage fields (`created:`, `last_eval:`, `fixes:`, `derived_from:`) in frontmatter, tiered test structure (Tier 1/2/3), and the Tier 3 MANDATORY STOP protocol. Add if missing.

If they don't exist: **ALWAYS decide NOW, from the codebase** — auth, payments, multi-tenancy, AI/LLM or PII present in the code → create them. Read templates at `docs/modules/agents/red_team.md` and `docs/modules/agents/blue_team.md`. Adapt with stack-specific attack vectors.
**ALWAYS re-run this decision in Step 2.9b's PHASE-3 RE-CHECK, against the retroactive PRD and the resolved profile** (forward reference, flagged) — `production-financial` ALWAYS warrants them. The earlier text deferred the decision to "the PRD (once created in Phase 3)" and no later step returned to it, so an adapted `production-financial` project could mandate a red-team that was never installed (`/audit` 2026-09-16 A-8).
**ALWAYS REPORT — `red/blue team: present — verified` or `red/blue team: created at Step 2.6 — [indicators]` or `red/blue team: created at the Phase-3 re-check — [indicators]` or `red/blue team: not warranted — no indicator in code or PRD`. NEVER emit nothing.**

**Step 2.6.1 — Verify validator agent/skill:**

If it exists: verify it has `invocation: subagent`, `effort: high`, `receives:`, `produces:`, Input, Output, Verification Process, and BOUNDARIES sections. Add if missing.

If it doesn't exist: create it. The validator is mandatory for ALL projects. Read the template at `docs/modules/agents/validator.md`. Adapt with project-specific context. Create at `.claude/agents/validator.md`.

**Creation eval (DEFERRABLE if context is low):** See agent template for 2 test scenarios. Update lineage after eval.

**Step 2.6.2 — Verify arbitrator agent/skill:**

If it exists: verify it has `invocation: subagent`, `effort: high`, `receives:`, `produces:`, three terminal rulings (UPHOLD/OVERRIDE/ESCALATE), and BOUNDARIES sections.

If it doesn't exist: create it. The arbitrator is mandatory for ALL projects. Read the template at `docs/modules/agents/arbitrator.md`. Adapt with project-specific context. Create at `.claude/agents/arbitrator.md`.

**Creation eval (DEFERRABLE if context is low):** See agent template for 2 test scenarios. Update lineage after eval.

**Step 2.7 — Verify rules files:**

Read each rules file. No structural changes needed — rules files are project-specific. Just verify they are referenced from the code-reviewer's Security section or relevant agent.

**Step 2.7.1 — Pre-create missing domain rules from codebase analysis:**

**PRECONDITION — `assets/examples/rules/` may not exist yet.** Phase 4 Step 4.1 is what copies it into the project; on a never-bootstrapped project this step runs BEFORE that. **ALWAYS CHECK first** (`ls projects/$ARGUMENTS/assets/examples/rules/ 2>/dev/null`): if it is missing, do NOT silently no-op — record the domain matches you found and **DEFER the copying to Step 4.6**, which runs after Step 4.1 has copied the examples and is this command's PRD-derived rules step (`/audit` 2026-09-02 M-9 — the deferral had named Step 4.1b, which handles cross-cutting concerns and never receives domain rules). **ALWAYS REPORT — `domain rules: N created` or `N matches deferred to Step 4.6 — examples not yet present`. NEVER emit nothing.**

Based on the codebase analysis from Step 1 and the existing PRD when there is one (the retroactive PRD does not exist until Phase 3; Step 4.6 is its receiver — forward reference, flagged — `/audit` 2026-09-16 A-33), identify domain signals that match example templates. For each domain that is a core feature or architectural pattern in the project, check if the corresponding rules file ALREADY EXISTS in `.claude/rules/`. If it does NOT exist and a matching example template is available in `assets/examples/rules/`, pre-create it:

| Domain signal | Rules file | Example template |
|---|---|---|
| Multilingual / i18n | i18n-rules.md | assets/examples/rules/i18n-rules.md |
| Microservices / event-driven | distributed-systems-rules.md | assets/examples/rules/distributed-systems-rules.md |
| Scheduling / cron / calendar | scheduling-rules.md | assets/examples/rules/scheduling-rules.md |
| High-availability / retry | resilience-rules.md | assets/examples/rules/resilience-rules.md |
| Rate limiting / throttling | rate-limiting-rules.md | assets/examples/rules/rate-limiting-rules.md |
| E-commerce / cart / payment | e-commerce-rules.md | assets/examples/rules/e-commerce-rules.md |
| Full-stack / FE+BE | frontend-backend-integration-rules.md | assets/examples/rules/frontend-backend-integration-rules.md |
| Auth / login / permissions | auth-rules.md | assets/examples/rules/auth-rules.md |
| PII / LGPD / GDPR | compliance-rules.md | assets/examples/rules/compliance-rules.md |
| Multi-tenancy / org isolation | multi-tenancy-rules.md | assets/examples/rules/multi-tenancy-rules.md |
| Observability / logging | observability-rules.md | assets/examples/rules/observability-rules.md |

For each match: copy from `assets/examples/rules/` to `.claude/rules/`, adapting:
- `applies_to:` frontmatter: reference actual module names found in the codebase
- Remove clearly irrelevant sections
- Add HTML comment: `<!-- Seeded from example template during adaptation. Refined by rules-agents-updater as patterns emerge. -->`

**Step 2.8 — Verify and upgrade skills:**

**NEVER edit in this step a component Steps 2.9 / 2.9b compare against the framework** — any skill
whose folder name exists in `docs/modules/skills/`, and the agents `prd-sync-checker`,
`criteria-enforcer`, `diff-pattern-extractor` and `skill-reviewer`. Those steps compare them byte
for byte, and a field added here turns every pristine copy into `DIFFERS` (`/audit` 2026-09-14
X-2). Other agents built from templates (code-reviewer, validator, …) are upgraded by their own
steps and are NOT covered by this rule. A refresh brings their current frontmatter.

Read each OTHER skill. Verify frontmatter has `effort:` field. Add if missing (most skills are `effort: medium`; security-related are `effort: high`). For review/validation/security skills, verify `invocation: subagent` and `receives:`/`produces:` fields. For knowledge/reference skills, verify `invocation: inline`.

**Verify lineage fields** on every OTHER agent/skill: `created:`, `last_eval:` (subagent only), `fixes:`, `derived_from:`. Add if missing — set `created:` to the adaptation session, `last_eval: none (pre-framework)`, `fixes: []`, `derived_from: null`.

**Flat→folder migration (Claude Code skills):** If any skills exist as flat files (`.claude/skills/[name].md`), migrate to the Anthropic folder format:
```bash
for skill in projects/$ARGUMENTS/.claude/skills/*.md; do
  if [ -f "$skill" ]; then
    name=$(basename "$skill" .md)
    mkdir -p "projects/$ARGUMENTS/.claude/skills/$name"
    mv "$skill" "projects/$ARGUMENTS/.claude/skills/$name/SKILL.md"
    echo "Migrated: $skill → projects/$ARGUMENTS/.claude/skills/$name/SKILL.md"
  fi
done
```
After migration, update any references in CLAUDE.md from `.claude/skills/[name].md` to `.claude/skills/[name]/SKILL.md`.

**Step 2.9 — Copy pre-built process skills, process agents, and session rules:**

The v2.29.0 CLAUDE.md references process skills and rules via pointers. Without these, every pointer is a broken reference.

**Copy process skills (12 lifecycle — ALWAYS copied, to `.claude/skills/`):**
```bash
# CREATE BOTH TARGETS FIRST. This command targets projects with PARTIAL structure, and `cp` into a
# missing directory FAILS — the loops below ran before any mkdir and reported every copy as done
# while installing nothing (`/audit` 2026-09-14 X-21, X-22). Bootstrap's twin creates them at 5.7.
# BACKSTOP for the Setup guard — it catches a name that splits or globs, NEVER an injected `$(…)`,
# which ran when this fence was parsed (`/audit` 2026-09-14 Y-8).
case "$ARGUMENTS" in ''|.*|*[!A-Za-z0-9._-]*) echo "FAILED: project name is empty, starts with a dot, or has characters outside [A-Za-z0-9._-]"; exit 1 ;; esac
[ -d "projects/$ARGUMENTS" ] || { echo "FAILED: projects/$ARGUMENTS is not an existing folder"; exit 1; }
mkdir -p "projects/$ARGUMENTS/.claude/skills" "projects/$ARGUMENTS/.claude/agents"
for skill_dir in ./docs/modules/skills/*/; do
  skill_name=$(basename "$skill_dir")
  case "$skill_name" in codebase-audit|framework-audit|skill-gate) continue ;; esac  # tier-gated — copied in Step 2.9b
  if [ ! -d "projects/$ARGUMENTS/.claude/skills/$skill_name" ]; then
    if cp -r "$skill_dir" "projects/$ARGUMENTS/.claude/skills/$skill_name"; then echo "Copied skill: $skill_name"; else echo "FAILED to copy skill: $skill_name"; fi
  else
    diff -rq "${skill_dir%/}" "projects/$ARGUMENTS/.claude/skills/$skill_name" >/dev/null 2>&1; rc=$?
    if [ $rc -eq 0 ]; then echo "SKIPPED (identical): $skill_name"
    elif [ $rc -eq 1 ]; then echo "DIFFERS from framework: $skill_name — owner decides: refresh or keep"
    else echo "FAILED to compare skill: $skill_name"; fi   # exit 2 = unreadable, never a difference
  fi
done
```

**ALWAYS REPORT every `DIFFERS` component and ASK the owner — ONE question per component OUTSIDE the
coupled set below, and ONE question for the WHOLE coupled set.** ALWAYS show the diff before asking:
a refresh REPLACES the project's copy. Asking per skill inside the set contradicted "ALL of it or
NONE of it" (`/audit` 2026-09-14 X-4).
- **ALWAYS ASK the coupled-set question in Step 2.9b, never here** — two of its members
  (`codebase-audit`, `skill-gate`) get their verdicts only there, once the risk profile is decided
  (`/audit` 2026-09-15 V-9). Components outside the set are asked here.
- **NEVER overwrite silently** — the project may carry its own evolutions of that skill.
- **NEVER skip silently** — the project would keep an old contract under the new version label.

**THE CONTINUOUS-MODE COUPLED SET — ALWAYS refresh ALL of it or NONE of it:** `autonomous-loop`,
`sprint-proposer`, `pendencias-updater`, `validation-orchestrator`, `session-end`,
`project-md-updater`, the `prd-sync-checker` agent, and — when installed — `codebase-audit`,
`skill-gate` and the `diff-pattern-extractor` agent. Continuous mode
reads an untagged task as `owner`; refreshing `autonomous-loop` without the writers that tag
discovered tasks would admit every AI-filed task uncapped. `autonomous-loop` → "Continuous mode" →
C1 fails CLOSED on that state, so a partial refresh leaves the mode unavailable rather than unsafe —
but only a full refresh makes it usable (`/audit` 2026-09-14 W-2).
**v2.26.0 migration — two members joined the set.** `prd-sync-checker` now tags the tasks it adds, and
C1's writer check is DERIVED from every installed component that mentions `pendencias`, so an older
`prd-sync-checker` reads as an untagged writer and continuous mode stays unavailable. And
`project-md-updater` now writes the `counts as N sessions for audit cadence` weight that
`sprint-proposer` Step 0 reads — an older copy leaves every loop session counted as 1.
**v2.27.0 migration — no member joins; two pairs travel together.** `validation-orchestrator`'s pre-deploy
receipt gate now EXITS 1 unless every reviewer's latest verdict on each commit is a PASS, and prints four fixed `review receipts:` strings, and
`session-log-creator`'s log slot copies them — **ALWAYS offer `session-log-creator` with it**; an older
creator only lacks the pathspec-RED slot, never unsafe. `framework-audit` now writes a `steps:` line in
the `framework-metrics.md` Status cell and runs the steps self-check over the NEWEST row only, so older
rows need no rewrite (the `SINCE=` reader still matches `| COMPLETE`). `codebase-audit` gains the same
self-check and wider guard-invoker sources (`/audit` 2026-09-16 A-6, A-7, A-9, A-13, A-19).
**v2.28.0 migration — the same pair, tightened; no new member.** The pre-deploy receipt gate now matches the
WHOLE verdict field (a prefix like `APPROVE WITH NITS` no longer passes) and every non-RED line names the
pathspec, so `validation-orchestrator` and `session-log-creator` MUST be refreshed together or the log slot
quotes strings the gate no longer prints. `framework-audit` gains a denominator in its HYPOTHESIS listing —
refresh it with `component_design.md`, which now carries the authoring half (a hypothesis lives in a `> `
blockquote). A project that refreshes neither keeps a gate that passes prefixed verdicts
(`/audit` 2026-09-20 AA-6, AA-7, AA-8, AA-1).

**v2.29.0 migration — the frontmatter guard and EVERY agent move together.** Mechanism 4
(`session-rules` → "Model by risk class") makes `model:` mandatory in every `.claude/agents/*.md`
and forbidden in every `.claude/skills/*/SKILL.md`, and the refreshed
`scripts/check-agent-frontmatter.mjs` FAILS on both. So `session-rules.md`, the guard, and every
agent the project holds MUST be refreshed together — refreshing the guard alone turns the
project's `guards` CI stage red on every pre-v2.29.0 agent. The coupled set, the owner-facing
wording and the two honest paths live ONCE, at the guard step's "COUPLED REFRESH" note; this line
is the index, not a second home. `codebase-audit` also gains a breadth-pass model and a wider
`Breadth findings` slot — refresh it with `session-rules.md` or its report prints a heading the
skill no longer mandates.

**REFRESH — ONLY what the owner chose.** `cp -r SRC DEST` onto an EXISTING `DEST` nests it
(`DEST/<name>/SKILL.md`) (`/audit` 2026-09-14 X-4).
**ALWAYS remove, then copy, with these helpers:**
```bash
# Each helper VALIDATES THE SOURCE and THE TARGET'S KIND BEFORE touching anything: an empty or
# template-less name must never reach `rm -rf`, and `cp` onto a DIRECTORY writes INSIDE it.
# BACKSTOP (Setup guard) — no fence in this step may act on a missing project (`/audit` 2026-09-15 V-12).
case "$ARGUMENTS" in ''|.*|*[!A-Za-z0-9._-]*) echo "FAILED: project name is empty, starts with a dot, or has characters outside [A-Za-z0-9._-]"; exit 1 ;; esac
[ -d "projects/$ARGUMENTS" ] || { echo "FAILED: projects/$ARGUMENTS is not an existing folder"; exit 1; }
refresh_skill() { s="./docs/modules/skills/$1"; d="projects/$ARGUMENTS/.claude/skills/$1"
  case "$1" in ''|*[!a-z0-9-]*) echo "FAILED to refresh skill: '$1' is not a skill name — nothing removed"; return 1 ;; esac   # `../agents` passed the template check
  if [ ! -d "$s" ]; then echo "FAILED to refresh skill: '$1' has no framework template — nothing removed"
  elif [ -e "$d" ] && [ ! -d "$d" ]; then echo "FAILED to refresh skill: $1 — a file occupies the target"
  elif rm -rf "$d" && cp -r "$s" "$d"; then echo "Refreshed skill: $1"; else echo "FAILED to refresh skill: $1"; fi; }
refresh_agent() { s="docs/modules/agents/$1.md"; d="projects/$ARGUMENTS/.claude/agents/$(echo "$1" | tr '_' '-').md"
  case "$1" in ''|*[!a-z_]*) echo "FAILED to refresh agent: '$1' is not a template name"; return 1 ;; esac
  if [ ! -f "$s" ]; then echo "FAILED to refresh agent: '$1' has no framework template"
  elif [ -d "$d" ]; then echo "FAILED to refresh agent: $1 — a directory occupies the target"
  elif cp "$s" "$d"; then echo "Refreshed agent: $1"; else echo "FAILED to refresh agent: $1"; fi; }
refresh_extract() { src=$1; lang=$2; d=$3; t=$(mktemp); sed -n "/^\`\`\`\`$lang\$/,/^\`\`\`\`\$/p" "$src" 2>/dev/null | sed '1d;$d' > "$t"
  if [ ! -s "$t" ]; then echo "FAILED to refresh: $src extracted empty"
  elif [ -d "$d" ]; then echo "FAILED to refresh: $d — a directory occupies the target"
  elif cp "$t" "$d"; then echo "Refreshed: $d"; else echo "FAILED to refresh: $d"; fi; rm -f "$t"; }
refresh_rule() { refresh_extract "docs/modules/rules/$1.md" markdown "projects/$ARGUMENTS/.claude/rules/$(echo "$1" | tr '_' '-').md"; }
refresh_guard() { refresh_extract docs/modules/templates/check_agent_frontmatter.md js "projects/$ARGUMENTS/scripts/check-agent-frontmatter.mjs"; }
# The coupled-set refresh runs in Step 2.9b ("THE COUPLED-SET QUESTION"), after all its members' verdicts exist.
```
**ALWAYS define these helpers and call them in the SAME shell invocation** — a function defined in one
Bash call does not exist in the next, and an undefined helper prints no verdict at all.

**Copy process agents (3 subagents — to `.claude/agents/`):**
```bash
# BACKSTOP (Setup guard) — no fence in this step may act on a missing project (`/audit` 2026-09-15 V-12).
case "$ARGUMENTS" in ''|.*|*[!A-Za-z0-9._-]*) echo "FAILED: project name is empty, starts with a dot, or has characters outside [A-Za-z0-9._-]"; exit 1 ;; esac
[ -d "projects/$ARGUMENTS" ] || { echo "FAILED: projects/$ARGUMENTS is not an existing folder"; exit 1; }
for agent in prd_sync_checker criteria_enforcer diff_pattern_extractor; do
  dest_name=$(echo "$agent" | tr '_' '-')
  if [ -d "projects/$ARGUMENTS/.claude/agents/$dest_name.md" ]; then
    echo "FAILED to copy agent: $dest_name — a directory occupies the target"   # X-23: cp would write INTO it
  elif [ ! -e "projects/$ARGUMENTS/.claude/agents/$dest_name.md" ]; then
    if cp "docs/modules/agents/${agent}.md" "projects/$ARGUMENTS/.claude/agents/$dest_name.md"; then echo "Copied agent: $dest_name"; else echo "FAILED to copy agent: $dest_name"; fi
  else
    cmp -s "docs/modules/agents/${agent}.md" "projects/$ARGUMENTS/.claude/agents/$dest_name.md"; rc=$?
    if [ $rc -eq 0 ]; then echo "SKIPPED (identical): $dest_name.md"
    elif [ $rc -eq 1 ]; then echo "DIFFERS from framework: $dest_name.md — owner decides: refresh or keep (diff-pattern-extractor and prd-sync-checker are in the coupled set above)"
    else echo "FAILED to compare agent: $dest_name.md"; fi
  fi
done
```

**Copy rules files (to `.claude/rules/`):**
```bash
# FOUR DIRECTORIES THIS FENCE CREATES: `.claude/rules/`, which the loop below writes into, plus
# THREE THIS COMMAND WRITES INTO LATER (`/audit` 2026-09-14 Y-10). A write — `cp` or a `sed … >`
# redirect — to a missing directory FAILS, and this command targets projects with only PARTIAL
# framework structure, so this fence does not assume an earlier fence ran: `.claude/agents/` (Step 4.6.5 copies specialists into it),
# `assets/docs/` (Phase 3 writes the retroactive PRD into it) and `.claude/docs/` (the upstream
# channel `evolution-policy.md` mandates). Bootstrap created the first two and this twin did
# not — twin asymmetry, found by the LATERAL directory sweep (`/audit` 2026-09-11).
# `.claude/agents/` is now ALSO created at the top of the skills fence above, which runs first
# (`/audit` 2026-09-14 X-22); repeating it here is harmless and keeps this fence self-sufficient.
# BACKSTOP (Setup guard) — the mkdir below must never create a missing project (`/audit` 2026-09-15 V-12).
case "$ARGUMENTS" in ''|.*|*[!A-Za-z0-9._-]*) echo "FAILED: project name is empty, starts with a dot, or has characters outside [A-Za-z0-9._-]"; exit 1 ;; esac
[ -d "projects/$ARGUMENTS" ] || { echo "FAILED: projects/$ARGUMENTS is not an existing folder"; exit 1; }
mkdir -p "projects/$ARGUMENTS/.claude/rules" "projects/$ARGUMENTS/.claude/agents" "projects/$ARGUMENTS/.claude/docs" "projects/$ARGUMENTS/assets/docs"
# A VERDICT FOR EVERY OUTCOME, and `Copied` ONLY after the write succeeded and is non-empty: a redirect
# into an occupied path, or an empty extraction, printed `Copied` over nothing (`/audit` 2026-09-14 Y-8).
# An existing file gets the same identical / DIFFERS verdict skills and agents get (X-4).
for tmpl in session_rules evolution_policy component_design; do
  target=$(echo "$tmpl" | tr '_' '-')
  dest="projects/$ARGUMENTS/.claude/rules/${target}.md"
  t=$(mktemp); sed -n '/^````markdown$/,/^````$/p' "docs/modules/rules/${tmpl}.md" | sed '1d;$d' > "$t"
  if [ ! -s "$t" ]; then echo "FAILED to extract rule template: ${tmpl}.md"
  elif [ ! -e "$dest" ]; then
    if cp "$t" "$dest"; then echo "Copied ${target}.md"; else echo "FAILED to copy rule: ${target}.md"; fi
  elif [ ! -f "$dest" ]; then echo "FAILED to copy rule: ${target}.md — the target is not a regular file"
  else cmp -s "$t" "$dest"; rc=$?
    if [ $rc -eq 0 ]; then echo "SKIPPED (identical): ${target}.md"
    elif [ $rc -eq 1 ]; then echo "DIFFERS from framework: ${target}.md — owner decides: refresh or keep"
    else echo "FAILED to compare rule: ${target}.md"; fi
  fi
  rm -f "$t"
done
```

**Copy the component-registry liveness guard (all tiers — to `scripts/`):**
```bash
# BACKSTOP (Setup guard) — the mkdir below must never create a missing project (`/audit` 2026-09-15 V-12).
case "$ARGUMENTS" in ''|.*|*[!A-Za-z0-9._-]*) echo "FAILED: project name is empty, starts with a dot, or has characters outside [A-Za-z0-9._-]"; exit 1 ;; esac
[ -d "projects/$ARGUMENTS" ] || { echo "FAILED: projects/$ARGUMENTS is not an existing folder"; exit 1; }
mkdir -p "projects/$ARGUMENTS/scripts"
dest="projects/$ARGUMENTS/scripts/check-agent-frontmatter.mjs"
t=$(mktemp); sed -n '/^````js$/,/^````$/p' docs/modules/templates/check_agent_frontmatter.md | sed '1d;$d' > "$t"
if [ ! -s "$t" ]; then echo "FAILED to extract guard template: check_agent_frontmatter.md"
elif [ ! -e "$dest" ]; then
  if cp "$t" "$dest"; then echo "Copied guard: scripts/check-agent-frontmatter.mjs"; else echo "FAILED to copy guard: scripts/check-agent-frontmatter.mjs"; fi
elif [ ! -f "$dest" ]; then echo "FAILED to copy guard: scripts/check-agent-frontmatter.mjs — the target is not a regular file"
else cmp -s "$t" "$dest"; rc=$?
  if [ $rc -eq 0 ]; then echo "SKIPPED (identical): check-agent-frontmatter.mjs"
  elif [ $rc -eq 1 ]; then echo "DIFFERS from framework: check-agent-frontmatter.mjs — owner decides: refresh or keep"
  else echo "FAILED to compare guard: check-agent-frontmatter.mjs"; fi
fi
rm -f "$t"
```

An invalid YAML frontmatter makes a component silently VANISH from the registry
(FRAMEWORK-AGENT-YAML-01 — see component-design.md §8); this guard fails loud instead. If the
project has a `package.json`, register `"check:agents": "node scripts/check-agent-frontmatter.mjs"`;
if it has a CI pipeline, add a `guards` stage running it (dependency-free, no install needed).
Then RUN it once now — an adapted project may already carry a broken frontmatter.

**COUPLED REFRESH — `session-rules.md`, the guard and EVERY agent move TOGETHER, or the project's
CI goes red.** As of
v2.29.0 the guard also enforces mechanism 4 (`session-rules` → "Model by risk class"): `model:` is
MANDATORY in every `.claude/agents/*.md` and FORBIDDEN in every `.claude/skills/*/SKILL.md`. A
project adapted before v2.29.0 carries neither.

**ALWAYS TELL THE OWNER, at the `DIFFERS from framework: check-agent-frontmatter.mjs` decision,
that refreshing the guard alone will fail on every existing agent** — then offer the two honest
paths: refresh `session-rules.md`, the guard AND every agent in the SAME pass — all three, so the
policy the guard enforces is the one the project holds (each agent's value is decided by what its
report produces: `inherit` for any gating verdict) — or keep the current guard until that pass is
scheduled.

**NEVER refresh the guard silently on a project whose agents carry no `model:`.**

**ALWAYS STOP on any line beginning `FAILED` printed by the fences of this step AND of Step 2.9b** —
`FAILED to copy`, `FAILED to extract`, `FAILED to refresh`, `FAILED to compare`, and the backstops' `FAILED:` lines. The target is unwritable, occupied by a file or directory
of the wrong kind, or its template extracted empty (`/audit` 2026-09-14 Y-9).
- **NEVER continue past a FAILED component** — into Step 2.9b, or out of it — every CLAUDE.md pointer to it is a broken reference.
- **ALWAYS name the path to the owner, ASK before removing anything that belongs to the project**, fix it, and re-run the fence until it prints no `FAILED` line.
- **ALWAYS REPORT — `copy failures: none` or `copy failures: N resolved by re-run — [components, or "project name" for a backstop line]`.** An unresolved failure has no verdict, because the step has not ended.

**Expected after this step:**
- **Process skills (12 lifecycle):** sprint-proposer, autonomous-loop, session-end, context-recovery, validation-orchestrator, project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator, cross-cutting-analysis, commit
- **Process agents (3):** prd-sync-checker, criteria-enforcer, diff-pattern-extractor
- **Rules (3 core):** session-rules.md, evolution-policy.md, component-design.md
- **Guards (1):** scripts/check-agent-frontmatter.mjs (component-registry liveness — run once during adaptation)

Skills and agents are auto-discovered by Claude Code. No explicit listing is needed in CLAUDE.md.

---

**Step 2.9b — Determine risk profile + copy tier-gated MACRO skeletons:**

The current framework scales ceremony by risk profile. Existing projects must be tiered too.

1. **Determine the profile.** Read `project.md` Overview → **Risk profile:**. If absent, derive it
   from the codebase (money/PII/multi-tenant → `production-financial`; public app with auth/data →
   `production`; internal/admin → `internal-tool`; throwaway → `prototype`) and
   **confirm with the owner** (ASK). Record it in `project.md` Overview and CLAUDE.md.

   **FORWARD REFERENCE, FLAGGED: the retroactive PRD does NOT exist yet.** This step runs in
   Phase 2; Phase 3 creates the PRD. The fallback source therefore names an artifact this step
   cannot read — **on the COMMON path**, an existing project with no `Risk profile:` line, which
   is exactly what this command targets. Every other Phase-2→later dependency in this file is
   explicitly flagged and this one was silent (`/audit` 2026-09-10 U-18).
   **NEVER wait for the PRD here, and NEVER read it.** The profile gates every tier-gated copy in
   this same step, so it MUST resolve now, from the codebase plus the owner's answer.

   **PHASE-3 RE-CHECK — ALWAYS run it, and ALWAYS REPORT — `risk profile: confirmed unchanged` or
   `risk profile: revised [old] → [new] — N tier-gated artifacts [copied | already present]`.**
   When the retroactive PRD lands in Phase 3, re-read it against the profile chosen here, **and ALWAYS
   re-run Step 2.6's Red/Blue Team decision** against the PRD and the resolved profile. A
   revision UPWARD means tier-gated skeletons this step skipped are now owed: copy them then,
   never silently. **NEVER emit nothing.**

2. **Copy what the profile warrants** (uncopied = inactive ceremony; the cheap core clauses arrive
   automatically via the updated session-rules/evolution-policy/criteria-enforcer copied above):

```bash
PROFILE="[chosen]"   # prototype | internal-tool | production | production-financial
PROJ="projects/$ARGUMENTS"
# EPA targets projects that may have NO framework structure — the metrics redirects below
# fail silently without this. (bootstrap has the same guard at its Step 5.8.)
# BACKSTOP (Setup guard) — the mkdir below must never create a missing project (`/audit` 2026-09-15 V-12).
case "$ARGUMENTS" in ''|.*|*[!A-Za-z0-9._-]*) echo "FAILED: project name is empty, starts with a dot, or has characters outside [A-Za-z0-9._-]"; exit 1 ;; esac
[ -d "$PROJ" ] || { echo "FAILED: $PROJ is not an existing folder"; exit 1; }
mkdir -p "$PROJ/.claude/phases" "$PROJ/.claude/skills" "$PROJ/.claude/agents"
# VERDICTS, NEVER A SILENT `[ ! -d ] && cp`: codebase-audit and skill-gate are members of Step 2.9's
# coupled set, and a copy with no verdict cannot be refreshed all-or-none (`/audit` 2026-09-14 X-3).
tier_skill() { d="$PROJ/.claude/skills/$1"
  if [ ! -e "$d" ]; then if cp -r "docs/modules/skills/$1" "$d"; then echo "Copied skill: $1"; else echo "FAILED to copy skill: $1"; fi
  elif [ ! -d "$d" ]; then echo "FAILED to copy skill: $1 — a file occupies the target"
  else diff -rq "docs/modules/skills/$1" "$d" >/dev/null 2>&1; rc=$?
    if [ $rc -eq 0 ]; then echo "SKIPPED (identical): $1"
    elif [ $rc -eq 1 ]; then case "$1" in codebase-audit|skill-gate) m=" (Step 2.9 coupled set)" ;; *) m="" ;; esac
      echo "DIFFERS from framework: $1 — owner decides: refresh or keep$m"
    else echo "FAILED to compare skill: $1"; fi
  fi; }
tier_agent() { n=$(echo "$1" | tr '_' '-'); d="$PROJ/.claude/agents/$n.md"
  if [ -d "$d" ]; then echo "FAILED to copy agent: $n.md — a directory occupies the target"
  elif [ ! -e "$d" ]; then if cp "docs/modules/agents/$1.md" "$d"; then echo "Copied agent: $n.md"; else echo "FAILED to copy agent: $n.md"; fi
  else cmp -s "docs/modules/agents/$1.md" "$d"; rc=$?
    if [ $rc -eq 0 ]; then echo "SKIPPED (identical): $n.md"
    elif [ $rc -eq 1 ]; then echo "DIFFERS from framework: $n.md — owner decides: refresh or keep"
    else echo "FAILED to compare agent: $n.md"; fi
  fi; }
# Extracted templates: a RULE gets identical / DIFFERS; a PHASE DOC (metrics) is project data once
# present, so it is never compared. A redirect with no verdict left a 0-byte file silently.
tier_tmpl() { src=$1; d=$2; kind=$3; t=$(mktemp); sed -n '/^````markdown$/,/^````$/p' "$src" | sed '1d;$d' > "$t"
  if [ ! -s "$t" ]; then echo "FAILED to extract: $src"
  elif [ -d "$d" ]; then echo "FAILED to copy: $d — a directory occupies the target"
  elif [ ! -s "$d" ]; then   # absent, OR the 0-byte file the old silent redirect left behind
    if cp "$t" "$d"; then echo "Copied: $d"; else echo "FAILED to copy: $d"; fi
  elif [ "$kind" = data ]; then echo "SKIPPED (present — project data): $d"
  else cmp -s "$t" "$d"; rc=$?
    if [ $rc -eq 0 ]; then echo "SKIPPED (identical): $d"
    elif [ $rc -eq 1 ]; then echo "DIFFERS from framework: $d — owner decides: refresh or keep"
    else echo "FAILED to compare: $d"; fi
  fi; rm -f "$t"; }
case "$PROFILE" in
  internal-tool|production|production-financial)
    tier_skill codebase-audit
    tier_tmpl docs/modules/templates/metrics_md.md "$PROJ/.claude/phases/metrics.md" data
    tier_skill skill-gate
    tier_agent skill_reviewer
    mkdir -p "$PROJ/.claude/drafts/skills" "$PROJ/.claude/drafts/rules" "$PROJ/.claude/skill-gate/review_reports"
    ;;
esac
case "$PROFILE" in
  production|production-financial)
    tier_skill framework-audit
    mkdir -p "$PROJ/.claude/rules"
    tier_tmpl docs/modules/templates/framework_metrics_md.md "$PROJ/.claude/phases/framework-metrics.md" data
    tier_tmpl docs/modules/rules/ops_rules.md "$PROJ/.claude/rules/ops-rules.md" rule
    tier_tmpl docs/modules/rules/quality_budgets.md "$PROJ/.claude/rules/quality-budgets.md" rule
    ;;
esac
```

**Step 2.9's STOP rule governs every `FAILED` line the fence above prints.**

**THE COUPLED-SET QUESTION — ALWAYS ASK IT HERE, ONCE, over the members' verdicts from Steps 2.9 AND
2.9b.** The members are the six lifecycle skills and the `diff-pattern-extractor` and `prd-sync-checker` agents (Step 2.9) plus
`codebase-audit` and `skill-gate` whenever they are PRESENT in the project — installed by the fence
above at this tier, or left from an earlier one (a leftover copy is still a writer continuous mode reads).
- **ALWAYS show every differing member's diff before asking.**
- **Answer "refresh" → ALWAYS run the Step 2.9 REFRESH helpers fence and the fence below in ONE shell invocation.**
- **Answer "keep", or no member differed → run nothing, and say so in the coupled-set slot.**
```bash
# BACKSTOP (Setup guard) — no fence in this step may act on a missing project (`/audit` 2026-09-15 V-12).
case "$ARGUMENTS" in ''|.*|*[!A-Za-z0-9._-]*) echo "FAILED: project name is empty, starts with a dot, or has characters outside [A-Za-z0-9._-]"; exit 1 ;; esac
[ -d "projects/$ARGUMENTS" ] || { echo "FAILED: projects/$ARGUMENTS is not an existing folder"; exit 1; }
command -v refresh_skill >/dev/null 2>&1 || { echo "FAILED to refresh: the Step 2.9 helpers are not defined in this invocation"; exit 1; }
for s in autonomous-loop sprint-proposer pendencias-updater validation-orchestrator session-end project-md-updater; do refresh_skill "$s"; done
for s in codebase-audit skill-gate; do
  # `-e`, never `-d`: a FILE at the target must reach refresh_skill's own "a file occupies" FAILED.
  if [ -e "projects/$ARGUMENTS/.claude/skills/$s" ]; then refresh_skill "$s"; else echo "SKIPPED (not installed): $s"; fi
done
refresh_agent diff_pattern_extractor
refresh_agent prd_sync_checker
```

**`framework-audit` + `session-log-creator` ↔ `autonomous-loop` (v2.25.0 migration) — at `production`+,
ALWAYS PRESENT THEM TOGETHER when any of them DIFFERS.** (EPA-only: bootstrap installs all three
fresh, so it has no twin of this rule.) `autonomous-loop`'s HYPOTHESES note names `framework-audit` →
Q4 → the HYPOTHESIS check as its measurer, and that check counts lines only `session-log-creator`
writes. Refreshing `autonomous-loop` with the coupled set while keeping older copies of the other two
leaves the note pointing at a check or a log section the project lacks, so the rules stay unmeasured
(never unsafe) (`/audit` 2026-09-15 B-11). **Answer "refresh" → ALWAYS run `refresh_skill
framework-audit` and `refresh_skill session-log-creator` in the same invocation as the Step 2.9
helpers**, and record the choice on the `framework-audit` entry of the MACRO skeletons slot.

**`production-financial` — ALWAYS add a line under "Architecture Patterns" in `code-reviewer.md`
(Step 2.4 created or upgraded it): `red-team is MANDATORY on every diff that touches a money path.`**
Bootstrap Step 7 writes the same line; this twin carried none (found by the `/audit` 2026-09-14
W-14 PARALLEL sweep).

3. **CI floor (internal-tool+):** if the project has no CI workflow, create one (install → lint →
   build → test) or register a task to add it. **prototype:** skip THIS CI floor — never the
   coupled-set question above, which runs at every tier because a leftover member can be present at
   any tier (`/audit` 2026-09-15 B-2). (EPA-only wording: bootstrap has no coupled-set question.)
   **ALWAYS verify the test stage PROVES it executed** — whether the pipeline is new or
   pre-existing (session-rules → "Execution proof"): a zero-unit run must FAIL, and any
   conditional skip path (missing secrets/config) must exit RED with a named reason, never the
   same green as a real run. If the existing pipeline cannot prove it, register a task rather
   than leaving the gate aspirational.

4. **Add the Post-Mortem Ledger** section to `project.md` (internal-tool+) and the **Risk profile &
   ceremony tiers** awareness via the refreshed `session-rules.md` (already copied in Step 2.9).

---

### Phase 3 — Create Retroactive PRD

The PRD does not need to be speculative — it describes what already exists plus what is planned.

Create `projects/$ARGUMENTS/assets/docs/prd.md` with this approach:

**`## Cross-cutting Concerns` — ALWAYS populate it FIRST.** It is the FIRST section of the PRD
Structure template (`prd_planning.md`), and omitting it produces a retroactive PRD that fails its
own template. **ALWAYS INVOKE the `cross-cutting-analysis` skill in CONSULTATION-then-GENERATION
mode over the codebase analysis from Phase 1** — this command installs that skill at Step 2.9 and,
until now, never exercised it (`/audit` 2026-09-02 L-1). Themes that span modules and must stay
consistent (auth, tenancy, i18n, money handling, audit trail) are exactly what an existing
codebase makes visible and a retroactive PRD most needs.
**ALWAYS REPORT — `cross-cutting: N concerns identified` or `none — no theme spans 2+ modules`.
NEVER emit nothing.**

**Sections to populate from codebase analysis (what IS):**
- 1.1 Problem — infer from the project's purpose
- 1.2 Solution — describe what the product does today
- 2.1 In Scope (MVP) — list modules/features that are ALREADY IMPLEMENTED, mark as ✅
- 3.x Functional Requirements — for each implemented module: document the business rules you can infer from the code (database schema, API routes, UI flows). Mark each as `[Inferred from code — verify with owner]`
- 5.1 Stack — extracted from package.json / config files (this is factual)
- 5.3 Data Model — extracted from schema/models

**Sections the template defines that this list previously OMITTED — ALWAYS populate them too**
(`/audit` 2026-09-02 M-55; a retroactive PRD that skips them fails its own template):
- 2.3 Constraints — deadlines, compliance, platform limits visible in the codebase or from the owner
- 5.2 External Integrations — every third-party service the code actually calls
- 5.4 Build Order — derive it from `pendencias.md`'s dependency order; bootstrap reads this section
- 9. Risks and Dependencies — the watch-items `pendencias.md`'s Future Improvements already imply

**Sections to populate from pendencias.md (what is PLANNED):**
- 2.1 In Scope — add pending features marked as ⏳
- 2.2 Out of Scope — features explicitly excluded or deferred
- 8. Roadmap — current phase + remaining phases

**Sections that need user input (mark as TBD):**
- 1.3 Target Audience (personas) — `[TBD — describe your users]`
- 1.4 Competitive Differentiator — `[TBD]`
- 7. Business Model — `[TBD — describe monetization]`
- 4. Non-Functional Requirements — `[TBD — define performance/security/availability targets]`
- 6. Design and UX — `[TBD or reference existing design system]`

**Changelog:**
```
| Version | Date | Change | Author |
|---------|------|--------|--------|
| 1.0.0 | [date] | Retroactive PRD — created from codebase analysis during framework adaptation | AI + [owner] |
```

**After creating the PRD:** update CLAUDE.md to reference it (`**PRD:** See assets/docs/prd.md`), **and ALWAYS
write `**PRD version:** v1.0.0` into `.claude/phases/project.md`** when an existing project.md lacks it —
bootstrap Step 3 writes the field and prd-sync-checker Check A compares against it, and an adapted
project whose project.md already existed never received it (`/audit` 2026-09-19 C-24).

---

### Phase 4 — Copy Examples and Fill Gaps

**Step 4.1 — Copy framework examples (if not already present):**

```bash
# Check if examples exist
ls projects/$ARGUMENTS/assets/examples/ 2>/dev/null || echo "MISSING"
```

If missing, copy from the framework root:
```bash
cp -r ./examples/ projects/$ARGUMENTS/assets/examples/ 2>/dev/null || echo "Framework examples not accessible — copy manually from the framework's examples/ directory"
```

**Step 4.1b — Route the PRD's Cross-cutting Concerns (RECEIVER of Phase 3's list):**

**ALWAYS ROUTE each concern Phase 3 identified to the artifact that owns it** — the same three
destinations bootstrap Step 1.1 uses, so an adapted project and a bootstrapped one end up with the
same structure:

| Concern constrains… | Destination | Receiver step |
|---|---|---|
| CODE | a `.claude/rules/` domain rules file | **Step 4.6** — "Pre-create domain rules from retroactive PRD", the PRD-derived analogue of bootstrap Step 13. NOT Step 2.7.1, which is codebase-derived and runs before the PRD exists. |
| ARCHITECTURE | a row in `project.md`'s Architectural Decisions table | **Step 2.2** |
| WORK still to do | a task in `pendencias.md` | **Step 2.3** |

**THIS step writes the ARCHITECTURE and WORK concerns in itself** — the "Receiver step" column
names the artifact each concern LANDS in, not who performs the write. Steps 2.2 and 2.3 ran in
Phase 2, before the PRD existed, so they cannot have received anything and carry no write mandate;
**reopen their artifacts from here.** Step 4.6 is the one true receiver: it runs AFTER this step
and consumes the CODE rows itself.
Reopening a Phase-2 artifact from Phase 4 is normal in this command, not exceptional — Phase 3's
closing line reopens Step 2.1's CLAUDE.md and Step 4.6 reopens Step 2.7.1's rules files.

**ALWAYS CLASSIFY each concern as CODE / ARCHITECTURE / WORK before routing** — Phase 3 emits the
COUNT (`N concerns identified`) and does not split it, so the R/A/T breakdown is produced HERE.

**ALWAYS REPORT BOTH LINES — routing AND writing:**
- `cross-cutting routed: R rules, A decisions, T tasks (of N identified)`, or
  `cross-cutting: none identified`. R+A+T below N is RED — name the dropped concern.
- `cross-cutting written: A/A decisions into project.md, T/T tasks into pendencias.md` — the writes
  THIS step performs. `R/R` is reported by Step 4.6, which performs its own.
**NEVER emit nothing.** Both lines have a slot in this command's final report; a mandated verdict
with no slot is owed by nobody (`/audit` 2026-09-03 N-21, N-27).

**Step 4.2 — Create settings.json and initialize logs (if missing):**

Read the template at `docs/modules/templates/settings_json.md` for the reference configuration. If `projects/$ARGUMENTS/.claude/settings.json` or `projects/$ARGUMENTS/.claude/settings.local.json` already exists, **merge** the keys rather than overwriting.

```bash
# Create logs directory
mkdir -p projects/$ARGUMENTS/.claude/logs 2>/dev/null

# Create settings.json if missing (Claude Code only)
if [ ! -f "projects/$ARGUMENTS/.claude/settings.json" ] && [ -d "projects/$ARGUMENTS/.claude" ]; then
  cat > projects/$ARGUMENTS/.claude/settings.json << 'SETTINGS'
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Edit(CLAUDE.md)",
      "Edit(.claude/**)",
      "Write(.claude/**)",
      "Read",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(npx *)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_TOOL_FILE_PATH\" == *.js || \"$CLAUDE_TOOL_FILE_PATH\" == *.ts || \"$CLAUDE_TOOL_FILE_PATH\" == *.jsx || \"$CLAUDE_TOOL_FILE_PATH\" == *.tsx || \"$CLAUDE_TOOL_FILE_PATH\" == *.json || \"$CLAUDE_TOOL_FILE_PATH\" == *.css || \"$CLAUDE_TOOL_FILE_PATH\" == *.md ]]; then npx prettier --write \"$CLAUDE_TOOL_FILE_PATH\" 2>/dev/null || true; fi",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "if [ -f .claude/skills/skill-gate/scripts/skill_gate_hook.sh ]; then bash .claude/skills/skill-gate/scripts/skill_gate_hook.sh; fi",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
SETTINGS
  echo "Created settings.json with hooks"
fi
```

**The smart-formatting hook requires Prettier. If the project does not use Prettier, ALWAYS drop the
Prettier hook entry and KEEP the skill-gate hook entry** — it has no dependency (bootstrap Step 14
carries the same rule; `/audit` 2026-09-15 V-16). If settings.json already existed, merge the skill-gate hook entry into its `PostToolUse` array — without it, the gate installed in Step 2.9b is never enforced (it remains a harmless no-op on tiers where skill-gate was not copied).

**ALWAYS WRITE HERE the adaptation row and the session log that Step 2.2 specifies** — the
retroactive PRD exists now (Phase 3) and the fence above just created `.claude/logs/`.

**ALWAYS write the hooks outcome into CLAUDE.md's `## Hooks` section** — the configured hooks, or
`configured — skill-gate hook only (project has no formatter)` — **and ALWAYS REPORT — `configured — [the hooks written]` or
`configured — skill-gate hook only (project has no formatter)`** (the two outcomes bootstrap Step 14 writes; the report offered
this slot with no step producing it — `/audit` 2026-09-14 W-19). The note above keeps the skill-gate
entry for a project with no formatter, so `none` was never a true outcome (`/audit` 2026-09-15 V-15).

**Step 4.3 — Discover and install MCPs:**

**4.3a. Check existing MCPs:**
```bash
cat projects/$ARGUMENTS/.claude/settings.json 2>/dev/null | grep -A5 "mcpServers"
cat projects/$ARGUMENTS/.claude/settings.local.json 2>/dev/null
```

**4.3b. Install browser automation (default for every project):**
```bash
npx @anthropic-ai/claude-code mcp add playwright -- npx -y @anthropic-ai/mcp-server-playwright
```

**4.3c. Install stack-based MCPs** based on the stack identified in Phase 1:

| Stack includes | Recommended MCP | When to install |
|---------------|----------------|-----------------|
| Supabase | supabase MCP | If Supabase project exists |
| PostgreSQL (not Supabase) | postgres MCP | If database exists |
| GitHub repo | github MCP | If repo exists |
| React/Next.js/Vue with libs | context7 MCP | Yes |

**4.3d. Security validation (MANDATORY before installing any MCP):**
```
□ Trusted source? (official org, verified publisher, >10k downloads)
□ Actively maintained? (published within last 6 months)
□ Reasonable permissions? (read-only by default)
□ Open source? (public repo with auditable code)
□ Actually relevant? (solves concrete problem for this stack)
```

If any fails: do not install, log reason. If uncertain: ASK user. Max 5 MCPs on day 1.

Register installed MCPs in CLAUDE.md "MCP Servers" section.
**ALWAYS REPLACE any placeholder in that section before this step ends** — with the installed
servers, or with the literal line `None installed.` — **and ALWAYS REPORT — `MCP: N installed [names]`
or `MCP: none installed — placeholder replaced`** (bootstrap Step 5's mandate; the report's second
verdict had no producing step here — `/audit` 2026-09-14 W-19).

**Step 4.4 — Enable Skill Creator plugin:**

1. Check if already installed: `grep -r "skill-creator" ~/.claude/plugins/installed_plugins.json 2>/dev/null`
2. If not installed: `/plugin install skill-creator@claude-plugins-official`
3. Enable in project settings.json — merge this key into the existing file:
   ```json
   "enabledPlugins": {
     "skill-creator@claude-plugins-official": true
   }
   ```
4. **If installation fails** (plugin not available, network error, unsupported environment): Log "Skill Creator plugin unavailable — framework creation eval protocol will be used instead." Continue normally.

**Step 4.5 — Discover and install stack skills:**

Search for available skills relevant to the project stack:
```bash
npx claude-code-templates@latest --list-skills 2>/dev/null || echo "CLI not available"
```

If the stack has framework-specific patterns AND no pre-made skill was found, create a stack skill:
```bash
mkdir -p projects/$ARGUMENTS/.claude/skills/[stack-name]
# Create projects/$ARGUMENTS/.claude/skills/[stack-name]/SKILL.md with key patterns, common mistakes, security settings
```

Register in CLAUDE.md "Skills & Agents" section.

**Step 4.6 — Pre-create domain rules from retroactive PRD:**

**This step is the RECEIVER of Step 4.1b's CODE concerns — and, unlike Steps 2.2 and 2.3, it
genuinely is one: it runs AFTER Step 4.1b.** ALWAYS write in every concern Step 4.1b routed here,
and REPORT `cross-cutting received: R/R code concerns written` — a mismatch with Step 4.1b's count
is RED.
**This step is ALSO the RECEIVER of Step 2.7.1's DEFERRED domain-rule matches.** Step 2.7.1 runs
before Step 4.1 has copied `assets/examples/rules/`, so on a never-bootstrapped project it defers
its matches HERE by name. **ALWAYS consume that deferred list and ALWAYS REPORT
`deferred domain rules: N/N created` or `deferred domain rules: none — Step 2.7.1 deferred nothing`
— a mismatch with Step 2.7.1's deferred count is RED, and it is the line that CLOSES 2.7.1's own
report. NEVER emit nothing.** Step 2.7.1 pointed here from the moment M-9 re-pointed it, and this
step never mentioned the deferral (`/audit` 2026-09-03 N-22).
(Bootstrap's Steps 3/4/13 each carry a receiver declaration because each genuinely runs after
its router. **EPA has exactly ONE true receiver — this step.** Steps 2.2 and 2.3 run in Phase 2,
before the PRD exists, so Step 4.1b reopens their artifacts and performs those writes itself.
An earlier fix gave all three a write mandate, which put two steps on one write —
`/audit` 2026-09-02 M-2, corrected 2026-09-03 N-21.)

Analyze the retroactive PRD (created in Phase 3) for domain signals matching example templates (same mapping table as Step 2.7.1). For each domain that is a core feature or architectural pattern:

- If the rules file was already pre-created in Step 2.7.1: skip (already exists)
- If the rules file does NOT exist and a matching example template is available: pre-create using the same process as Step 2.7.1
- If the domain has complex business logic but NO matching example template: register in `pendencias.md`:
  ```
  - Create `.claude/rules/[module]-rules.md` when starting implementation of [module]
  ```

**Step 4.6.5 — Pre-install specialist agents and validate activation chains:**

Read the project's `.claude/agents/code-reviewer.md`, `.claude/agents/security-reviewer.md` **and `.claude/agents/validator.md` — ALL THREE declaring components** (`component-design` §1; the validator declares the visual-regression gap from inside its own Validation Report, and the table below attributes that gap to it. Reading two of three meant this step could not produce its own table's row — `/audit` 2026-09-04 Q-1). Identify which Coverage Gap Declaration sections are present. For each gap declaration, check if a matching specialist agent ALREADY EXISTS in `.claude/agents/`. If it does NOT exist and a matching example is available in `assets/examples/agents/`, pre-install it:

| Gap declaration (in reviewer) | Specialist example to install |
|-------------------------------|-------------------------------|
| accessibility gap (code-reviewer) | accessibility-checker.md |
| performance gap (code-reviewer) | performance-auditor.md |
| concurrency gap (code-reviewer) | concurrency-tester.md |
| visual regression gap (code-reviewer + validator) | visual-regression-tester.md |
| data integrity gap (code-reviewer) | data-integrity-checker.md |
| static analysis gap (security-reviewer) | sast-scanner.md |
| secrets coverage gap (security-reviewer) | secrets-scanner.md |
| federation protocol gap (security-reviewer) | oauth-flow-tester.md |
| compliance gap (security-reviewer) | compliance-auditor.md |
| infrastructure security gap (security-reviewer) | iac-scanner.md |

For each match: copy from `assets/examples/agents/` to `.claude/agents/`, adapting only:
- `created:` lineage: change from `example` to `adaptation (pre-installed from example template)`
- Verify the `description:` gap phrase matches the declaring component's gap declaration vocabulary

If a gap was KEPT but no matching example exists in `assets/examples/agents/`: register in
`pendencias.md` — "Create specialist agent for [gap] when domain implementation begins." A kept
gap that installs nothing and registers nothing is a gap the project can never act on.

> **The declaring components are gap SOURCES, not gap targets, and the loop below DERIVES that set rather than listing it** — it harvests the declared gaps from whichever files declare them and excludes exactly those files.
> **NEVER type the set here**: a typed five-name copy stood two lines above the loop that derives it, and its twin carried no such paragraph at all (`/audit` 2026-09-04 R-32). The replacement then asserted a derivation the loop did not perform — it still typed the three declarer names — until `/audit` 2026-09-09 T-16 made the loop match the paragraph.

After installation, validate activation chains for every pre-installed specialist.

**THIS SPAN IS TWINNED — bootstrap Step 12.5b and EPA Step 5.1 MUST be byte-identical between
the TWINNED SPAN markers, and ONLY between them.** D6.7 diffs the install TABLES, which were
byte-identical while this prose diverged (`/audit` 2026-09-04 Q-34); the repair then asserted
word-for-word equivalence over the whole block, and that claim was false in four places — item
wrapping, the lead-in, the closer, and a bootstrap-only paragraph with no EPA counterpart
(`/audit` 2026-09-10 U-24). An UNBOUNDED equivalence claim over prose that legitimately differs
(step numbers, path prefixes) is unfalsifiable; the markers make it mechanical. The mandate also
lived on ONE side only — the R-32 shape it exists to forbid — so it is now on both.
**ALWAYS run this before committing either twin, expected result stated:**
```bash
ex() { sed -n '/TWINNED SPAN START: activation-chain criteria/,/TWINNED SPAN END/p' "$1"; }
diff <(ex .claude/commands/bootstrap.md) <(ex .claude/commands/existing_project_adaptation.md)
```
**Expected: no output (exit 0).** Any output is RED and BLOCKS the commit.

<!-- TWINNED SPAN START: activation-chain criteria (bootstrap Step 12.5b == EPA Step 5.1) -->
1. Verify it has a matching Coverage Gap Declaration in the declaring component (code-reviewer.md,
   security-reviewer.md or validator.md) whose domain vocabulary echoes the agent's Pushy Description
2. If no match: add the gap declaration to the appropriate DECLARING COMPONENT (a reviewer, or the
   validator) following the existing conditional format — see `docs/modules/rules/component_design.md` sections 1-3
3. The pass criterion: the domain must appear in **at least one** declaring component
4. Run a vocabulary alignment check: `grep "[domain keyword]" .claude/agents/code-reviewer.md .claude/agents/security-reviewer.md .claude/agents/validator.md`
<!-- TWINNED SPAN END -->

This step prevents "orphan agents" that exist in `.claude/agents/` but are never spawned because the declarer-to-orchestrator-to-specialist activation chain is broken (twin parity with bootstrap Step 12.5b — `/audit` 2026-09-04 Q-34).

---

### Phase 5 — Validation and Report

**Step 5.1 — Run consistency check:**

```bash
echo "=== File structure ==="
find projects/$ARGUMENTS/.claude -name "*.md" -o -name "*.json" | sort

echo "=== CLAUDE.md references valid files? ==="
# Check that referenced paths exist
grep -oP '`[^`]*\.md`' projects/$ARGUMENTS/CLAUDE.md | sort -u | while read ref; do
  path=$(echo "$ref" | tr -d '`')
  [ ! -f "projects/$ARGUMENTS/$path" ] && echo "BROKEN REF: $path"
done

echo "=== PRD exists? ==="
ls projects/$ARGUMENTS/assets/docs/prd.md 2>/dev/null && echo "YES" || echo "NO"

echo "=== All agents have effort: frontmatter? ==="
for f in projects/$ARGUMENTS/.claude/agents/*.md; do
  grep -q "effort:" "$f" 2>/dev/null || echo "MISSING effort: in $f"
done

echo "=== All agents have invocation: frontmatter? ==="
for f in projects/$ARGUMENTS/.claude/agents/*.md; do
  grep -q "invocation:" "$f" 2>/dev/null || echo "MISSING invocation: in $f"
done

echo "=== All agents have lineage frontmatter? ==="
for f in projects/$ARGUMENTS/.claude/agents/*.md; do
  grep -q "created:" "$f" 2>/dev/null || echo "MISSING lineage (created:) in $f"
done

echo "=== Validator and arbitrator exist? ==="
ls projects/$ARGUMENTS/.claude/agents/validator.md 2>/dev/null || echo "MISSING validator"
ls projects/$ARGUMENTS/.claude/agents/arbitrator.md 2>/dev/null || echo "MISSING arbitrator"

echo "=== Skills use folder format? ==="
for f in projects/$ARGUMENTS/.claude/skills/*.md; do
  [ -f "$f" ] && echo "FLAT FORMAT (needs migration): $f"
done 2>/dev/null

echo "=== All skills have effort: frontmatter? ==="
find projects/$ARGUMENTS/.claude/skills -name "SKILL.md" 2>/dev/null | while read f; do
  grep -q "effort:" "$f" 2>/dev/null || echo "MISSING effort: in $f"
done

echo "=== All 12 process skills present? ==="
for skill in sprint-proposer autonomous-loop session-end context-recovery validation-orchestrator project-md-updater pendencias-updater config-file-updater rules-agents-updater session-log-creator cross-cutting-analysis commit; do
  ls "projects/$ARGUMENTS/.claude/skills/$skill/SKILL.md" 2>/dev/null || echo "MISSING process skill: $skill"
done

echo "=== Rules files present? ==="
ls "projects/$ARGUMENTS/.claude/rules/session-rules.md" 2>/dev/null || echo "MISSING session-rules.md"
ls "projects/$ARGUMENTS/.claude/rules/evolution-policy.md" 2>/dev/null || echo "MISSING evolution-policy.md"
ls "projects/$ARGUMENTS/.claude/rules/component-design.md" 2>/dev/null || echo "MISSING component-design.md"

echo "=== All 3 process agents present? ==="
for agent in prd-sync-checker criteria-enforcer diff-pattern-extractor; do
  ls "projects/$ARGUMENTS/.claude/agents/$agent.md" 2>/dev/null || echo "MISSING process agent: $agent"
done

echo "=== Known Bug Patterns have efficacy tracking? ==="
grep -c "\[added:" projects/$ARGUMENTS/.claude/agents/code-reviewer.md 2>/dev/null || echo "No efficacy tracking in code-reviewer"

# The DECLARER set and the DECLARED set are BOTH DERIVED, never typed (R-32, T-16): any agent
# carrying a gap declaration IS a declaring component, whatever it is called.
# TWO declaration forms are live and BOTH must be harvested - the blockquote form
# (`> Accessibility gap:`) and the bold form (`ALWAYS DECLARE a **visual regression gap**`).
# Anchoring on the blockquote alone derived ZERO gaps from the validator, so the chain held
# only because code-reviewer duplicated the gap; deleting that row broke it (T-8).
# The blockquote anchor is `^ *>`, NEVER `^>`: a `>` legitimately indented inside a list item is
# a real declaration and a column-0 anchor drops it silently (U-46).
# The specialist side reads the `description:` field ONLY - a whole-file grep false-BREAKS
# on "When spawned" prose, on negations and on historical notes (T-9). THE RANGE TERMINATOR MUST
# ADMIT HYPHENATED YAML KEYS AND THE CLOSING `---`: `^[a-z_]*: ` matches neither, so on the
# CANONICAL frontmatter (`name:`/`description:`/`allowed-tools:`) the range ran to EOF and the
# false-BREAK returned - for exactly the population component-design §1 mandates a
# "When spawned" section on (U-4).
# The domain char class admits DIGITS, DOTS and `&`, and EVERY branch echoes (T-15, U-9).
# NO BRANCH MAY MISREPORT: a description carrying `declares ... gap` whose domain the class could
# not parse is BROKEN and says so. Announcing it as "no gap phrase" asserted a fact the file
# contradicts, under a reassuring `0 broken` (U-9).
# NEGATION-PROVED 2026-09-11: on a fixture with ONE indented `>` declaration and ONE `&` domain,
# the pre-U-4/U-9/U-46 loop printed `none installed` - the T-14 healthy-EMPTY verdict - on a
# fully populated project. This comment is MAINTAINED ON BOTH TWINS (U-30).
# candidate replacement for bootstrap Step 12.5b / EPA Step 5.1
echo "=== Activation chain integrity? ==="
norm() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -- '-_/.' '    ' | tr -s ' ' | sed 's/^ *//;s/ *$//'; }
AG="projects/$ARGUMENTS/.claude/agents"
# FAIL CLOSED WHEN `grep -P` CANNOT RUN (a C/POSIX locale on Git for Windows, or BSD/macOS grep). The
# harvests below discard grep's stderr, so a grep that cannot run read as "no declaring component" and
# printed the healthy `none installed` with exit 0 on a fully populated project (`/audit` 2026-09-19 C-2).
if ! printf 'a
' | grep -qP 'a' 2>/dev/null; then
  echo "RED: this grep cannot run -P (C/POSIX locale, or a grep without PCRE) - the check cannot run"; exit 1
fi
declared=""; declarers=""
for f in "$AG"/*.md; do
  [ -f "$f" ] || continue
  g=$( { grep -oiP '^ *> *\K[A-Za-z][A-Za-z0-9 &./-]{2,30}?(?= gap:)' "$f"; \
         grep -oiP '\*\*\K[A-Za-z][A-Za-z0-9 &./-]{2,30}?(?= gap\*\*)' "$f"; } 2>/dev/null | sort -u)
  [ -z "$g" ] && continue
  declarers="$declarers|$(basename "$f" .md)|"
  while IFS= read -r d; do [ -n "$d" ] && declared="$declared|$(norm "$d")|"; done <<EOF
$g
EOF
done
if [ -z "$declarers" ]; then
  echo "activation chains: none installed - no declaring component in $AG"; exit 0
fi
if [ -z "$declared" ]; then
  echo "RED: declaring components present but no gap parsed - the check cannot run"; exit 1
fi
verified=0; broken=0; info=0
for f in "$AG"/*.md; do
  [ -f "$f" ] || continue
  an=$(basename "$f" .md)
  case "$declarers" in *"|$an|"*) continue ;; esac
  desc=$(sed -n '/^description:/,/^\(---\|[A-Za-z_][A-Za-z0-9_.-]*:\)/p' "$f" | tr '\n\t' '  ' | tr -s ' ' | sed 's/\*\*//g')
  domains=$(printf '%s' "$desc" | grep -oiP 'declares (?:an? |the )?\K[A-Za-z][A-Za-z0-9 &./-]{2,40}?(?= gap)' | sed 's/^ *//;s/ *$//' | sort -u)
  if [ -n "$domains" ]; then
    while IFS= read -r domain; do
      [ -z "$domain" ] && continue
      case "$declared" in
        *"|$(norm "$domain")|"*) verified=$((verified+1)) ;;
        *) echo "BROKEN CHAIN: $an declares '$domain gap' but no declaring component declares it"; broken=$((broken+1)) ;;
      esac
    done <<EOF
$domains
EOF
  elif printf '%s' "$desc" | grep -qiE 'declares .{0,40}gap'; then
    echo "BROKEN CHAIN: $an - description carries a gap phrase the domain pattern could not parse; widen the class"
    broken=$((broken+1))
  elif [ -f "projects/$ARGUMENTS/assets/examples/agents/$an.md" ]; then
    echo "INFO: $an - shipped example, no gap phrase, trigger-activated by design"
    info=$((info+1))
  else
    echo "INFO: $an has no gap phrase and is not a shipped example - verify it is protocol-spawned"
    info=$((info+1))
  fi
done
echo "activation chains: $verified verified, $broken broken, $info info"
```

**ALWAYS REPORT the loop's literal last line — `activation chains: N verified, M broken, I info`,
or `activation chains: none installed - no declaring component in <path>`, or one of the loop's two
`RED: … - the check cannot run` lines, verbatim (a RED run's last line is the RED). NEVER emit nothing.**
(**COPIED FROM the loop verbatim.** It emits THREE counts, so a two-count slot cannot receive it, and
`none installed` is now a real branch rather than a verdict the step could never produce —
`/audit` 2026-09-09 T-13, T-14.) Twin parity with bootstrap Step 12.5b, which mandates the
same line — this command ran the loop and reported nothing (`/audit` 2026-09-04 Q-34).

**Step 5.2 — Produce the adaptation report:**

```
## Adaptation Complete — Framework Upgrade Report

### Framework + project freshness (Steps 0.5 and 1.0) — ALWAYS report, never omit:
- Framework clone — one of Step 0.5's SEVEN verdicts:
- `up to date` · `no remote — skipped` · `behind by N commits — STOPPED` ·
  `behind upstream by N — STOPPED` · `no upstream tracking — UNVERIFIABLE, STOPPED` ·
  `fetch failed — UNVERIFIABLE, STOPPED` · `unverifiable — STOPPED`
- Project copy (Step 1.0's five verdicts, COPIED from its table — Gate 4): `project copy: up to date` /
  `project copy: behind by N commits — STOPPED` (reconciled before analysis) / `no remote — skipped` /
  `project copy: fetch failed — UNVERIFIABLE, STOPPED` / `project copy: unverifiable — STOPPED`

### Risk profile and tier-gated install (Steps 2.9b / 2.9) — ALWAYS report, never omit:
- Risk profile: [prototype | internal-tool | production | production-financial], derived from [signals]
- MACRO skeletons: codebase-audit / metrics.md / skill-gate + skill-reviewer + `.claude/drafts/` /
  framework-audit / framework-metrics.md / ops-rules.md / quality-budgets.md —
  each [`Copied` · `SKIPPED (identical)` · `SKIPPED (present — project data)` · `DIFFERS from framework` → refreshed / kept · not copied (tier)]
  (COPIED FROM the Step 2.9b helpers' verdicts; any `FAILED` line lands in "Copy failures" above)
- [production-financial] red-team-on-money-paths line written into `code-reviewer.md` (Step 2.9b): [yes / N/A — profile]
- CI floor: [created / skipped / deferred — task added]
- `scripts/check-agent-frontmatter.mjs`: [`Copied guard` · `SKIPPED (identical)` · `DIFFERS from framework` → refreshed (`refresh_guard`) / kept]
  (COPIED FROM the Step 2.9 guard fence's verdicts; `already present` was the pre-verdict form)
- `assets/examples/` (Step 4.1): [copied / already present]
- Plugin enablement (Step 4.4): [key merged / none — unavailable]

### Documents upgraded:
- CLAUDE.md: [sections added/modified]
- project.md: [adaptation entry added, sections added]
- pendencias.md: [tasks upgraded with metadata]
- code-reviewer.md: [Known Bug Patterns seeded, sections added]
- security-reviewer.md: [sections added]
- [other agents/skills]: [changes]

### Documents created:
- assets/docs/prd.md (retroactive — [N] sections populated, [N] TBD)
- .claude/logs/ (initialized — session logs start from next session)
- .claude/agents/validator.md (if created)
- .claude/agents/arbitrator.md (if created)
- [any other new files]

### Process skills (Step 2.9): [N `Copied skill` · N `SKIPPED (identical)` · N `DIFFERS from framework` — of 12]
### Existing components that DIFFER from the framework (Steps 2.9 / 2.9b — one owner decision per item, ONE for the coupled set): [name — refreshed / kept, or "none"]
### Continuous-mode coupled set (asked in Step 2.9b): [no member differed (copied fresh / identical) | refreshed as a set | kept as a set]
  (COPIED FROM the verdicts of Steps 2.9 AND 2.9b — `codebase-audit` and `skill-gate` get theirs in
  Step 2.9b — and from its refresh fence: `Refreshed skill` · `Refreshed agent` · `SKIPPED (not installed)` ·
  `FAILED to refresh`. The five lifecycle members are always installed, so `not installed` is never
  the set's value — `/audit` 2026-09-14 X-5; 2026-09-15 V-11.)
- **Session lifecycle:** sprint-proposer, session-end, context-recovery
- **Segment or continuous orchestration (opt-in Level 5):** autonomous-loop
- **Implementation:** validation-orchestrator
- **Session end:** project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator
- **PRD workflows:** cross-cutting-analysis
- **Commit workflow:** commit
- Per skill, the loop's own verdict: `Copied skill` · `SKIPPED (identical)` · `DIFFERS from framework` → refreshed / kept

### Process agents (Step 2.9): [per agent — `Copied agent` · `SKIPPED (identical)` · `DIFFERS from framework` → refreshed / kept]

### Copy failures (Steps 2.9 / 2.9b) — ALWAYS report, never omit:
- `copy failures: none` · `copy failures: N resolved by re-run — [components, or "project name" for a backstop line]`

### Rules:
- .claude/rules/session-rules.md [Copied · SKIPPED (identical) · DIFFERS → refreshed / kept]
- .claude/rules/evolution-policy.md [Copied · SKIPPED (identical) · DIFFERS → refreshed / kept]
- .claude/rules/component-design.md [Copied · SKIPPED (identical) · DIFFERS → refreshed / kept]

### Cross-cutting concerns (Phase 3 → Step 4.1b → Steps 2.2 / 2.3 / 4.6) — ALWAYS report, never omit:
- Identified in Phase 3: [N] — [or `none identified`]
- Routed at Step 4.1b: [N] identified (R → rules, A → decisions, T → tasks)
- Written by Step 4.1b: A/A decisions into `project.md` · T/T tasks into `pendencias.md`
- Received by Step 4.6: R/R code concerns written
- [or `none — retroactive PRD has no Cross-cutting Concerns section`]
- **Any count below Step 4.1b's is RED** — name the dropped concern.
  (Bootstrap's twin has carried "Delivered by receivers" since M-2; EPA's three verdicts were
  mandated with no slot to land in — `/audit` 2026-09-03 N-27.)

### Red Team / Blue Team (Step 2.6 → Step 2.9b Phase-3 re-check) — ALWAYS report, never omit:
- `red/blue team: present — verified` · `red/blue team: created at Step 2.6 — [indicators]` ·
  `red/blue team: created at the Phase-3 re-check — [indicators]` · `red/blue team: not warranted — no indicator in code or PRD`
  (the four verdicts Step 2.6 mandates, COPIED FROM it — `/audit` 2026-09-16 A-8.)

### Risk profile re-check (Step 2.9b → Phase 3) — ALWAYS report, never omit:
- `risk profile: confirmed unchanged`
- `risk profile: revised [old] → [new] — N tier-gated artifacts [copied | already present]`
  (BOTH verdicts the Phase-3 re-check can produce, and ONLY those two — COPIED FROM the mandating
  step, never re-derived (Gate 4). Step 2.9b resolves the profile in Phase 2 from the codebase
  alone, because the retroactive PRD its fallback named does not exist until Phase 3 —
  `/audit` 2026-09-10 U-18.)

### Activation chains (Step 5.1) — ALWAYS report, never omit:
- `activation chains: N verified, M broken, I info`
- `activation chains: none installed - no declaring component in <path>`
- `RED: this grep cannot run -P (C/POSIX locale, or a grep without PCRE) - the check cannot run`
- `RED: declaring components present but no gap parsed - the check cannot run`
  (the FOUR verdicts the loop can emit, and ONLY those four — **COPIED FROM the loop's own `echo`
  lines, never re-derived** (Gate 4). The two RED lines had no slot — one of them added by
  `/audit` 2026-09-19 C-2 — so a RED run had nowhere to land. The loop emits THREE counts and this slot offered two, so a
  compliant discharge had nowhere to land; the `none installed` verdict carries the path. The
  MANDATE was corrected on both twins and the SLOT was not — `/audit` 2026-09-10 U-5, U-13.)

### PRD line (Step 2.1) — ALWAYS report, never omit:
- `written, bracket removed` · `already present, untouched`

### `done_tasks.md` (Step 2.3) — ALWAYS report, never omit:
- `created` · `already present`
  (`pendencias-updater` moves completed tasks there; without it the task lifecycle breaks
  silently. Bootstrap's twin has carried this slot all along — `/audit` 2026-09-03 P-17.)

### Deferred domain rules (Step 2.7.1 → Step 4.6) — ALWAYS report, never omit:
- `N/N created` · `none — Step 2.7.1 deferred nothing`
- **A mismatch with Step 2.7.1's deferred count is RED** (`/audit` 2026-09-03 N-22).

### Domain rules pre-created (from example templates — Step 2.7.1/4.6):
- .claude/rules/[domain]-rules.md ← seeded, refined by rules-agents-updater
- [list each, or "none — no domain signals matched example templates"]

### Specialist agents pre-installed (from example templates — Step 4.6.5):
- .claude/agents/[specialist].md ← activation chain verified
- [list each, or "none — no gap declarations without existing specialists"]

### Preserved (not modified):
- [N] rows in Progress Log index
- [N] rules files: [names]
- [N] existing Known Bug Patterns
- All existing git history

### PRD sections needing user input:
- [ ] 1.3 Target Audience
- [ ] 1.4 Competitive Differentiator
- [ ] 7. Business Model
- [ ] [other TBD sections]

### MCPs (Step 4.3) — ALWAYS report, never omit:
- `MCP: N installed [names]` · `MCP: none installed — placeholder replaced`
  (the second verdict was missing; the enumeration is COPIED FROM the mandating step,
  never re-derived — `/audit` 2026-09-03 P-21)
### Skills: [list with status]
### Hooks (Step 4.2) — ALWAYS report, never omit:
- `configured — [the hooks written]` · `configured — skill-gate hook only (project has no formatter)`
(**COPIED FROM the hooks step's mandate verbatim**, and byte-equivalent to the bootstrap twin's
slot. The banned three-verdict form lived here for two batches after being deleted from the twin —
`/audit` 2026-09-04 R-13, written back `applied` with nothing landed; re-filed 2026-09-09 T-10.)

### Non-standard naming:
- [e.g., `[nome-fora-do-padrao].md` — reference updated in CLAUDE.md]

### PRD version: v1.0.0 (retroactive)

### Next session should:
- Review TBD sections in PRD
- [first item from pendencias]
```
