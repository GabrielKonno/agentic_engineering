---
name: sprint-proposer
invocation: user
effort: medium
description: >
  Run before implementation work to load project state, sync PRD, and propose a
  sprint. Checks for model switch continuation, reads project.md, optionally syncs
  PRD, analyzes pendencias.md, selects 3-5 tasks by dependency, and presents for
  approval. Also manages sprint-approved mode (exception stops, between-tasks
  workflow, sprint reports) and the opt-in Autonomous Loop Mode (Level 5 —
  whole-backlog execution with the main agent as orchestrator). Not needed for
  planning discussions, task management, or quick fixes. Without this,
  implementation sessions start without project context and wrong priorities.
created: framework-v2.1.0 (pre-validated)
derived_from: session_protocol "At the START of implementation sessions"
---

# Sprint Proposer

## When to run

Before **implementation work** — when you intend to build, fix, or validate code.

Not needed for:
- Planning discussions or architecture reviews
- Adding/reorganizing tasks in pendencias.md
- Quick fixes where the user specifies the exact task
- Framework maintenance sessions

Claude Code automatically handles: CLAUDE.md reading, rules loading (via `applies_to` globs), skill/agent discovery (via `description:` frontmatter), and codebase exploration.

## Process

### 0. Audit cadence check (gated by skill presence)

Before anything else, check whether a periodic audit is due. Each check is silently skipped if
the corresponding skill folder was not copied at bootstrap (its absence = the tier doesn't want
it — no tier lookup needed).

- **codebase-audit:** IF `.claude/skills/codebase-audit/` exists — compute sessions since the last
  codebase-audit (scan the Progress Log). If ≥ `AUDIT_CADENCE` (default 12; 20 for internal-tool)
  OR this is a phase boundary → propose running `/codebase-audit` as this session's work (or
  alongside a light sprint). Owner accepts or defers.
- **framework-audit:** IF `.claude/skills/framework-audit/` exists — same check against
  `FRAMEWORK_AUDIT_CADENCE` (default 35; 25 for production-financial). Propose `/framework-audit`.
  Sparser than codebase-audit by design.

Proposing is not running — the owner decides. If both are due, propose codebase-audit first
(code health) and note framework-audit is also due. Then continue to Step 1.

### 1. Check for MODEL SWITCH or LOOP CONTINUATION

