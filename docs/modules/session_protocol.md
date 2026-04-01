# Session Protocol

This module defines the START-of-session, END-of-session, between-tasks, and mid-session recovery protocols. This is the architectural reference — WHAT happens and WHY.

In v2.1.0, all protocol logic is implemented as skills. CLAUDE.md contains pointers only:
- `sprint-proposer` skill: START-of-session (4 steps: model switch check, project.md, PRD sync, sprint proposal) + sprint-approved mode + between-tasks workflow
- `session-end` skill: END-of-session (5 skills/agents orchestrated in sequence)
- `context-recovery` skill: mid-session emergency save (calls 3 sub-skills directly, not session-end)
- `.claude/rules/evolution-policy.md`: evolution classification (FIX/DERIVED/CAPTURED) + auto-evolution boundaries
- `validation-orchestrator` skill: before-implementing + validation loop + post-mortem
- `.claude/rules/session-rules.md`: task limits, documentation quality, reasoning depth

---

## At the START of implementation sessions:

> **Note:** Claude Code automatically handles CLAUDE.md reading, rules loading (via `applies_to` globs), skill/agent discovery (via `description:` frontmatter), and codebase exploration. The steps below cover what Claude Code does NOT do automatically.

Run `/sprint-proposer` to load project context and propose a sprint. The skill handles:

1. **Check for MODEL SWITCH continuation** (early return if active — proceeds directly to validation-orchestrator)
2. **Read project.md** (full on first session, partial on returning)
3. **PRD sync check** (opt-in — asks user, spawns prd-sync-checker subagent)
4. **Analyze pendencias.md and propose sprint** (3-5 tasks, ordered by dependency)

See `.claude/skills/sprint-proposer/SKILL.md` for the full process.

### Task limit per session:

Maximum 3-5 tasks per session. If backlog has more: complete 3-5, run end-of-session docs, commit, and start a new session for the next batch. Exceptions: if all tasks are small (single file, bug fix) and related, up to 7 is acceptable. If a single task is large (new module), 1 task per session is appropriate.

Signals that you've exceeded the limit: contradicting earlier self-review findings, skipping validation steps, producing ⏭️ on steps that should be ✅ or ❌.

### Process component types

**Skills (9, in `.claude/skills/`):** inline — main agent reads SKILL.md and follows steps in its own context.
- **Session lifecycle (3, user-triggered):** sprint-proposer, session-end, context-recovery
- **During implementation (1):** validation-orchestrator
- **Session end (5, called by session-end):** project-md-updater, pendencias-updater, config-file-updater, rules-agents-updater, session-log-creator

**Process agents (3, in `.claude/agents/`):** subagent — main agent invokes via Agent tool; isolated context, no session bias. Main agent does NOT proceed until the subagent returns.
- `prd-sync-checker` — session start (step 3, opt-in)
- `criteria-enforcer` — before implementing (pass `Task: [task name]` in prompt)
- `diff-pattern-extractor` — session end (item 1)

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

<!-- Before running any skill, create a task list to ensure no step is skipped: -->
<!-- TaskCreate: end-of-session checklist -->
<!--   [ ] diff-pattern-extractor (subagent — invoke via Agent tool) -->
<!--   [ ] session-log-creator -->
<!--   [ ] project-md-updater -->
<!--   [ ] pendencias-updater -->
<!--   [ ] config-file-updater -->
<!--   [ ] rules-agents-updater -->
<!-- Mark each task complete only after the skill finishes. -->

1. **Extract patterns from diff** → invoke `.claude/agents/diff-pattern-extractor.md` as subagent
   <!-- Scans git diff, adds to Known Bug Patterns / Architecture Patterns — runs in isolated context -->
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
