# Bootstrap Session

This is a **bootstrap session** (Session 0) for project **$ARGUMENTS**.

**Project path:** `projects/$ARGUMENTS/`
**PRD path:** `projects/$ARGUMENTS/assets/docs/prd.md`

## Authorized Operations

- Create all project files inside `projects/$ARGUMENTS/`
- Install MCPs and plugins for the project
- Copy examples and skills from the framework into the project
- Run `git init`, `git add`, and `git commit` **inside** `projects/$ARGUMENTS/` (the project's own repo — never the framework repo)
- No files outside `projects/$ARGUMENTS/` should be created or modified

## Rules

- All documents (CLAUDE.md, project.md, pendencias.md, code-reviewer.md, PRD) are written in English for consistency
- Conversational output (reports, questions, summaries) should be in Brazilian Portuguese
- Never modify files in `docs/` or `examples/` (framework read-only references)
- No application code will be written — only documentation and configuration

## Setup

Before starting the process:

1. If `projects/$ARGUMENTS/` does not exist, create it and `projects/$ARGUMENTS/assets/docs/`
2. If `projects/$ARGUMENTS/.git/` does not exist, ALWAYS run `git init` inside `projects/$ARGUMENTS/` **before creating any other file**. This gives the project its own git identity from the first file onward. Without this early `git init`, any IDE opened on the project folder during bootstrap walks up the directory tree, attaches to the framework's `.git/`, and displays the framework's commit history as if it belonged to the project — a confusing (though harmless) artifact of git's walk-up behavior.
3. If `projects/$ARGUMENTS/assets/docs/prd.md` does not exist, the session still works — PRD-derived sections will be marked "to be defined"

Execute in order. Report results after each part.

---

## Process

### Step 0.5 — Framework-clone freshness check (MANDATORY, before any copy)

**ALWAYS RUN before Step 1.5 copies anything out of this repo:**

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

On any RED, **STOP and tell the owner** — a stale clone silently stamps an OLD contract into a new
project under a version label (`framework-vX.Y.Z`) the project will then trust, and
`/existing_project_adaptation` later keys migration decisions to that same label. Update or attach
the upstream first (`git pull`, `git fetch upstream && git merge upstream/main` on a fork, or
`git branch --set-upstream-to=origin/main`), then restart.

**ALWAYS REPORT one of the SEVEN verdict strings above — `up to date` / `behind by N commits —
STOPPED` / `no upstream tracking — UNVERIFIABLE, STOPPED` / `no remote — skipped` / `fetch failed — UNVERIFIABLE,
STOPPED` / `behind upstream by N — STOPPED` / `unverifiable — STOPPED`. NEVER emit nothing.** This is the symmetric twin of `existing_project_adaptation.md` Step 0.5, which runs the
same check there, and of its Step 1.0, which checks the PROJECT copy.

---

### Step 1 — Read the PRD

If `projects/$ARGUMENTS/assets/docs/prd.md` exists, read it completely. Extract:
- Product name and description
- Target audience
- MVP modules/features with priorities
- Features out of scope
- Stack (or "to be defined")
- Constraints (deadline, compliance, platform)
- Business rules per module
- External integrations
- Business model

If `projects/$ARGUMENTS/assets/docs/prd.md` does not exist, skip this step. Record that there is no PRD; **Step 2 selects the `**PRD:**` line accordingly.** Use information from the user or CLAUDE.md to populate documents. Mark unknown sections as "to be defined".

---

### Step 1.1 — Read the PRD's Cross-cutting Concerns

**ALWAYS READ the PRD's `Cross-cutting Concerns` section when present** (written by
`/prd_planning` Phase 4, maintained by `/prd_change` Phase 3). It names the themes that span
multiple PRD sections and must stay consistent when any of them changes — the highest-value
context the PRD carries and the only section no bootstrap step used to read.

None of the receiving artifacts exist yet at this point in the run, so this step does NOT write
them. **ALWAYS BUILD the routing list here and CARRY IT FORWARD** — each destination step below
is the RECEIVER that writes it, and each says so in its own text.

**ALWAYS CLASSIFY each concern to the artifact that owns it:**