Check for a LOOP CONTINUATION block below the Progress Log table in `.claude/phases/project.md`.
If one exists: re-enter Autonomous Loop Mode at the next approved phase — no new approval
(see "Continuation across sessions" in the Autonomous Loop Mode section). Skip the normal
proposal flow below, BUT still run Step 0 first: a multi-session loop can cross
`AUDIT_CADENCE` mid-loop. If an audit is due, do NOT silently skip it — include it in the
resume announcement ("audit due — say 'pause for audit' to run it now, otherwise I'll
propose it after the loop") and propose it in the final sprint report. The loop NEVER runs
an audit autonomously; audits stay owner-gated.

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

Ask the user: **"Do you want me to run the PRD sync check?"**

If yes: invoke `.claude/agents/prd-sync-checker.md` as subagent. This compares PRD version/content with project.md and propagates changes. Runs in isolated context, no session bias.

If no: skip. The user knows whether the PRD changed or was already synced.

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
- Pick 3-5 dependency-satisfied tasks
- Order by: dependency resolution first, then priority
- Respect task limit (3-5 standard, up to 7 if all small+related, 1 if large)
- Mix: prefer starting with a small warm-up task if available

#### 4c. Present sprint proposal

```
## Sprint Proposal: Session N
### Tasks selected (N):
1. Task [N] — [name] (complexity, estimated scope)
2. Task [N] — [name] (complexity, estimated scope)
### Execution order: [N → N → N]
### Model & effort (MUST include — never omit):
- Task [N]: [complexity] → [model] + [effort] — [justification]
- Task [N]: [complexity] → [model] + [effort] — [justification]
### Risks: [anything that might cause a stop]
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
- **Human approves in loop mode** (or requested it up front) → enter Autonomous Loop Mode (Level 5, below)
- **Human adjusts** → apply adjustments and confirm
- **Human wants task-by-task** → proceed as Level 3 (present each task individually)

### Rules
- Only include tasks with satisfied dependencies
- Never include a task whose prerequisite is also in the sprint (sequential dependency)
- If a task is classified as architecture/security, it will trigger model switch — note this in Risks
- Large tasks (1 per session) should not be batched with other tasks

---

## Sprint-Approved Mode (Level 4)

When the human approves a sprint batch (step 4 above), the following rules apply:

- **Small tasks:** implement directly (same as Level 3).
- **Medium tasks:** generate the plan, log it, and proceed WITHOUT waiting for approval.
- **Large tasks:** still require individual plan approval, even within a sprint.
- **Discoveries during implementation:** add new task to pendencias.md with full Context/State/Constraints/Complexity/Criteria. Continue sprint unless the discovery blocks the current task. **Cap: max 3 discoveries per sprint.** After 3, flag to human at next exception stop or sprint report.

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
3. **Context health check:** If this is task 3+ in the session, evaluate context health. If degrading → run `/context-recovery` instead of continuing.
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
### Next sprint suggestion: [top 3-5 tasks]
```

---

## Autonomous Loop Mode (Level 5 — opt-in, NEVER default)

Extends sprint-approved mode from ONE batch to the WHOLE approved backlog, with the main
agent acting as ORCHESTRATOR instead of implementer. Validated in practice before
formalization (framework v2.5.0): one prototype session delivered 7 build phases
end-to-end under this shape.

### Activation
- The owner explicitly requests it ("run the backlog in loop mode"), OR Step 4c MAY
  OFFER it when the backlog fits: mostly small/medium independent tasks, dependencies
  resolvable in sequence, no large task, no architecture/security task that would force
  a model switch mid-loop. Offering is not entering — the owner decides.
- ALWAYS present a loop proposal for approval: the phases (groups of 3-5 tasks in
  dependency order), the context budget (~80% of the window), and what is explicitly OUT
  of loop scope. Owner approval of the loop proposal = prior approval for every phase.

### Orchestrator role — the main agent does NOT implement medium tasks
- **Small tasks** (single file, routine): implement directly — spawning costs more than doing.
- **Medium tasks:** ALWAYS spawn an implementer subagent per task with:
  - **Input:** the task's full block from pendencias (Context/State/Constraints/Criteria),
    the relevant rules files, CLAUDE.md Key Patterns, and target file paths — NOT the
    session history or other tasks' reasoning.
  - **Output contract:** files changed, diff summary, build/test results, and anything
    NOT done or discovered. The orchestrator reads the report — never re-derives the
    implementation reasoning into its own context. That separation is what buys the
    long horizon.
- **Large tasks** stay OUT of loop scope (individual plan approval, as in sprint-approved mode).

### Validation geometry (hybrid by risk)
- **Routine/small:** ONE merged review+validation subagent (single report: checklist
  review + criteria verification). The implementer is already an isolated subagent, so
  the two-judge split loses its main justification for low-risk diffs.
- **Logic-heavy:** full Route 2 (code-reviewer → validator), unchanged.
- **Security-relevant:** full chain including security-reviewer (+ red-team when
  high-risk), unchanged.
- ❌ handling, the 3-retry cap, and arbitrator escalation are inherited unchanged.

### Context budget — the stop condition is the window, not the task count
- The session task limit does NOT apply in loop mode; the budget is the context window.
- At EVERY phase boundary, ALWAYS checkpoint: estimate context usage. At ~80% — or at
  the first degradation signal (contradicting earlier findings, re-exploring known
  files) — STOP the loop: commit, produce the sprint report, run `/session-end`.
  NEVER start a new phase past the checkpoint.
- The ~20% above the budget is the RESERVE that pays for the stop path (commit + report
  + LOOP CONTINUATION marker + full session-end). NEVER spend it on one more phase —
  a loop that ends without its session-end leaves every document stale at once.
- Commit at every phase boundary — any stop is resumable from the last checkpoint.

### Per-phase rhythm
1. Announce the phase (tasks N..M) in one line.
2. Execute each task per Between Tasks, with delegation + validation as above.
3. At the phase boundary: commit; update pendencias/done_tasks; report the phase to the
   owner (1 line per task + discoveries); run the context checkpoint.
4. Proceed DIRECTLY to the next phase — no re-approval. The ONLY pauses are the
   exception stops (list in session-rules, unchanged — including skill-gate deferral).
5. Backlog done OR budget reached → final sprint report + full `/session-end` ONCE
   (never a heavyweight session-end per phase).

**Audit-cadence equivalence:** for `AUDIT_CADENCE` counting, a loop session counts as
ONE session PER COMPLETED PHASE (record "counts as N sessions for audit cadence" in the
sprint report). A loop session ships several sessions' worth of code — counting it as
one would silently thin audit coverage exactly when code volume spikes.

### Loop-specific guardrails (in addition to the exception stops)
- STOP the loop if 2 CONSECUTIVE tasks fail validation after retries — that is a
  systemic signal (wrong assumptions, degraded context), not a task-local one.
- STOP if a discovery invalidates the approved loop plan (dependency order broken,
  scope contradiction) — re-propose instead of improvising.
- Discovery cap: max 3 per PHASE (the sprint-approved cap, applied per phase).

### Continuation across sessions — one approval covers the WHOLE backlog

The loop approval is for the BACKLOG, not for one session. When the loop stops at the
context budget with approved phases remaining, ALWAYS write a LOOP CONTINUATION block
below the Progress Log table in `project.md` (same mechanism as the MODEL SWITCH marker)
before running session-end:

```
<!-- LOOP CONTINUATION — active -->
### [date] — Session N (AUTONOMOUS LOOP — in progress)
**Approved scope:** [the phases as approved, with status per phase]
**Completed:** [phases/tasks done this session]
**Next phase:** [tasks N..M]
**Stop reason:** context budget / [degradation signal]
```

On the NEXT session, Step 1 checks for this marker (alongside MODEL SWITCH). If present:
- Re-enter loop mode DIRECTLY at the next phase — NO new approval (the original approval
  stands until the approved scope is done or the owner revokes it).
- ALWAYS announce the resume in one line: "Resuming autonomous loop: phase X of Y
  ([tasks]). Say 'cancel the loop' to revoke." — visibility, not an approval gate.
- Remove the marker when the approved scope completes (final report) or the owner revokes.

**Scope integrity:** discoveries added during the loop are NEVER absorbed into the
approved scope — they queue in pendencias and the final report proposes them as the next
loop. Without this, the scope creeps and "the backlog" never ends.
