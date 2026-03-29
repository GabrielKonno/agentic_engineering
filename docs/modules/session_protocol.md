# Session Protocol

This module defines the START-of-session, END-of-session, between-tasks, and mid-session recovery protocols. It is embedded into the project's config file (CLAUDE.md) during bootstrap.

In v1.6.0, the protocol items that involve multi-step processes are delegated to pre-built process skills (in `.claude/skills/`). The protocol retains the sequence and triggers; the skills contain the how-to.

---

## At the START of every session:

1. Read `CLAUDE.md` (this file)
2. **Check for MODEL SWITCH continuation:** Check for a MODEL SWITCH block below the Progress Log table in `.claude/phases/project.md`. If one exists:
   - This session is a continuation — skip normal task selection
   - The task and reason for the switch are in the marker
   - Log: "Continuing: [task name] (model switched from [source] to [target])"
   - Proceed directly to "Before implementing" with the specified task
3. Read `.claude/phases/project.md` — full on first session; architectural decisions + Project Phases status + Progress Log index on returning sessions
4. **PRD sync check** → run `.claude/skills/prd-sync-checker/SKILL.md`
   <!-- Compares PRD version/content with project.md, propagates changes if needed -->
5. Read `.claude/phases/pendencias.md` — what is next
6. **Propose sprint** → run `.claude/skills/sprint-proposer/SKILL.md`
   <!-- Selects 3-5 tasks, orders by dependency, presents for approval -->
7. Read `.claude/rules/*.md` relevant to current task
8. Read design system if modifying UI
9. Read `.claude/skills/*/SKILL.md` if relevant skill exists for current task
10. **Codebase discovery** (if first session or unfamiliar module):
    ```bash
    find . -maxdepth 2 -type d -not -path '*/node_modules/*' -not -path '*/.next/*' -not -path '*/.git/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' | head -40
    find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.rb" -o -name "*.java" -o -name "*.vue" -o -name "*.svelte" 2>/dev/null | grep -v node_modules | grep -v .next | wc -l
    ls -la package.json tsconfig.json next.config.* nuxt.config.* vite.config.* manage.py pyproject.toml go.mod Cargo.toml Gemfile docker-compose.yml 2>/dev/null
    ```
    Explore deeper based on framework detected. File Map in CLAUDE.md is a quick pointer; codebase discovery is the source of truth. If they conflict, trust discovery and update File Map.

### Task limit per session:

Maximum 3-5 tasks per session. If backlog has more: complete 3-5, run end-of-session docs, commit, and start a new session for the next batch. Exceptions: if all tasks are small (single file, bug fix) and related, up to 7 is acceptable. If a single task is large (new module), 1 task per session is appropriate.

Signals that you've exceeded the limit: contradicting earlier self-review findings, skipping validation steps, producing ⏭️ on steps that should be ✅ or ❌.

### Three mechanisms for reasoning depth (complementary):

1. **Agent-level (automatic, zero intervention):** `effort:` in agent/skill frontmatter. Applies automatically when that agent/skill is invoked. Security agents always use `effort: high` regardless of session settings.

2. **Task-level recommendation (2 seconds):** AI classifies task complexity → recommends increased reasoning depth in implementation plan. Human adjusts before approving. No restart needed.

3. **Session-level model switch (5 seconds):** AI detects task needs a different model entirely → saves state with MODEL SWITCH marker → updates model configuration → requests restart. New session auto-continues the specific task. AI reverts settings after task completion.

Mechanisms stack: a standard-effort session uses high effort when security agents run (mechanism 1), can switch to high effort for a financial task (mechanism 2), and can switch to a more capable model for an architecture task (mechanism 3).

---

## At the END of every session:

### Evolution classification

Every evolution in the items below must be classified by its trigger mode:

| Mode | Trigger | Examples |
|------|---------|----------|
| **FIX** | Something failed that should have worked | Bug missed by review → fix agent checklist. Rule contradicts code → fix rule. |
| **DERIVED** | Something works but can be consolidated | 3+ Known Bug Patterns from same domain → derive rules file. Agent accumulates similar checks → derive organized sections. |
| **CAPTURED** | Pattern observed in real usage | Diff scan finds recurring pattern → capture as Known Bug Pattern. Structural decision → capture as Architecture Pattern. |

