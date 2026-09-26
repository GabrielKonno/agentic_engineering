---
name: sprint-proposer
invocation: user
effort: medium
description: >
  Run before implementation work to load project state, sync PRD, and propose a
  sprint. Checks for model switch continuation, reads project.md, optionally syncs
  PRD, analyzes pendencias.md, selects 3-5 tasks by dependency, and presents for
  approval. Owns SESSION ENTRY for every mode (audit cadence, markers, PRD sync)
  and manages sprint-approved mode (exception stops, between-tasks workflow, sprint
  reports); HANDS OFF to the `autonomous-loop` skill when Level 5 (segment or
  continuous mode) is requested or a LOOP CONTINUATION marker is found. Not needed for
  planning discussions, task management, or quick fixes. Without this,
  implementation sessions start without project context and wrong priorities.
created: framework-v2.1.0 (pre-validated)
derived_from: 'session_protocol "At the START of implementation sessions" — section of docs/agentic_engineering_framework.md in the FRAMEWORK repo; lineage only, NOT shipped to projects, do not attempt to resolve a project path'
---

# Sprint Proposer

## When to run

Before **implementation work** — when you intend to build, fix, or validate code.

Not needed for:
- Planning discussions or architecture reviews
- Adding/reorganizing tasks in pendencias.md
- Quick fixes where the user specifies the exact task
- Framework maintenance sessions

Claude Code automatically handles: CLAUDE.md reading, rules loading (via `paths:` globs — a rule without `paths:` loads in every session and subagent; `applies_to:` is ignored), skill/agent discovery (via `description:` frontmatter), and codebase exploration.

## Process

### 0. Audit cadence check (gated by skill presence)

Before anything else, check whether a periodic audit is due. A check whose skill folder was not
copied at bootstrap does not apply — its absence means the tier does not want it, and no tier
lookup is needed. **NEVER skip one SILENTLY: ALWAYS REPORT one line per check** —
`audit cadence: codebase-audit [due at N — proposed | not due, N of M | n/a — skill not installed]`
— and the same for `framework-audit`. A silent skip and a forgotten check are indistinguishable to
the next session, which is the whole proposition of `component-design` § 9 item 3
(`/audit` 2026-09-02 M-49, re-filed 2026-09-03 N-34 after the first fix was receipted but never
made).

- **codebase-audit:** IF `.claude/skills/codebase-audit/` exists — compute sessions since the last
  codebase-audit (scan the Progress Log). If ≥ `AUDIT_CADENCE` (default 12; 20 for internal-tool)
  OR this is a phase boundary → propose running `/codebase-audit` as this session's work (or
  alongside a light sprint). Owner accepts or defers.
- **framework-audit:** IF `.claude/skills/framework-audit/` exists — same check against
  `FRAMEWORK_AUDIT_CADENCE` (default 35; 25 for production-financial). Propose `/framework-audit`.
  Sparser than codebase-audit by design.

**ALWAYS anchor both counts on the last `COMPLETE` entry, SKIPPING any marked `INCOMPLETE`**
(session-rules → "Cadence integrity"). An interrupted audit records valid data but does NOT reset
the clock — treating its entry as "last run" is how the expensive half of an audit goes missing
for many cadences while the cheap half keeps publishing healthy numbers. If the most recent entry
is INCOMPLETE, ALWAYS say so in the proposal: `audit due — last run was INCOMPLETE (steps N,M)`.

**ALWAYS COUNT a Progress Log entry carrying `counts as N sessions for audit cadence` as N sessions,
never as 1** — `project-md-updater` → step 1 writes it for loop and continuous sessions, from the
count `autonomous-loop` hands to `/session-end` (Step 2; "Continuous mode" → C5 and C6), and an entry
reading `counts as 0` counts 0.

Proposing is not running — the owner decides. If both are due, propose codebase-audit first
(code health) and note framework-audit is also due. Then continue to Step 1.

### 1. Check for LOOP CONTINUATION — and HAND OFF

Check for a LOOP CONTINUATION block below the Progress Log table in `.claude/phases/project.md`.