| Concern constrains… | Destination artifact | Written by |
|---|---|---|
| CODE | a `.claude/rules/` domain rules file (Step 13's signal table is the first place to look for a matching example) | **Step 13 — RECEIVER** |
| ARCHITECTURE | a row in `project.md`'s Architectural Decisions table | **Step 3 — RECEIVER** |
| WORK still to do | a task in `pendencias.md` | **Step 4 — RECEIVER** |

**ALWAYS REPORT the LIST, not a completed routing — `cross-cutting: N concerns classified
(R → rules/Step 13, A → decisions/Step 3, T → tasks/Step 4)` or `cross-cutting: none — PRD has
no such section`. NEVER emit nothing.** Step 15 re-reports the same counts as DELIVERED, which is
the line that proves each receiver consumed its share. A concern that reaches no artifact is a
concern the project will rediscover as a bug.

---

### Step 1.2 — Determine risk profile (the ceremony keystone)

The risk profile scales how much process ceremony this project receives. It is the single
knob that keeps the framework from imposing financial-grade rigor on a throwaway prototype.
**Every later step that creates an optional skeleton (CI floor, codebase-audit, ops-rules,
quality-budgets, metrics, framework-audit, deploy gates) checks this profile.**

**1.2a — Derive a default from PRD signals:**

| PRD signals | Default profile |
|-------------|-----------------|
| Throwaway/demo/POC, no real users, no persistence | `prototype` |
| Internal/admin tool, trusted users, no public exposure | `internal-tool` |
| Public-facing app with real users, auth, or persisted data | `production` |
| Money movement, PII/health/financial data, multi-tenant isolation, compliance (LGPD/GDPR/PCI) | `production-financial` |

**1.2b — Confirm with the user.** Present the derived default and ask the user to confirm or
override (ASK — this decision governs the whole bootstrap). If no PRD exists, ask directly.

**1.2c — Record it.** Write `**Risk profile:** [chosen]` into `project.md` Overview (Step 3) and
CLAUDE.md (Step 2). The ceremony matrix lives in `session-rules.md` (copied Step 5.7).

**RECEIVER MANDATE — Steps 2 and 3 ALWAYS confirm receipt, and this hand-off is not complete
until they do.** Step 1.1's three hand-offs each carry one and this one did not; it survived only
because both templates happen to ship the line as a bracketed placeholder, so a silent drop is
indistinguishable from a correct write (`/audit` 2026-09-10 U-28). Mechanical, expected result
stated, run after Step 3:
```bash
# ANCHOR ON THE TIER WORD, NEVER ON END-OF-LINE: both templates ship a trailing "— governs ..."
# clause, so a `$`-anchored form returns 0 on a CORRECTLY resolved line - the K-8/L-7 inversion.
grep -c '^\*\*Risk profile:\*\* \(prototype\|internal-tool\|production\|production-financial\)'   projects/$ARGUMENTS/project.md projects/$ARGUMENTS/CLAUDE.md
```
**Expected: `1` for BOTH files.** A `0` means the placeholder was never replaced — RED, and every
tier-gated copy downstream is running off an unresolved profile.

**Ceremony by tier (the matrix later steps obey):**

| Skeleton / ceremony | prototype | internal-tool | production | production-financial |
|---------------------|:---------:|:-------------:|:----------:|:--------------------:|
| Core: per-diff review, criteria-enforcer, KBP loop, session archetypes, per-incident post-mortem, class-checklist | ✅ | ✅ | ✅ | ✅ |
| CI floor at t=0 (Step 14) | — | ✅ | ✅ | ✅ |
| metrics.md (Step 5.8) + back-sweep + debt-aging + Post-Mortem ledger | — | ✅ | ✅ | ✅ |
| codebase-audit skill (Step 5.8) | — | ✅ sparse | ✅ | ✅ |
| skill-gate + skill-reviewer (Step 5.8) | — | ✅ | ✅ | ✅ |
| ops-rules + quality-budgets + delta gate + deploy gates (Step 5.8) | — | — | ✅ | ✅ |
| framework-audit skill (Step 5.8) | — | — | ✅ sparse | ✅ frequent |
| Data reconciliation + red-team mandatory on money-paths | — | — | — | ✅ |

> A skeleton that the tier does NOT warrant is simply not copied — its absence is what
> deactivates the ceremony (no runtime tier check needed). This mirrors how Rules-Driven
> Checks activate only when their rules file exists.

---

### Step 1.5 — Copy examples to project

Copy the framework's examples directory into the project for future reference:

```bash
cp -r examples/ projects/$ARGUMENTS/assets/examples/
```

These examples serve as quality reference for creating agents, skills, and rules — both during this bootstrap AND during on-demand creation in future sessions. They are read-only templates, not active configuration.

---

### Step 2 — Create CLAUDE.md

**ALWAYS SELECT the `**PRD:**` line for the case at hand — this step OWNS it, because this is where
CLAUDE.md comes into existence** (`/audit` 2026-09-02 M-6: the instruction previously sat in Step 1,
before there was anything to rewrite):
- PRD present → keep `See assets/docs/prd.md` and **DELETE the `[or, when bootstrapped WITHOUT…]`
  bracket** the template carries. Leaving it ships the annotation verbatim.
- No PRD → replace the whole line with the no-PRD variant.
**ALWAYS REPORT — `PRD pointer: assets/docs/prd.md` or `PRD pointer: none — bootstrapped without a
PRD`. NEVER emit nothing.**

**All files from Step 2 onwards are created inside `projects/$ARGUMENTS/`.** Paths in this prompt (e.g., `CLAUDE.md`, `.claude/phases/`) are relative to the project root. Exception: shell command blocks (cp/mkdir/sed) run from the FRAMEWORK root — their targets keep the explicit `projects/$ARGUMENTS/` prefix because their sources (`docs/modules/...`, `examples/`) are framework-relative.

**If CLAUDE.md already exists:** Do NOT overwrite. Instead, compare the existing content with the template. Add missing sections and update outdated sections. Report what was added/changed.

**If CLAUDE.md does not exist:** Read the template at `docs/modules/templates/claude_md.md`. Adapt with PRD data:
- Fill Project Overview from PRD (name, description, modules, owner)
- Fill Architecture from PRD section 5
- Fill Key Patterns based on the stack
- Fill Build Order from PRD module dependencies
- Fill Design System reference from PRD section 6 (Design and UX)
- Fill Environment Variables from stack requirements
- Fill **Commands** from the PRD stack now (build / lint / test / dev). Step 14.2 READS this
  section to generate the CI pipeline, and no later step fills it — leaving it empty produces a CI
  floor with no commands.
- Leave MCP Servers (Step 5), Skills & Agents (Step 6), and Hooks (Step 14) empty — those steps
  fill them and each says so explicitly.

Create the file at the project root as `CLAUDE.md`.

**The template is a slim orchestrator** (~90 lines). It contains project identity and pointers to skills/rules. Protocol logic lives in process skills (copied in Step 5.7) and session rules (also copied in Step 5.7).

---

### Step 3 — Create project.md

**If `.claude/phases/project.md` already exists:** Do NOT overwrite. Add a new index row to the Progress Log table for this migration/bootstrap session. Verify it has the required sections (Architectural Decisions, Module Relationships, Progress Log index table). Add missing sections.

**If it does not exist:** Read the template at `docs/modules/templates/project_md.md`. Adapt with PRD data:
- Fill Overview from PRD sections 1.1, 1.2, 1.3 (including `**PRD version:** [READ the latest version from the PRD's Changelog table — do NOT assume v1.0.0; a PRD revised via `/prd_change` before bootstrap carries a higher version, and this field is what prd-sync-checker compares against]`)
- Fill Architectural Decisions table with stack decisions from PRD
- Fill Module Relationships with dependencies from PRD
- Fill Project Phases from Build Order
- **For each phase, ALWAYS include a Module Breakdown** — for every module in the phase, include: 1-line objective, key features with concrete details (component names, data values, IDs), key business rules that affect implementation, and integration points with other modules. This is what makes project.md useful as a session entry point without re-reading the full PRD every time.
- Add Session 0 row to Progress Log index table: `| 0 (Bootstrap) | [date] | PRD analyzed, docs + agents created, stack confirmed | — |`
Create at `.claude/phases/project.md`.

**This step is the RECEIVER of Step 1.1's ARCHITECTURE concerns — on BOTH branches above.**
ALWAYS add one Architectural Decisions row per cross-cutting concern Step 1.1 classified as
architectural, naming the concern and the sections it spans. This applies whether `project.md` was
just created OR already existed: a pre-existing file is exactly the case where the concerns have
never been recorded. **REPORT `cross-cutting received: A/A architecture concerns written` — a
mismatch with Step 1.1's count is RED.**

---

### Step 4 — Create pendencias.md and done_tasks.md

**If `.claude/phases/pendencias.md` already exists:** Do NOT overwrite. Verify existing items have acceptance criteria tags. Add tags to items missing them. Add any new items from the PRD that are not yet tracked.

**If it does not exist:** Read the template at `docs/modules/templates/pendencias_md.md`. Adapt with PRD data:
- Fill tasks from Build Order with full Context/State/Constraints/Complexity/Criteria
- Ensure every task has acceptance criteria with `BUILD:`/`VERIFY:`/`QUERY:`/`REVIEW:`/`MANUAL:` tags
- Criteria quality standard: every criterion must have 3 parts (action, expected result, failure signal)
- Consult PRD section 4 (NFRs) when writing criteria: performance, security, and compliance NFRs become `VERIFY:`/`REVIEW:` criteria on the tasks they constrain
- Seed "Future Improvements" with watch-items from PRD section 9 (Risks and Dependencies), stamped `[added s0]` — risks tracked nowhere are risks forgotten
Create at `.claude/phases/pendencias.md`.

**This step is the RECEIVER of Step 1.1's WORK concerns — on BOTH branches above.** ALWAYS create
one task per cross-cutting concern Step 1.1 classified as work, with full acceptance criteria like
any other task. This applies whether `pendencias.md` was just created OR already existed.
**REPORT `cross-cutting received: T/T work concerns written` — a mismatch with Step 1.1's count
is RED.**

**ALWAYS create `.claude/phases/done_tasks.md`** if it does not exist. This file is the destination for completed tasks — the `pendencias-updater` skill moves tasks here at end of each session. Without it, the task lifecycle breaks silently.

```markdown
# [Project] — Completed Tasks

> Tasks moved here from `pendencias.md` by the `pendencias-updater` skill at end of each session.
> Full metadata preserved for dependency tracking and audit trail.

---

## Done

- [x] PRD created and approved
- [x] Session 0: bootstrap and configuration ([date])
```

---

### Step 5 — Discover and install MCPs

**5a. Install browser automation (default for every project):**
```bash
npx @anthropic-ai/claude-code mcp add playwright -- npx -y @anthropic-ai/mcp-server-playwright
```

**5b. Search for available MCPs:**

**Source 1 — npm registry (preferred, most secure):**
```bash
npm search @modelcontextprotocol/server 2>/dev/null | head -20
npm search mcp-server 2>/dev/null | head -20
```

**Source 2 — claude-code-templates CLI:**
```bash
npx claude-code-templates@latest --list-mcps 2>/dev/null || echo "CLI not available"
```

**Source 3 — Web search via Playwright (complementary):**
Use ONLY if sources 1 and 2 returned no result.

**5c. Decide which to install** based on the project stack:

| Stack includes | Recommended MCP | When to install |
|---------------|----------------|-----------------|
| Supabase | supabase MCP | If Supabase project exists |
| PostgreSQL (not Supabase) | postgres MCP | If database exists |
| GitHub repo | github MCP | If repo exists |
| React/Next.js/Vue with libs | context7 MCP | Yes |
| Other service | Search in sources 1-3 | Assess need + security |

**5d. Security validation (MANDATORY before installing any MCP):**

```
□ Trusted source? (official org, verified publisher, >10k downloads)
□ Actively maintained? (published within last 6 months)
□ Reasonable permissions? (read-only by default)
□ Open source? (public repo with auditable code)
□ Actually relevant? (solves concrete problem for this stack)
```

If any fails: do not install, log reason. If uncertain: ASK user.

**Rules:** Max 5 MCPs on day 1. Only install if resource exists.

**ALWAYS REPLACE the `[Filled in Step 5 below]` placeholder in CLAUDE.md's "MCP Servers" section
before this step ends — with the installed servers, or with the literal line `None installed.`**
NEVER leave the placeholder in a shipped CLAUDE.md: a project whose config still reads "filled in
Step 5 below" references a bootstrap step that does not exist inside the project, and the AI
reading it has no way to tell "none installed" from "this step never ran". Same rule, same reason
as Step 14's Hooks placeholder. **ALWAYS REPORT — `MCP: N installed [names]` or
`MCP: none installed — placeholder replaced`.**

---

### Step 5.5 — Enable Skill Creator plugin

Enable the Skill Creator plugin for automated skill evaluation:

1. Check if already installed: `grep -r "skill-creator" ~/.claude/plugins/installed_plugins.json 2>/dev/null`
2. If not installed: `/plugin install skill-creator@claude-plugins-official`
3. Enable in project settings.json. NOTE: `.claude/settings.json` is only created in Step 14 —
   do NOT try to merge into it now. Record this key and merge it during Step 14:
   ```json
   "enabledPlugins": {
     "skill-creator@claude-plugins-official": true
   }
   ```
4. Log "Skill Creator plugin enabled. Will be used for skill eval in Steps 7-12 and on-demand creation."

**If installation fails** (plugin not available, network error, unsupported environment): Log "Skill Creator plugin unavailable — framework creation eval protocol will be used instead." Continue with Step 5.7. The framework's manual creation eval (2 test scenarios per agent) provides the same quality gate without the plugin.

---

### Step 5.7 — Copy pre-built process skills, process agents, and session rules

**Process skills (12 lifecycle — ALWAYS copied to `.claude/skills/`):**

```bash
# `.claude/docs/` IS THE UPSTREAM CHANNEL AND IT IS CORE, NOT TIER-GATED. `evolution-policy.md`
# is extracted unconditionally above and mandates writing
# `.claude/docs/framework-evolution-YYYY-MM-DD-<slug>.md`; the mother repo's `/maintenance`
# Step 0 globs exactly that path and is the ONLY mechanical owner of the whole
# project -> framework chain. Three shipped artifacts mandated the directory and NO command
# created it, so 2 of 3 live projects had nowhere to write and the sweep read `0 pending`
# on a channel that did not exist (`/audit` 2026-09-11, scoped sweep).
mkdir -p projects/$ARGUMENTS/.claude/skills projects/$ARGUMENTS/.claude/agents projects/$ARGUMENTS/.claude/docs
cp -r docs/modules/skills/* projects/$ARGUMENTS/.claude/skills/
# Tier-gated skills are copied ONLY by Step 5.8 per risk profile; README.md is framework docs.
# Without this removal, file-presence tier-gating silently activates every ceremony on every tier.
rm -rf projects/$ARGUMENTS/.claude/skills/codebase-audit projects/$ARGUMENTS/.claude/skills/framework-audit projects/$ARGUMENTS/.claude/skills/skill-gate projects/$ARGUMENTS/.claude/skills/README.md
```

- **Session lifecycle (user-triggered):** sprint-proposer, session-end, context-recovery
- **Whole-segment orchestration (user-triggered, opt-in Level 5):** autonomous-loop
- **During implementation:** validation-orchestrator
- **Session end:** project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator
- **PRD workflows:** cross-cutting-analysis
- **Commit workflow (user-triggered):** commit

**Process agents (3 — invoked as subagents, copied to `.claude/agents/`):**

```bash
cp docs/modules/agents/prd_sync_checker.md projects/$ARGUMENTS/.claude/agents/prd-sync-checker.md
cp docs/modules/agents/criteria_enforcer.md projects/$ARGUMENTS/.claude/agents/criteria-enforcer.md
cp docs/modules/agents/diff_pattern_extractor.md projects/$ARGUMENTS/.claude/agents/diff-pattern-extractor.md
```

- **Session start:** prd-sync-checker (called by sprint-proposer skill, step 3, opt-in)
- **Before implementing:** criteria-enforcer (called by validation-orchestrator skill)
- **Session end:** diff-pattern-extractor (called by session-end skill, item 1)

These 3 run as isolated subagents via Agent tool — they produce decisions or analyses where in-context execution risks skipping steps. The 12 lifecycle skills split by `invocation:` — **7 `inline`** (config-file-updater, cross-cutting-analysis, pendencias-updater, project-md-updater, rules-agents-updater, session-log-creator, validation-orchestrator: another component reads SKILL.md and follows its steps in its own context) and **5 `user`** (autonomous-loop, commit, context-recovery, session-end, sprint-proposer: the owner invokes them). "Copied to every project" and "`invocation: inline`" are DIFFERENT properties — never use one word for both.

**Session rules (copied to `.claude/rules/`):**

```bash
mkdir -p projects/$ARGUMENTS/.claude/rules
# Extract content between the 4-backtick outer fences (4 backticks so template bodies may contain normal ``` blocks)
sed -n '/^````markdown$/,/^````$/p' docs/modules/rules/session_rules.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/rules/session-rules.md
sed -n '/^````markdown$/,/^````$/p' docs/modules/rules/evolution_policy.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/rules/evolution-policy.md
sed -n '/^````markdown$/,/^````$/p' docs/modules/rules/component_design.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/rules/component-design.md
```

This creates session-rules.md (task limits, documentation quality, reasoning depth, scripts convention), evolution-policy.md (evolution classification, auto-evolution boundaries), and component-design.md (agent/skill/rule design principles: gap-declaration activation, Pushy Descriptions, vocabulary alignment, tiered architecture, Preservar+Adicionar).

**Component-registry liveness guard (ALL tiers — copied to `scripts/`):**

```bash
mkdir -p projects/$ARGUMENTS/scripts
sed -n '/^````js$/,/^````$/p' docs/modules/templates/check_agent_frontmatter.md | sed '1d;$d' > projects/$ARGUMENTS/scripts/check-agent-frontmatter.mjs
```

An invalid YAML frontmatter does not error — it makes the component silently VANISH from the
registry (FRAMEWORK-AGENT-YAML-01; see component-design.md §8). This guard fails loud instead.
It is dependency-free Node; the scripts convention applies (use if Node is available, otherwise
the manual check is reading the frontmatter of every agent/skill after editing it). If/when the
project gains a `package.json`, register `"check:agents": "node scripts/check-agent-frontmatter.mjs"`
so sessions and CI can invoke it uniformly.

Skills and agents are auto-discovered by Claude Code from `.claude/skills/` and `.claude/agents/`. No explicit listing is needed in CLAUDE.md.

---

### Step 5.8 — Copy tier-gated MACRO skeletons (by risk profile)

These ceremonies are scaled by the risk profile chosen in Step 1.2. **Copy ONLY what the profile
warrants** — an uncopied skeleton is an inactive ceremony (no runtime tier check needed; the
cadence checks in sprint-proposer Step 0 and the Rules-Driven Checks self-gate on file presence).

The cheap core (back-sweep, debt-aging, Post-Mortem ledger, session archetypes, class-checklist,
deploy guards) is already baked into the components/templates copied in Steps 3-5.7 and self-gates
by profile via its own clauses — nothing extra to copy for those.

**`internal-tool` and above — codebase-audit + metrics + skill-gate:**
```bash
cp -r docs/modules/skills/codebase-audit projects/$ARGUMENTS/.claude/skills/
mkdir -p projects/$ARGUMENTS/.claude/phases
sed -n '/^````markdown$/,/^````$/p' docs/modules/templates/metrics_md.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/phases/metrics.md
cp -r docs/modules/skills/skill-gate projects/$ARGUMENTS/.claude/skills/
cp docs/modules/agents/skill_reviewer.md projects/$ARGUMENTS/.claude/agents/skill-reviewer.md
mkdir -p projects/$ARGUMENTS/.claude/drafts/skills projects/$ARGUMENTS/.claude/drafts/rules projects/$ARGUMENTS/.claude/skill-gate/review_reports
```

**`production` and above — framework-audit + ops-rules + quality-budgets:**
```bash
cp -r docs/modules/skills/framework-audit projects/$ARGUMENTS/.claude/skills/
sed -n '/^````markdown$/,/^````$/p' docs/modules/templates/framework_metrics_md.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/phases/framework-metrics.md
sed -n '/^````markdown$/,/^````$/p' docs/modules/rules/ops_rules.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/rules/ops-rules.md
sed -n '/^````markdown$/,/^````$/p' docs/modules/rules/quality_budgets.md | sed '1d;$d' > projects/$ARGUMENTS/.claude/rules/quality-budgets.md
```

**`production-financial` only — additionally** fill the ops-rules §6 reconciliation queries with
schema-specific SELECTs (from the PRD data model), and note in `code-reviewer.md` that red-team is
mandatory on money-paths.

**`prototype` — copy none of the above.** The per-diff review loop is sufficient.

Log which skeletons were copied and the profile that gated them.

---

### Step 6 — Discover and install Skills

**6a. Search (in priority order):**

**Source 1 — Plugin marketplace (if available):**
If the plugin marketplace is accessible, browse for skills relevant to the stack:
```
/plugin marketplace browse
```
If this command is not recognized, skip to Source 2.

**Source 2 — CLI:**
```bash
npx claude-code-templates@latest --list-skills 2>/dev/null || echo "CLI not available"
```

**Source 3 — Web via Playwright (complementary):**
Only if Sources 1 and 2 returned no result.

**6b. Decide:**

| Stack | Recommended | Notes |
|-------|------------|-------|
| React / Next.js | react-best-practices | If available |
| Other | Search by technology | If available |

**Validation:**
- ✅ Focuses on QUALITY/PERFORMANCE of the stack → install
- ❌ Focuses on design/architecture OPINION → do NOT install (conflicts with project decisions)
- ❌ Contradicts PRD or CLAUDE.md patterns → do NOT install
- ❌ Covers 3+ languages/frameworks → too generic, do NOT install

Register in CLAUDE.md "Skills & Agents" section (the template's actual heading — Step 2 names it
correctly). No skill found? That is fine — skills are optional.

---

### Steps 7-12 — Create agents and skills

**Before creating any agent or skill in the steps below:** read `assets/examples/README.md` for conventions (frontmatter, structure, output format, invocation type). Then check if a relevant example exists in `assets/examples/agents/` or `assets/examples/skills/`. If found, use as a structural template — adapt to this project's stack and domain. Do NOT copy verbatim if not perfectly suitable for the project.

### Step 7 — Create code-reviewer agent

**If `.claude/agents/code-reviewer.md` already exists:** Do NOT overwrite. Verify it has "Known Bug Patterns" and "Architecture Patterns" sections. Add them if missing. Do not remove existing patterns.

**If it does not exist:** Read the template at `docs/modules/agents/code_reviewer.md`. Adapt:
- **Pre-fill "Architecture Patterns" from PRD:** Read the PRD's stack, framework, and architectural constraints. Add 3-7 stack-specific structural rules that are predictable from the technology choice (e.g., Next.js App Router → server/client component separation; Prisma → transaction usage for multi-table ops; Django → fat models/thin views). Keep the existing generic rules and append project-specific ones below them. Do NOT invent speculative patterns — only add rules that are well-established conventions for the chosen stack.
- **Pre-select Coverage Gap Declarations from PRD:** Review the five optional gap sections (accessibility, performance, concurrency, visual regression, data integrity). Remove sections that are clearly irrelevant to this project's domain (e.g., remove accessibility gap if project has no UI; remove concurrency gap if project has no shared state or booking logic; remove visual regression gap if the project ships no UI or has no shared components/design tokens). Keep sections that match PRD features. When in doubt, keep the section — it is conditional and only activates when matching diffs appear.
- **Keep "Known Bug Patterns" empty** — this section is populated by `rules-agents-updater` as real bugs emerge during development, not from predictions.
- Create at `.claude/agents/code-reviewer.md`

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios. Update lineage after eval.

### Step 8 — Create security-reviewer agent

This agent is created at bootstrap for ALL projects (security is universal).

**If `.claude/agents/security-reviewer.md` already exists:** Do NOT overwrite. Verify it has: prompt injection section, tiered security testing model reference, and Section 8 delegation.

**If it does not exist:** Read the template at `docs/modules/agents/security_reviewer.md`. Adapt:
- **Pre-select Coverage Gap Declarations from PRD:** Review the five optional gap sections (static analysis, secrets coverage, federation protocol, compliance, infrastructure security). Remove sections clearly irrelevant to this project (e.g., remove federation protocol gap if no OAuth/OIDC/SAML; remove infrastructure security gap if no IaC/Docker/K8s). Keep sections that match PRD's tech stack and architecture. When in doubt, keep — gaps are conditional and only fire when matching diffs appear.
- **Compliance Probe context:** If the PRD indicates the project handles personal data (PII, CPF, health records, payment data), note this in the agent so the Compliance Probe section activates from session 1 rather than waiting for a diff to reveal it.
- **Keep Section 8 (Stack-Specific Security) as-is** — this delegates to the stack skill and Red Team agent by design.
- Create at `.claude/agents/security-reviewer.md`

After creating, verify code-reviewer references it in the Security section.

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios.

### Step 9 — Create Red Team / Blue Team agents (if project risk warrants it)

Assess the PRD for security risk indicators:

```
PRD indicates ANY of these → CREATE Red Team + Blue Team agents:
  - User authentication (login, signup, password reset)
  - Multi-tenancy (org/team separation, row-level security)
  - Payment processing (Stripe, cards, financial transactions)
  - AI/LLM integration (prompts, embeddings, function calling)
  - Sensitive data storage (PII, health records, financial data)
  - External API integrations with credentials
  - File uploads from users