The classification determines follow-up actions:
- **FIX** → re-run eval if the component has a `last_eval` in its lineage
- **DERIVED** → no eval needed (source patterns were already validated individually)
- **CAPTURED** → no eval needed (the diff is the evidence)

Log each evolution with its classification: `"[FIX/DERIVED/CAPTURED]: [component] — [what changed and why]"`

**Priority order** (if context limited, at minimum do items 1 and 2):

1. **Extract patterns from diff** → run `.claude/skills/diff-pattern-extractor/SKILL.md`
   <!-- Scans git diff, adds to Known Bug Patterns / Architecture Patterns -->
2. **Create session log** → run `.claude/skills/session-log-creator/SKILL.md`
   <!-- Primary detailed record in .claude/logs/ -->
   **Update project.md** → run `.claude/skills/project-md-updater/SKILL.md`
   <!-- Concise index row referencing the session log + PRD version + phase status -->
3. **Update pendencias.md** → run `.claude/skills/pendencias-updater/SKILL.md`
   <!-- Move completed to Done, add new items with full criteria -->
4. **Update CLAUDE.md** → run `.claude/skills/config-file-updater/SKILL.md`
   <!-- When module status, patterns, rules, or File Map changed -->
5. **Update rules/agents/skills/PRD** → run `.claude/skills/rules-agents-updater/SKILL.md`
   <!-- Create rules files, update agents with discoveries, on-demand creation -->

**Documentation updates are mandatory.** Items 4-5 can be deferred if context window is low.

---

## Auto-evolution boundaries

The rule: if the evolution changes **DATA** (what the agent knows), it is safe for autonomous evolution. If it changes **BEHAVIOR** (how the agent acts), it requires human approval.

**Agent evolves autonomously (no human approval needed):**
- Known Bug Patterns (factual — derived from diffs)
- Architecture Patterns (factual — derived from structural decisions)
- File Map in CLAUDE.md (factual — reflects filesystem)
- Commands section in CLAUDE.md (factual — reflects what works)
- Skills content (knowledge/process — errors are caught by eval loops)
- Agent checklist items — **ADDING** new checks (from real bugs via FIX mechanism)
- Lineage metadata (append-only)
- Efficacy tracking fields (append-only metrics)

**Requires human approval before modification:**
- Session Protocol / Execution Protocol / Validation Orchestration Protocol
- Task limits, retry limits, sprint mechanics
- Context routing rules
- Rules files (domain business logic)
- PRD
- Agent checklist items — **REMOVING or WEAKENING** existing checks
- Changing an agent's `invocation` type, report format, or trigger conditions

The agent checks this list before making end-of-session updates. For human-approval items, propose the change in the session log and wait for confirmation instead of applying directly.

---

## Mid-session context recovery:

If context window is getting full (forgetting earlier decisions, repeating mistakes, losing track):
1. STOP implementation
2. Run end-of-session skills (at minimum session-log-creator, project-md-updater and pendencias-updater)
3. Commit: `git add -A && git commit -m "wip: [task] — context limit"`
4. Tell the user: "Context is degrading. I've saved state. Please start a new session to continue with fresh context."

Signals: contradicting earlier decisions, re-asking answered questions, forgetting patterns from CLAUDE.md, inconsistent validation results.
The user can also trigger this by saying "save state and start fresh".

---

## Documentation quality:
- Specific: "Fixed reopenMonth deleting only unpaid" NOT "Fixed a bug"
- Include WHY: "Added parseLocal() because toISOString() shifts dates in UTC-3 timezone"
- Constraints go in rules files, not just session logs

## PRD sync check — edge cases:
- No PRD: skip entirely
- PRD without changelog: add one with version 1.0, run Check B
- Check A version matches project.md recorded version: already propagated, skip
- Check B mismatch without version bump: ASK user before propagating, fix changelog
