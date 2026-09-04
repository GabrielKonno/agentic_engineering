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
git fetch && git status -sb | head -1                # (c) ahead/behind
```

**Classify into exactly one of the SEVEN outcomes below — the table is exhaustive and its last row is the CATCH-ALL — the check FAILS CLOSED, never open:**

| Observation | Verdict |
|-------------|---------|
| (a) empty — no remote configured at all | `no remote — skipped`. Nothing to be behind; CONTINUE. |
| (a) lists an `upstream` remote (this clone is a FORK) | Compare against **`upstream`**, never `origin`: `git fetch upstream && git rev-list --count HEAD..upstream/main` → **0 = `up to date`; anything else = RED, `behind upstream by N — STOPPED`**. On a fork `@{upstream}` points at the FORK's own `origin`, so the rows below would read GREEN while the clone is arbitrarily behind the real upstream. |
| (b) empty or errors — branch tracks nothing (or detached HEAD) | **RED — STOP.** `no upstream tracking — UNVERIFIABLE, STOPPED`. |
| (c) produced NO line — `git fetch` failed, so `&&` short-circuited | **RED — STOP.** `fetch failed — UNVERIFIABLE, STOPPED`. Re-run the two commands separately to see the error. |
| (c) branch line contains `behind` | **RED — STOP.** `behind by N commits — STOPPED`. |
| (c) branch line shows a `...` tracking segment and no `behind` | `up to date`. CONTINUE. |
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
git -C projects/$ARGUMENTS remote -v            # has a remote?
git -C projects/$ARGUMENTS fetch origin
git -C projects/$ARGUMENTS status -sb           # ahead/behind?
```

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
- Project-copy freshness (Step 1.0): `up to date` / `behind by N — reconciled before analysis` /
  `no remote — skipped` — ALWAYS report; the verdict had no slot anywhere (`/audit` M-53)
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

**When Step 2.1 or Step 4.8 writes the `**PRD:**` line from
`docs/modules/templates/claude_md.md`, ALWAYS DELETE the template's
`[or, when bootstrapped WITHOUT …]` bracket annotation** — it is authoring guidance, not project
content, and bootstrap's twin has carried this mandate all along while this command had none, so
an adapted project could ship the annotation verbatim (`/audit` 2026-09-03 P-21).
**ALWAYS REPORT — `PRD line: written, bracket removed` or `PRD line: already present, untouched`.**

**Step 2.1 — Upgrade CLAUDE.md:**

Compare the existing config file against this checklist. Add any missing section:

```
Required sections (compare against docs/modules/templates/claude_md.md — v2.17.0 slim orchestrator):
□ Project Overview (name, state, PRD reference, pending tasks reference, session logs)
□ Session Protocol (pointers to /sprint-proposer, /session-end, /context-recovery, session-rules.md)
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
**Steps 1.1, 1.5, 2.2, 2.9b, 4.1b and 5.2 read or write it**, and this command's own Reading Report has an
`[exists/missing]` slot for it (`/audit` 2026-09-02 K-11; consumers corrected twice — `N-24` removed a
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
```

**Do NOT modify existing Progress Log entries.** Add missing sections at the appropriate location.