PRD indicates NONE of these → security-reviewer is sufficient, skip this step
```

**If creating:** Read templates at `docs/modules/agents/red_team.md` and `docs/modules/agents/blue_team.md`. Adapt with stack-specific attack vectors and security settings from PRD.
- Fill Stack Attack Surface table from PRD
- Fill Stack Security Settings from framework
- Create at `.claude/agents/red-team.md` and `.claude/agents/blue-team.md`

**Creation eval (DEFERRABLE if context is low):** See templates for eval scenarios.

### Step 10 — Create validator agent

The validator is mandatory for ALL projects. Read the template at `docs/modules/agents/validator.md`. Adapt with project-specific context. Create at `.claude/agents/validator.md`.

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios.

### Step 11 — Create arbitrator agent

The arbitrator is mandatory for ALL projects. Read the template at `docs/modules/agents/arbitrator.md`. Adapt with project-specific context. Create at `.claude/agents/arbitrator.md`.

**Creation eval (DEFERRABLE if context is low):** See template for eval scenarios.

### Step 12 — Create proactive stack skills

If the stack identified in the PRD has framework-specific patterns AND no existing skill was found in Step 6, create a stack skill using the Anthropic folder format:

```bash
mkdir -p projects/$ARGUMENTS/.claude/skills/[stack-name]
# Create projects/$ARGUMENTS/.claude/skills/[stack-name]/SKILL.md
```

**Trigger:** Stack is defined in PRD + no pre-made skill found + framework has known patterns.

**Include in the stack skill:**
- Key patterns for the framework (ORM, middleware, routing, component model)
- Common mistakes to avoid
- Stack-specific security settings (debug mode, secure cookies, CSRF, headers)
- Testing framework and conventions
- Project-specific adaptations (from PRD constraints)

**Also create domain-specific test patterns** when the project enters a domain with complex verification needs. Create as `.claude/skills/[domain]-test-patterns/SKILL.md` with:
- Critical test scenarios table (Scenario | Why | Example test)
- STRONG criteria examples for the domain
- Edge cases checklist

**Do NOT create if:** pre-made skill already installed, stack too generic, AI unfamiliar with framework.

### Step 12.5 — Pre-install specialist agents and validate activation chains

#### Step 12.5a — Pre-install specialist agents matching kept gap declarations

Read the project's `.claude/agents/code-reviewer.md`, `.claude/agents/security-reviewer.md` **and `.claude/agents/validator.md` — ALL THREE declaring components** (`component-design` §1; the validator declares the visual-regression gap from inside its own Validation Report, and the table below attributes that gap to it. Reading two of three meant this step could not produce its own table's row — `/audit` 2026-09-04 Q-1) (code-reviewer in Step 7, security-reviewer in Step 8, **validator in Step 10** — the parenthetical read `Steps 7-8` and was never updated when the validator became the third declarer, `/audit` 2026-09-10 U-25). Identify which Coverage Gap Declaration sections were KEPT (not removed during pre-selection). For each kept gap, check if a matching specialist example exists in `assets/examples/agents/`:

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
- `created:` lineage: change from `example` to `s0 (bootstrap — pre-installed from example template)`
- Verify the `description:` gap phrase matches the declaring component's gap declaration vocabulary

If a gap was KEPT but no matching example exists in `assets/examples/agents/`: register in
`pendencias.md` — "Create specialist agent for [gap] when domain implementation begins." A kept
gap that installs nothing and registers nothing is a gap the project can never act on.

#### Step 12.5b — Validate activation chains

> **The declaring components are gap SOURCES, not gap targets, and the loop below DERIVES that set rather than listing it** — it harvests the declared gaps from whichever files declare them and excludes exactly those files.
> **NEVER type the set here**: a typed five-name copy stood two lines above the loop that derives it, and its twin carried no such paragraph at all (`/audit` 2026-09-04 R-32). The replacement then asserted a derivation the loop did not perform — it still typed the three declarer names — until `/audit` 2026-09-09 T-16 made the loop match the paragraph.

For each remaining specialist agent:

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

**ALWAYS RUN THIS CHECK — it is the same loop EPA Step 5.1 runs, and bootstrap had none.** The
install link has broken on BOTH paths (H-2 on bootstrap, J-5 on EPA) while the mechanical net
existed on one; a prior receipt recorded that absence as a clearance rather than a finding
(`/audit` 2026-09-04 Q-33).

```bash
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
or `activation chains: none installed - no declaring component in <path>`. NEVER emit nothing.**
(**COPIED FROM the loop verbatim.** It emits THREE counts, so a two-count slot cannot receive it, and
`none installed` is now a real branch rather than a verdict the step could never produce —
`/audit` 2026-09-09 T-13, T-14.)