**If one exists, this session is a loop RESUME: ALWAYS HAND OFF to the `autonomous-loop` skill**
at the next approved phase — no new approval (see `autonomous-loop` → "Continuation across
sessions"). SKIP the normal proposal flow below. Step 0 has already run and its result TRAVELS
with the handoff: a multi-session loop can cross `AUDIT_CADENCE` mid-loop. If an audit is due, do
NOT silently skip it — include it in the resume announcement ("audit due — say 'pause for audit'
to run it now, otherwise I'll propose it after the loop"). The loop NEVER runs an audit
autonomously; audits stay owner-gated.

**A marker carrying `**Mode:** continuous` hands off the SAME way** — to `autonomous-loop` →
"Continuous mode" → C6 re-entry. That skill reads the marker's `State:`; this step NEVER decides
whether a continuous resume may open a task.

**A firing of the continuous-mode trigger (`/sprint-proposer continuous`) that finds NO marker ALWAYS
ENDS ITS TRIGGER AND STOPS** — the mode was revoked or completed, possibly from another session.
**NEVER fall through to a sprint proposal on such a firing:** it would re-propose on every firing,
unattended.
- **The `continuous` ARGUMENT is what marks a trigger firing** — only a recurring trigger carries it
  (`autonomous-loop` → C6 arms it that way). An owner who wants to START continuous mode asks for it in
  words and runs this skill WITHOUT the argument; the request then reaches Step 4d, never this branch.
- **ALWAYS END the trigger with the mechanism it provides** — do not schedule the next wake-up of a
  self-paced `/loop`, delete a fixed-interval `/loop`'s job, disable a scheduled session — and name it
  in the report line below.

**ALWAYS REPORT the check — `loop marker: none` or `loop marker: active → handing off to
autonomous-loop (phase X of Y)` or `loop marker: active → handing off to autonomous-loop
(continuous, state S)` or `loop marker: none — continuous trigger ended (no marker; [mechanism])`. NEVER emit nothing.** This step is the INVOKER of the loop's
resume (component-design §9): nobody reads the `autonomous-loop` frontmatter in a session that has
not already decided to run it. Mechanical self-check (expected result stated):
`grep -c "LOOP CONTINUATION — active" .claude/phases/project.md` → `1` means hand off; `0` means
continue below — EXCEPT on a firing carrying the `continuous` argument, where `0` means end the
trigger and stop.

### 1b. Check for MODEL SWITCH continuation

Check for a MODEL SWITCH block below the Progress Log table in `.claude/phases/project.md`. If one exists:
- This session is a continuation — skip normal dependency analysis and task selection (steps 4a/4b)
- The task and reason for the switch are in the marker
- Log: "Continuing: [task name] (model switched from [source] to [target])"
- **Still produce a sprint proposal using the §4c format, with a single task (the one from the marker).**
  Include a "Continuation context" block at the top: why the switch happened, what the previous session
  delivered, what this session must not re-decide. Include Risks, Critical files previewed, and Verification
  overview.
- Wait for user approval of the proposal.
- After approval, proceed to the validation-orchestrator skill's "Before Implementing" section with the
  specified task.
- **Do NOT load a pre-existing plan.** Planning happens fresh in the continuation session by design, so the
  more capable model plans without bias from a weaker-model draft. Any exploration/notes the prior session
  persisted are context, not a plan.

If no MODEL SWITCH block exists, continue normally.

### 2. Read project.md

Read `.claude/phases/project.md`:
- **First session:** read fully (overview, architectural decisions, module relationships, phases)
- **Returning sessions:** architectural decisions + Project Phases status + Progress Log index

### 3. PRD sync check (opt-in)

**This step is the INVOKER — it is the only place the prd-sync-checker mandate lives**
(component-design §9). NEVER rely on the agent's own frontmatter to make it run: nobody reads the
frontmatter of an agent that is not being spawned.

Ask the user: **"Do you want me to run the PRD sync check?"**

If yes: invoke `.claude/agents/prd-sync-checker.md` as subagent. This compares PRD version/content with project.md and propagates changes. Runs in isolated context, no session bias.

If no: skip. The user knows whether the PRD changed or was already synced.

**ALWAYS report the outcome in the sprint proposal (§4c) — `ran — [outcome]` or
`skipped — [reason]`. NEVER emit nothing.** A silence is indistinguishable from a forgetting, and
that is exactly how a "mandatory at every session start" component reaches zero spawns without
anyone noticing. Mechanical self-check for the owner (expected result stated): grep the session
logs for this step's outcome line — every session must have one.

### 4. Analyze pendencias.md and propose sprint

Read `.claude/phases/pendencias.md`. If MODEL SWITCH continuation was active (step 1), **skip 4a (dependency
analysis) and 4b (task selection)** — the task is already fixed by the marker — but **still produce the
sprint proposal in 4c format** with that single task and the continuation context block.

After a model switch restart: do NOT resume the previous sprint unchanged — propose a fresh single-task
sprint for the task named in the marker. Context has changed and the continuation session plans fresh.

> **Design rationale:** Planning post-switch is intentional. The weaker model must not draft the plan the
> stronger model will execute (avoids bias). sprint-proposer only reads project.md + pendencias.md without
> code exploration, so no prior-session work is lost when the switch happens at classification time. The
> sprint proposal in continuation exists to give panoramic visibility (context/risks/critical files) before
> the user enters detailed plan approval inside validation-orchestrator.

#### 4a. Analyze
- Read all items in "Next Steps" and "In Progress"
- Check dependency graph (`depends:` fields)
- Identify which tasks have satisfied dependencies (a task in "Next Steps" or "In Progress" whose dependencies are all completed)
- If a `depends:` references a task number not found in pendencias.md, check `.claude/phases/done_tasks.md` — the dependency may have been archived there. If found in done_tasks.md, the dependency is satisfied.
- Note complexity classification of each task

#### 4b. Select tasks
- **ALWAYS PICK dependency-satisfied tasks within the task limit — 3-5 by default; up to 7 ONLY
  if all are small AND related; exactly 1 if the task is large.** The cap is the limit of a human
  APPROVAL's attention, which is why it is a COUNT here and explicitly NOT one in loop mode
  (`autonomous-loop` Step 1: phases are cut by dependency and resource disjointness). The 3-5
  default is what you pick absent a reason; the 7 and 1 cases are the only sanctioned departures
  from it, and each requires the stated condition to hold.
- Order by: dependency resolution first, then priority
- Mix: prefer starting with a small warm-up task if available

#### 4c. Present sprint proposal

```
## Sprint Proposal: Session N
### PRD sync: ran — [outcome] | skipped — [reason]   (ALWAYS present; never blank)
### Audit cadence: codebase-audit [due at N — proposed | not due, N of M | n/a — not installed]
                   framework-audit [same three verdicts]   (ALWAYS present; never blank)
                   (`n/a — skill not installed`, verbatim from the step; NEVER paraphrased)
### Loop marker: [none | active → handing off to autonomous-loop (phase X of Y) | active → handing off to autonomous-loop (continuous, state S) | none — continuous trigger ended (no marker; [mechanism])]   (ALWAYS present)
### Audit due: [n/a | last run was INCOMPLETE (steps N,M)]   (ALWAYS present when a check reports it)
### Tasks selected (N):
1. Task [N] — [name] (complexity, estimated scope)
2. Task [N] — [name] (complexity, estimated scope)
### Execution order: [N → N → N]
### Model & effort (MUST include — never omit):
- Task [N]: [complexity] → [model] + [effort] — [justification]
- Task [N]: [complexity] → [model] + [effort] — [justification]
### Risks: [anything that might cause a stop]
### Loop offer (only when the Level 5 section's conditions hold): [segment — why | continuous — why (N admissible, +M added since last session); alternative: [the other mode | sprint]]
### What I need from you:
- Approve this sprint (I will execute all tasks, stopping only on exceptions)
- OR adjust: remove/add/reorder tasks
```

**Model & effort mapping — ALWAYS derive and present for every task. Never omit this section.**
Derive from each task's `Complexity:` field in pendencias.md. If no complexity field exists, classify before presenting:
- `routine` → `current model` + `current settings` — no change needed
- `logic-heavy` → `current model` + `extended thinking` — [reason: e.g., financial logic, state machine]
- `architecture/security` → `⚠️ model switch required (interrupts sprint)` + `high effort` — [reason]

#### 4d. Handle response
- **Human approves** → enter sprint-approved mode (medium tasks proceed without approval)
- **Human approves in loop mode** (or requested it up front) → INVOKE the `autonomous-loop` skill (Level 5). Steps 0-3 above ARE the session entry it relies on — that skill NEVER repeats them
- **Human asks for (or accepts the offer of) continuous mode** → INVOKE the `autonomous-loop` skill at "Continuous mode" → C1 (it presents the admission POLICY for approval; this proposal's task list is NOT that approval)
- **Human adjusts** → apply adjustments and confirm
- **Human wants task-by-task** → proceed as Level 3 (present each task individually)

### Rules
- Only include tasks with satisfied dependencies
- Never include a task whose prerequisite is also in the sprint (sequential dependency)
- **If a task is classified as architecture/security, ALWAYS note in Risks that it triggers a model switch**
- Large tasks (1 per session) should not be batched with other tasks

---

## Sprint-Approved Mode (Level 4)

When the human approves a sprint batch (step 4 above), the following rules apply:

- **Small tasks:** implement directly (same as Level 3).
- **Medium tasks:** generate the plan, log it, and proceed WITHOUT waiting for approval.
- **Large tasks:** still require individual plan approval, even within a sprint.
- **Discoveries during implementation:** add new task to pendencias.md with full Context/State/Constraints/Complexity/Criteria, and ALWAYS tag it `origin: discovered (sN, task M)` — continuous mode's admission policy keys on that field (`autonomous-loop` → "Continuous mode" → C3). Continue sprint unless the discovery blocks the current task. **Cap: max 3 discoveries per sprint.** After 3, flag to human at next exception stop or sprint report.

### Exception stops

Sprint-approved mode pauses only for these conditions:

- ❌ after 3 retry cycles
- PRD ambiguity or contradiction with existing decision
- MANUAL: criteria (flag in report, continue with next task)
- Context degradation (trigger `/context-recovery`)
- Current task blocked by a discovery requiring human input
- False ❌ from subagent escalated by arbitrator (genuinely ambiguous — human decides)

This list is closed. Skill-gate events are deliberately NOT on it: a draft that
fails 3 review cycles, hits a duplicate overlap, or needs observation-mode
promotion confirmation becomes a pendency + sprint-report line and the sprint
continues (see skill-gate SKILL.md, "In sprint-approved mode").

---

## Between Tasks (after validation passes)

After the validation-orchestrator skill completes successfully:

1. **Commit** if not already committed: for routine tasks with inline validation, `git add -A && git commit -m "feat: [task name] — validated"`. For subagent-validated tasks, the `feat:` commit was made before Phase B — it already stands.
2. **Update pendencias.md:** move completed task to `done_tasks.md` (full metadata), confirm next task in pendencias.md.
3. **Context health check:** **From the 3rd task in a session on, ALWAYS evaluate context health before the next one.** If it is degrading, ALWAYS run `/context-recovery` instead of continuing, and say so.
4. **Sprint-approved mode:** pick next task from the batch and proceed directly to the validation-orchestrator's "Before Implementing" section. Do NOT re-propose the sprint or ask for confirmation. If all sprint tasks are done, produce a sprint report:

```
## Sprint Report: Session N
### Tasks completed: [N/N]
| Task | Result | Issues |
|------|--------|--------|
| [name] | ✅/❌ | [MANUAL: items or notes] |
### Discoveries added to backlog: [N new tasks]
### Known Bug Patterns added: [N]
### Rules files created/updated: [list]
### Skill-gate activity (if installed): [promoted / awaiting owner confirmation / failed review → pendency / none]
### Orchestration lessons (loop mode only — see `autonomous-loop`; "none" is a valid entry):
[subagent collisions/contention, implementer-report gaps, stale-premise surprises — distinct from code discoveries]
### Next sprint suggestion: [top 3-5 tasks]
```

**Why the orchestration-lessons section exists:** the diff-pattern-extractor captures CODE
lessons (it scans the diff) and the session log captures decisions — but "two subagents
collided on the same file" appears in NO diff. Full rationale and the loop's own report format:
`autonomous-loop` → "Final report".

---

## Autonomous Loop Mode (Level 5) — lives in its OWN skill

Level 5 (SEGMENT or CONTINUOUS execution with the main agent as ORCHESTRATOR) was extracted to
`.claude/skills/autonomous-loop/` in framework v2.8.0. Its mechanics are deliberately NOT restated
here: a mode whose full text would load in every non-loop session is context every ordinary sprint pays
for and never uses.

**ALWAYS INVOKE `autonomous-loop` — NEVER improvise loop mechanics from this file — when:**
- the owner asks to run the backlog in loop mode, OR
- the owner asks for continuous mode (a standing admission policy instead of a fixed list), OR
- Step 1 found an active LOOP CONTINUATION marker (handoff), OR
- Step 4c offered the loop and the owner accepted.

**Step 4c MAY OFFER the loop** when the backlog fits: mostly small/medium independent tasks,
dependencies resolvable in sequence, no large task, no architecture/security task that would force
a model switch mid-loop. **Offering is NOT entering** — the owner decides, and `autonomous-loop`
re-verifies the gate before planning (its Step 1a).

**Step 4c MAY OFFER continuous mode instead** when ALL hold:
1. the segment conditions above hold for the tasks that would be admitted;
2. more admissible tasks are waiting than one sprint holds (more than 5);
3. the backlog keeps receiving tasks — at least one task was added to `pendencias.md` since the
   previous session (a queue that never grows is a segment, and the segment offer is enough).

**ALWAYS offer AT MOST ONE mode, with the alternative named in the same line** — never two competing
offers.

**NEVER offer continuous mode in a session whose Step 0 reported an audit due** — the first thing
the mode would do is stop at its checkpoint. Accepting the offer goes to §4d.

What stays HERE and is SHARED by both modes: Steps 0-3 (session entry), "Between Tasks", the
sprint report format, and the exception-stop list. `autonomous-loop` points back at them rather
than restating them — one home per mandate (component-design §9).