If the Progress Log uses the old format (full session entry blocks), convert it to an index table during this adaptation. Extract session number, date, and 1-line summary from each block. Use `—` for the Log column (no log files exist for old sessions). Preserve old entries below the table as a legacy block.

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
**Steps 2.2, 2.3, 2.9b, 4.1b, 4.6, 4.6.5 and 5.2 read or write it**, and this command's own Reading
Report has an `[exists/missing]` slot for it (`/audit` 2026-09-02 K-11; consumers corrected
2026-09-03 N-24 — Step 5.1 does not read this file).

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
□ Dependency mapping (depends:/parallel:) is optional but noted
□ Evolution classification (FIX/DERIVED/CAPTURED) noted for items that originated from bug fixes or pattern captures during codebase analysis
```

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

If they don't exist: assess the PRD (once created in Phase 3) for risk indicators. If the project has auth, payments, multi-tenancy, AI/LLM, or PII → create them. Read templates at `docs/modules/agents/red_team.md` and `docs/modules/agents/blue_team.md`. Adapt with stack-specific attack vectors.

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

Based on the codebase analysis from Step 1 and the existing/retroactive PRD, identify domain signals that match example templates. For each domain that is a core feature or architectural pattern in the project, check if the corresponding rules file ALREADY EXISTS in `.claude/rules/`. If it does NOT exist and a matching example template is available in `assets/examples/rules/`, pre-create it:

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

Read each skill. Verify frontmatter has `effort:` field. Add if missing (most skills are `effort: medium`; security-related are `effort: high`). For review/validation/security skills, verify `invocation: subagent` and `receives:`/`produces:` fields. For knowledge/reference skills, verify `invocation: inline`.

**Verify lineage fields** on all agents/skills: `created:`, `last_eval:` (subagent only), `fixes:`, `derived_from:`. Add if missing — set `created:` to the adaptation session, `last_eval: none (pre-framework)`, `fixes: []`, `derived_from: null`.

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

The v2.17.0 CLAUDE.md references process skills and rules via pointers. Without these, every pointer is a broken reference.

**Copy process skills (12 lifecycle — ALWAYS copied, to `.claude/skills/`):**
```bash
for skill_dir in ./docs/modules/skills/*/; do
  skill_name=$(basename "$skill_dir")
  case "$skill_name" in codebase-audit|framework-audit|skill-gate) continue ;; esac  # tier-gated — copied in Step 2.9b
  if [ ! -d "projects/$ARGUMENTS/.claude/skills/$skill_name" ]; then
    cp -r "$skill_dir" "projects/$ARGUMENTS/.claude/skills/$skill_name"
    echo "Copied skill: $skill_name"
  else
    echo "SKIPPED (already exists): $skill_name — verify manually against framework version"
  fi
done
```

**Copy process agents (3 subagents — to `.claude/agents/`):**
```bash
for agent in prd_sync_checker criteria_enforcer diff_pattern_extractor; do
  dest_name=$(echo "$agent" | tr '_' '-')
  if [ ! -f "projects/$ARGUMENTS/.claude/agents/$dest_name.md" ]; then
    cp "docs/modules/agents/${agent}.md" "projects/$ARGUMENTS/.claude/agents/$dest_name.md"
    echo "Copied agent: $dest_name"
  else
    echo "SKIPPED (already exists): $dest_name.md — verify manually"
  fi
done
```

**Copy rules files (to `.claude/rules/`):**
```bash
mkdir -p projects/$ARGUMENTS/.claude/rules
for tmpl in session_rules evolution_policy component_design; do
  target=$(echo "$tmpl" | tr '_' '-')
  if [ ! -f "projects/$ARGUMENTS/.claude/rules/${target}.md" ]; then
    sed -n '/^````markdown$/,/^````$/p' "docs/modules/rules/${tmpl}.md" | sed '1d;$d' > "projects/$ARGUMENTS/.claude/rules/${target}.md"
    echo "Copied ${target}.md"
  else
    echo "SKIPPED (already exists): ${target}.md — verify manually"
  fi
done
```

**Copy the component-registry liveness guard (all tiers — to `scripts/`):**
```bash
mkdir -p projects/$ARGUMENTS/scripts
if [ ! -f "projects/$ARGUMENTS/scripts/check-agent-frontmatter.mjs" ]; then
  sed -n '/^````js$/,/^````$/p' docs/modules/templates/check_agent_frontmatter.md | sed '1d;$d' > "projects/$ARGUMENTS/scripts/check-agent-frontmatter.mjs"
  echo "Copied guard: scripts/check-agent-frontmatter.mjs"
else
  echo "SKIPPED (already exists): check-agent-frontmatter.mjs — verify manually against framework version"
fi
```

An invalid YAML frontmatter makes a component silently VANISH from the registry
(FRAMEWORK-AGENT-YAML-01 — see component-design.md §8); this guard fails loud instead. If the
project has a `package.json`, register `"check:agents": "node scripts/check-agent-frontmatter.mjs"`;
if it has a CI pipeline, add a `guards` stage running it (dependency-free, no install needed).
Then RUN it once now — an adapted project may already carry a broken frontmatter.

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
   from the codebase + retroactive PRD (money/PII/multi-tenant → `production-financial`; public app
   with auth/data → `production`; internal/admin → `internal-tool`; throwaway → `prototype`) and
   **confirm with the owner** (ASK). Record it in `project.md` Overview and CLAUDE.md.

2. **Copy what the profile warrants** (uncopied = inactive ceremony; the cheap core clauses arrive
   automatically via the updated session-rules/evolution-policy/criteria-enforcer copied above):

```bash
PROFILE="[chosen]"   # prototype | internal-tool | production | production-financial
PROJ="projects/$ARGUMENTS"
# EPA targets projects that may have NO framework structure — the metrics redirects below
# fail silently without this. (bootstrap has the same guard at its Step 5.8.)
mkdir -p "$PROJ/.claude/phases"
case "$PROFILE" in
  internal-tool|production|production-financial)
    [ ! -d "$PROJ/.claude/skills/codebase-audit" ] && cp -r docs/modules/skills/codebase-audit "$PROJ/.claude/skills/"
    [ ! -f "$PROJ/.claude/phases/metrics.md" ] && sed -n '/^````markdown$/,/^````$/p' docs/modules/templates/metrics_md.md | sed '1d;$d' > "$PROJ/.claude/phases/metrics.md"
    [ ! -d "$PROJ/.claude/skills/skill-gate" ] && cp -r docs/modules/skills/skill-gate "$PROJ/.claude/skills/"
    [ ! -f "$PROJ/.claude/agents/skill-reviewer.md" ] && cp docs/modules/agents/skill_reviewer.md "$PROJ/.claude/agents/skill-reviewer.md"
    mkdir -p "$PROJ/.claude/drafts/skills" "$PROJ/.claude/drafts/rules" "$PROJ/.claude/skill-gate/review_reports"
    ;;
esac
case "$PROFILE" in
  production|production-financial)
    [ ! -d "$PROJ/.claude/skills/framework-audit" ] && cp -r docs/modules/skills/framework-audit "$PROJ/.claude/skills/"
    [ ! -f "$PROJ/.claude/phases/framework-metrics.md" ] && sed -n '/^````markdown$/,/^````$/p' docs/modules/templates/framework_metrics_md.md | sed '1d;$d' > "$PROJ/.claude/phases/framework-metrics.md"
    [ ! -f "$PROJ/.claude/rules/ops-rules.md" ] && sed -n '/^````markdown$/,/^````$/p' docs/modules/rules/ops_rules.md | sed '1d;$d' > "$PROJ/.claude/rules/ops-rules.md"
    [ ! -f "$PROJ/.claude/rules/quality-budgets.md" ] && sed -n '/^````markdown$/,/^````$/p' docs/modules/rules/quality_budgets.md | sed '1d;$d' > "$PROJ/.claude/rules/quality-budgets.md"
    ;;
esac
```

3. **CI floor (internal-tool+):** if the project has no CI workflow, create one (install → lint →
   build → test) or register a task to add it. **prototype:** skip all of the above.
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

**After creating the PRD:** update CLAUDE.md to reference it (`**PRD:** See assets/docs/prd.md`).

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

**Note:** The smart-formatting hook requires Prettier. If the project doesn't use Prettier, create settings.json with only the `permissions` block and skip the hook — but KEEP the skill-gate hook entry (it has no dependencies). If settings.json already existed, merge the skill-gate hook entry into its `PostToolUse` array — without it, the gate installed in Step 2.9b is never enforced (it remains a harmless no-op on tiers where skill-gate was not copied).

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

Read the project's `.claude/agents/code-reviewer.md` and `.claude/agents/security-reviewer.md`. Identify which Coverage Gap Declaration sections are present. For each gap declaration, check if a matching specialist agent ALREADY EXISTS in `.claude/agents/`. If it does NOT exist and a matching example is available in `assets/examples/agents/`, pre-install it:

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

After installation, validate activation chains for every pre-installed specialist:
1. Verify it has a matching Coverage Gap Declaration in the declaring component whose domain vocabulary echoes the agent's Pushy Description
2. Run a vocabulary alignment check: `grep "[domain keyword]" .claude/agents/code-reviewer.md .claude/agents/security-reviewer.md .claude/agents/validator.md`

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

echo "=== Activation chain integrity? ==="
# For each specialist agent (not process/core agents), verify a declaring component declares a matching gap
for f in projects/$ARGUMENTS/.claude/agents/*.md; do
  agent_name=$(basename "$f" .md)
  # Skip process agents and core agents (they are gap sources or protocol-spawned, not gap targets)
  case "$agent_name" in
    code-reviewer|security-reviewer|validator|arbitrator|criteria-enforcer|prd-sync-checker|diff-pattern-extractor|red-team|blue-team) continue ;;
  esac
  # Extract domain from Pushy Description ("when [declaring component] declares a [domain] gap")
  # `an?` and a NON-GREEDY `.+?`: domains are multi-word ("visual regression",
  # "infrastructure security") and half take "an". A `\S+` after a literal "declares a "
  # extracted 3 of the 10 real phrases and reported the other 7 as broken chains
  # (`/audit` 2026-09-03 P-10).
  domain=$(grep -oP 'declares an? \K.+?(?= gap)' "$f" 2>/dev/null | head -1)
  if [ -n "$domain" ]; then
    found=0
    # ALL THREE declaring components — `validator` declares the visual-regression gap from
    # inside its own Validation Report (component-design §1). Grepping only the two reviewers
    # made a validator-only declaration read as a broken chain (`/audit` 2026-09-03 P-9).
    for dc in code-reviewer security-reviewer validator; do
      grep -qi "$domain gap" "projects/$ARGUMENTS/.claude/agents/$dc.md" 2>/dev/null && found=1
    done
    [ "$found" -eq 0 ] && echo "BROKEN CHAIN: $agent_name declares '$domain gap' but no declaring component has a matching gap declaration"
  else
    echo "WARNING: $agent_name has no Pushy Description gap phrase — may be unreachable via gap-declaration activation"
  fi
done
```

**Step 5.2 — Produce the adaptation report:**

```
## Adaptation Complete — Framework Upgrade Report

### Framework + project freshness (Steps 0.5 and 1.0) — ALWAYS report, never omit:
- Framework clone — one of Step 0.5's SEVEN verdicts:
- `up to date` · `no remote — skipped` · `behind by N commits — STOPPED` ·
  `behind upstream by N — STOPPED` · `no upstream tracking — UNVERIFIABLE, STOPPED` ·
  `fetch failed — UNVERIFIABLE, STOPPED` · `unverifiable — STOPPED`
- Project copy: `up to date` / `behind by N — reconciled before analysis` / `no remote — skipped`

### Risk profile and tier-gated install (Steps 2.9b / 2.9) — ALWAYS report, never omit:
- Risk profile: [prototype | internal-tool | production | production-financial], derived from [signals]
- MACRO skeletons: codebase-audit / metrics.md / skill-gate + skill-reviewer + `.claude/drafts/` /
  framework-audit / framework-metrics.md / ops-rules.md / quality-budgets.md —
  [copied (tier) / skipped (tier)] each
- CI floor: [created / skipped / deferred — task added]
- `scripts/check-agent-frontmatter.mjs`: [copied / already present]
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

### Process skills: [N of 12 copied from framework]
- **Session lifecycle:** sprint-proposer, session-end, context-recovery
- **Whole-segment orchestration (opt-in Level 5):** autonomous-loop
- **Implementation:** validation-orchestrator
- **Session end:** project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator
- **PRD workflows:** cross-cutting-analysis
- **Commit workflow:** commit
- [list copied / list skipped (already existed)]

### Rules:
- .claude/rules/session-rules.md [CREATED / SKIPPED]
- .claude/rules/evolution-policy.md [CREATED / SKIPPED]
- .claude/rules/component-design.md [CREATED / SKIPPED]

### Cross-cutting concerns (Phase 3 → Step 4.1b → Steps 2.2 / 2.3 / 4.6) — ALWAYS report, never omit:
- Identified in Phase 3: [N] — [or `none identified`]
- Routed at Step 4.1b: [N] identified (R → rules, A → decisions, T → tasks)
- Written by Step 4.1b: A/A decisions into `project.md` · T/T tasks into `pendencias.md`
- Received by Step 4.6: R/R code concerns written
- [or `none — retroactive PRD has no Cross-cutting Concerns section`]
- **Any count below Step 4.1b's is RED** — name the dropped concern.
  (Bootstrap's twin has carried "Delivered by receivers" since M-2; EPA's three verdicts were
  mandated with no slot to land in — `/audit` 2026-09-03 N-27.)

### PRD line (Steps 2.1 / 4.8) — ALWAYS report, never omit:
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

### MCPs: [list with status] · `none installed — placeholder replaced`
  (the second verdict was missing; the enumeration is COPIED FROM the mandating step,
  never re-derived — `/audit` 2026-09-03 P-21)
### Skills: [list with status]
### Hooks: smart-formatting [ACTIVE / SKIPPED: no formatter detected / none — project has no formatter]

### Non-standard naming:
- [e.g., `[nome-fora-do-padrao].md` — reference updated in CLAUDE.md]

### PRD version: v1.0.0 (retroactive)

### Next session should:
- Review TBD sections in PRD
- [first item from pendencias]
```