This step prevents "orphan agents" that exist in `.claude/agents/` but are never spawned because the declarer-to-orchestrator-to-specialist activation chain is broken.

---

### Step 13 — Pre-create domain rules from PRD

Analyze the PRD for domain signals. For each domain that is a **core feature or architectural pattern** in the PRD (not a passing mention), check if a matching example template exists in `assets/examples/rules/`:

| PRD signal (keywords/features) | Rules file to create | Example template |
|---|----|---|
| Multilingual, i18n, localization, multi-language | i18n-rules.md | assets/examples/rules/i18n-rules.md |
| Microservices, event-driven, message queue, saga | distributed-systems-rules.md | assets/examples/rules/distributed-systems-rules.md |
| Scheduling, cron, appointments, calendar, booking | scheduling-rules.md | assets/examples/rules/scheduling-rules.md |
| High-availability, retry, circuit-breaker, fallback | resilience-rules.md | assets/examples/rules/resilience-rules.md |
| Rate limiting, throttling, API quotas | rate-limiting-rules.md | assets/examples/rules/rate-limiting-rules.md |
| E-commerce, cart, checkout, payment, orders | e-commerce-rules.md | assets/examples/rules/e-commerce-rules.md |
| Full-stack, frontend + backend, SSR, API + UI | frontend-backend-integration-rules.md | assets/examples/rules/frontend-backend-integration-rules.md |
| Auth, login, permissions, roles, OAuth | auth-rules.md | assets/examples/rules/auth-rules.md |
| PII, LGPD, GDPR, personal data, consent | compliance-rules.md | assets/examples/rules/compliance-rules.md |
| Multi-tenancy, organization isolation, RLS | multi-tenancy-rules.md | assets/examples/rules/multi-tenancy-rules.md |
| Observability, logging, tracing, metrics, alerts | observability-rules.md | assets/examples/rules/observability-rules.md |

**This step is the RECEIVER of Step 1.1's CODE concerns.** ALWAYS run the signal table against
the cross-cutting concerns Step 1.1 classified as code-constraining, not only against the PRD's
module list — a concern with no matching template falls to the `pendencias.md` registration clause
at the end of this step, never to silence. REPORT `cross-cutting received: R/R code concerns
placed (rules file or pendencias task)` — a mismatch with Step 1.1's count is RED.

**Guard:** Only pre-create when BOTH conditions are met: (1) the domain is a core feature or architectural pattern in the PRD, and (2) a matching example template exists in `assets/examples/rules/`.

For each match: copy from `assets/examples/rules/` to `.claude/rules/`, adapting:
- `applies_to:` frontmatter: reference the project's actual module names from the PRD
- Remove clearly irrelevant sections that contradict the PRD (e.g., RTL layout section in i18n-rules.md if the project targets only Portuguese/English)
- Add an HTML comment at the top of the file body: `<!-- Seeded from example template at bootstrap. Refined by rules-agents-updater as project-specific patterns emerge. -->`
- Do NOT rewrite code examples to match the project's stack — leave for `rules-agents-updater` to refine with real code patterns

For modules with complex business logic but WITHOUT a matching example template: register in `pendencias.md` as a future task:
```
- Create `.claude/rules/[module]-rules.md` when starting implementation of [module]
```

---

### Step 14 — Create settings.json, configure hooks, and initialize logs

Create `.claude/logs/` directory for session logs:
```bash
mkdir -p projects/$ARGUMENTS/.claude/logs
```

Read the template at `docs/modules/templates/settings_json.md`. Create `.claude/settings.json` with the permissions and hooks configuration.

**ALWAYS merge the `enabledPlugins` key recorded in Step 5.5** (if that step succeeded) into the
settings file now — this step is the RECEIVER of that handoff. The template does NOT carry the key
(it is per-project: which plugins were actually installed is decided at runtime, not by the
template). If Step 5.5 logged the plugin as unavailable, ALWAYS state "no enabledPlugins to merge —
Step 5.5 reported the plugin unavailable" rather than silently writing nothing.

**Prerequisite:** Prettier must be installed (`npm install -D prettier`). If the project does not use Prettier, skip the hooks section.

**ALWAYS write the outcome back into CLAUDE.md's `## Hooks` section** — the template ships the
placeholder "[Configured in Step 14 below — depends on project formatter.]", and a project whose
CLAUDE.md still carries that line references a bootstrap step that does not exist in the project.
Replace it with the configured hooks, or with "none — project has no formatter".

**Note:** If `.claude/settings.json` or `.claude/settings.local.json` already exists, merge the keys rather than overwriting.

---

### Step 14.2 — Create the CI floor (t=0 gate — internal-tool+ profiles)

Rigor cannot depend on the discipline of the worst session. For `internal-tool` and above,
create a CI scaffold NOW so build/lint/test run as automatic gates from the first commit — the
pipeline never starts out empty and added "later."

- Detect the stack's CI convention (GitHub → `.github/workflows/ci.yml`; GitLab → `.gitlab-ci.yml`;
  etc.) and the project's actual build/lint/test commands (from CLAUDE.md Commands / package
  manifest).
- Emit a minimal pipeline that runs, in order: install → lint → build → test. Each step uses the
  REAL command if it exists; if a command is not yet defined (e.g., no tests yet), emit it
  commented with a `# TODO: enable when [command] exists` marker — never silently omit the stage.
- Add a `guards` stage running `node scripts/check-agent-frontmatter.mjs` (copied in Step 5.7 —
  dependency-free, needs no install). CI catches a broken component frontmatter before merge; the
  session-start/loop-start run (session-rules) catches it earlier, before any PR exists.
- **ALWAYS make the test stage PROVE it executed** (session-rules → "Execution proof"): configure
  the runner so a zero-unit run FAILS (most runners have a flag for it — e.g. "fail when no tests
  matched"), and make any conditional skip path (missing secrets, missing config) exit RED with a
  named reason instead of reporting the same green as a real run. A stage that skips silently
  reports `pass` in seconds for hundreds of test files, and the only clue is the DURATION.
- This is the per-diff CI gate (the lowest gate tier). It is distinct from the per-task validation
  gate and the production+ DEPLOY GUARD.

**`prototype` — skip.** Log "CI floor skipped (prototype profile)."

If the stack/runner cannot be determined, register a task in `pendencias.md`: "Create CI floor
once stack is confirmed" and log the deferral.

---

### Step 14.5 — Create initial commit

Every project file has now been written. Create the initial commit **inside the project repo** (created by Setup step 2 — never the framework repo):

```bash
cd projects/$ARGUMENTS
git add -A
git commit -m "chore: bootstrap from agentic framework"
```

**Before committing, ALWAYS verify you are inside the project repo:**
- Run `git rev-parse --show-toplevel`. It MUST print the absolute path to `projects/$ARGUMENTS`, not the framework path.
- If it prints the framework path, Setup step 2 failed (no `.git/` was created). STOP and investigate instead of committing — committing from the framework path would pollute the framework repo (or be silently blocked by `.gitignore: projects/`, depending on which files you stage).

**Do NOT run `git remote add origin` or `git push`.** The remote URL is project-specific and must be provided by the user after bootstrap. Step 15 will instruct the user on the exact commands to run.

**If the commit fails because `user.name` / `user.email` is not configured:** report the error in Step 15's output and instruct the user to set those locally inside the project (`git -C projects/$ARGUMENTS config user.name "..."` / `user.email "..."`) and then re-run the two commands above. Do NOT modify global git config.

---

### Step 15 — Report

```
## Session 0 — Bootstrap Complete

### Framework freshness (Step 0.5) — ALWAYS report, never omit:
- `up to date` · `no remote — skipped` · `behind by N commits — STOPPED` ·
  `behind upstream by N — STOPPED` · `no upstream tracking — UNVERIFIABLE, STOPPED` ·
  `fetch failed — UNVERIFIABLE, STOPPED` · `unverifiable — STOPPED`
  (all seven of Step 0.5's outcomes — a slot missing a verdict the step can produce is the
  DESCENDING gap `/audit` 2026-09-02 M-8 names)

### PRD pointer (Step 2) — ALWAYS report, never omit:
- `assets/docs/prd.md` · `none — bootstrapped without a PRD`
  (BOTH verdicts Step 2 can produce, and ONLY those two — a third, `none — no such section`, bled
  in from Step 1.1's cross-cutting verdict and was corrected by `/audit` 2026-09-03 P-16. A slot
  offering a verdict its owning step cannot emit is the same defect as a mandate with no slot,
  mirrored: **ALWAYS copy the enumeration FROM the mandating step, never re-derive it.** A mandated report line with no slot in the final report is
  owed by nobody — the same DESCENDING class M-8 was raised on, introduced by M-8's own commit
  and caught by `/audit` 2026-09-03 N-23.)

### Activation chains (Step 12.5b) — ALWAYS report, never omit:
- `activation chains: N verified, M broken, I info`
- `activation chains: none installed - no declaring component in <path>`
  (BOTH verdicts the loop can emit, and ONLY those two — **COPIED FROM the loop's own two `echo`
  lines, never re-derived** (Gate 4). The loop emits THREE counts and this slot offered two, so a
  compliant discharge had nowhere to land; the `none installed` verdict carries the path. The
  MANDATE was corrected on both twins and the SLOT was not — `/audit` 2026-09-10 U-5, U-13.)

### Cross-cutting concerns (Step 1.1 → Steps 3/4/13) — ALWAYS report, never omit:
- Classified at Step 1.1: [N] (R → rules, A → decisions, T → tasks)
- Delivered by receivers: R/R rules (Step 13) · A/A decisions (Step 3) · T/T tasks (Step 4)
- [or `none — PRD has no Cross-cutting Concerns section`]
- **Any receiver count below its Step 1.1 count is RED** — name the dropped concern.

### MCPs (Step 5) — ALWAYS report, never omit:
- `N installed: [names]` · `none installed — placeholder replaced`
  (BOTH verdicts Step 5 can produce. Neither had any slot at all until
  `/audit` 2026-09-03 P-21 — the mandate existed and had nowhere to land.)

### Hooks (Step 14) — ALWAYS report, never omit:
- `configured — [the hooks written]` · `none — project has no formatter`
  (**COPIED FROM Step 14's mandate verbatim** — those are the only two outcomes it writes. An
  earlier slot offered `smart-formatting ACTIVE`, a verdict Step 14 never emits, while the twin
  carried a third — `/audit` 2026-09-04 R-13, written back `applied` with nothing landed; re-filed
  2026-09-09 T-10.)
  (BOTH verdicts Step 14 can produce, and ONLY those two — the enumeration is COPIED FROM the
  step, never paraphrased. A third, `SKIPPED: no formatter detected`, was a paraphrase of the
  second and appears nowhere in Step 14; the slot asserted it was one of "all three"
  (`/audit` 2026-09-04 Q-7).)

### Files created:
- CLAUDE.md ([lines] lines)
- .claude/phases/project.md ([lines] lines)
- .claude/phases/pendencias.md ([lines] lines)
- .claude/phases/done_tasks.md — completed tasks destination (Step 4)
- .claude/agents/code-reviewer.md ([lines] lines)
- .claude/agents/security-reviewer.md ([lines] lines)
- .claude/agents/red-team.md ([lines] lines) ← if created (Step 9)
- .claude/agents/blue-team.md ([lines] lines) ← if created (Step 9)
- .claude/agents/validator.md ([lines] lines) ← mandatory (Step 10)
- .claude/agents/arbitrator.md ([lines] lines) ← mandatory (Step 11)
- .claude/skills/[stack-name]/SKILL.md ([lines] lines) ← if created (Step 12)
- .claude/skills/[domain]-test-patterns/SKILL.md ([lines] lines) ← if created (Step 12)
- .claude/settings.json
- .claude/logs/ (initialized — session logs start from session 1)
- assets/examples/ (copied from framework — Step 1.5)

### Process skills: copied from framework (Step 5.7):
- **Session lifecycle:** sprint-proposer, session-end, context-recovery
- **Whole-segment orchestration (opt-in Level 5):** autonomous-loop
- **Implementation:** validation-orchestrator
- **Session end:** project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator
- **PRD workflows:** cross-cutting-analysis
- **Commit workflow:** commit

### Process agents: copied from framework templates (Step 5.7):
- .claude/agents/prd-sync-checker.md (session start — subagent)
- .claude/agents/criteria-enforcer.md (before implementing — subagent)
- .claude/agents/diff-pattern-extractor.md (session end — subagent)

### Rules: copied from framework (Step 5.7):
- .claude/rules/session-rules.md (task limits, documentation quality, reasoning depth, scripts convention)
- .claude/rules/evolution-policy.md (evolution classification, auto-evolution boundaries)
- .claude/rules/component-design.md (agent/skill/rule design: gap-declaration, Pushy Descriptions, vocabulary alignment, tiered architecture)

### Guards: copied from framework (Step 5.7):
- scripts/check-agent-frontmatter.mjs (component-registry liveness — FRAMEWORK-AGENT-YAML-01; CI stage wired in Step 14.2)

### Domain rules pre-created (from example templates — Step 13):
- .claude/rules/[domain]-rules.md ← seeded, refined by rules-agents-updater
- [list each pre-created rules file, or "none — no PRD domain signals matched example templates"]

### Specialist agents pre-installed (from example templates — Step 12.5):
- .claude/agents/[specialist].md ← activation chain verified
- [list each pre-installed specialist, or "none — no gap declarations kept"]

### Risk profile: [prototype | internal-tool | production | production-financial]
- Derived from: [PRD signals], confirmed by owner: [yes/override]

### MACRO skeletons (tier-gated — Steps 5.8 / 14.2):
- codebase-audit skill ← [copied (internal-tool+) / skipped (prototype)]
- metrics.md ← [copied (internal-tool+) / skipped]
- skill-gate skill + skill-reviewer agent + .claude/drafts/ + .claude/skill-gate/review_reports/ ← [copied (internal-tool+) / skipped (prototype)]
- framework-audit skill ← [copied (production+) / skipped]
- framework-metrics.md ← [copied (production+) / skipped]
- ops-rules.md ← [copied (production+) / skipped]
- quality-budgets.md ← [copied (production+) / skipped]
- CI floor ← [created (internal-tool+) / skipped / deferred — task added]
- [production-financial] reconciliation queries filled, red-team mandatory on money-paths: [yes/N/A]

### Hooks configured: [see the `Hooks (Step 14)` slot above — this section lists the CONFIGURED
HOOK ENTRIES, not the verdict. One verdict, one home (`/audit` 2026-09-04 Q-8).]
- [hook entries written into settings.json, or `none`]

### MCPs installed: [see the `MCPs (Step 5)` slot above for the VERDICT — this section lists
the per-MCP connection status.]
- [name]: [WORKING / ERROR: detail]

### Skills installed:
- [name or "none"]
- [stack-skill if created] (proactive — Step 12)
- [domain-test-patterns if created] (proactive — Step 12)

### Rules planned for future creation (no example template):
- [module] → .claude/rules/[module]-rules.md
- [or "none — all detected domains had example templates"]

### Build Order:
1. [first step — NEXT SESSION]
2. [...]

### Decisions made:
- [list]

### PRD version: v[X.X.X]

### Plugin enablement (Step 5.5 → Step 14) — ALWAYS report, never omit:
- `enabledPlugins` merged into settings.json: [key] / `none — Step 5.5 reported the plugin unavailable`

### Initial commit (Step 14.5) — ALWAYS report, never omit:
- Status: ✅ committed `[hash]` / ❌ FAILED — [reason]
- Repo root verified: `git rev-parse --show-toplevel` → [path printed]
- If ❌ (e.g. `user.name` / `user.email` unset): the repo has NO commit yet. Instruct the owner to
  set the identity locally and re-run Step 14.5's two commands BEFORE the remote block below —
  `git push` against a commit-less repo does nothing useful.

### Next session should:
- [specific action from first Build Order item]

### Attach your remote (run these yourself — bootstrap never pushes; requires the commit above to be ✅):
    cd projects/[project-name]
    git remote add origin [project-repo-url]
    git push -u origin main
```
