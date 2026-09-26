---
name: autonomous-loop
invocation: user
effort: high
description: >
  Runs an approved backlog SEGMENT end-to-end with the main agent as ORCHESTRATOR rather than
  implementer — cuts the segment into phases by dependency and resource disjointness, dispatches
  one implementer subagent per medium task under a plan-first contract, verifies every return
  from DISK, and closes each task to disk before the next opens. Two modes: SEGMENT (a fixed task
  list approved once) and CONTINUOUS (a standing admission POLICY approved once — the queue is
  re-read at every task boundary, so tasks registered mid-session are picked up, bounded by a
  checkpoint every 10 tasks, a discovery brake, and a capped class for self-discovered tasks).
  Opt-in: it NEVER activates by itself. USE when the owner asks to run the backlog in loop mode,
  in autonomous mode, or in continuous mode (keep executing tasks while the backlog has them, pick
  up tasks as they are registered), when sprint-proposer detects a LOOP CONTINUATION marker, or when
  a sprint proposal's loop offer is accepted. NOT needed for
  single tasks, sprint-approved batches, planning sessions, or any segment containing a large or
  architecture/security task. Without this, long-horizon execution burns the main agent's context
  on implementation reasoning and cannot survive an autocompact.
created: framework-v2.8.0
derived_from: sprint-proposer "Autonomous Loop Mode (Level 5)" — extracted to its own component in v2.8.0
---

# Autonomous Loop (Level 5)

Extends sprint-approved mode from ONE batch to an approved backlog SEGMENT, with the main agent
acting as ORCHESTRATOR instead of implementer. Validated in practice before formalization
(framework v2.5.0): one prototype session delivered 7 build phases end-to-end under this shape.

**Opt-in, NEVER default.** The mode activates on owner request or explicit acceptance of a loop
proposal — never by inference from a large backlog.

**Two modes, one skill.** SEGMENT mode (Steps 1-3 below) approves a fixed LIST. CONTINUOUS mode
approves a standing POLICY and keeps draining the queue as the owner adds to it — see
"Continuous mode" below, which reuses Step 3, the task closure, the resource rules and the
guardrails UNCHANGED and replaces only Step 1, the phase cut and the end condition.

---

## Entry — this skill NEVER repeats session entry

`sprint-proposer` Steps 0-3 own SESSION ENTRY for every mode (audit cadence, MODEL SWITCH and
LOOP CONTINUATION markers, `project.md`, PRD sync). Duplicating them here would create a second
home for the same mandate — the failure component-design §9 exists to prevent.

Four legitimate paths in — two per mode:

| Path | What already happened | What this skill does |
|------|----------------------|----------------------|
| **Fresh loop** | sprint-proposer ran Steps 0-3; the owner requested loop mode or accepted the loop offer at §4d | Start at Step 1 (LOOP PLAN) |
| **Resume** | sprint-proposer Step 1 found `LOOP CONTINUATION — active` and handed off | SKIP Step 1 — the plan is already approved; announce the resume, start Step 2 at the next phase |
| **Fresh continuous** | sprint-proposer ran Steps 0-3; the owner asked for continuous mode | Go to "Continuous mode" → C1 (the POLICY replaces Step 1) |
| **Continuous resume** | the marker carries `**Mode:** continuous` | SKIP C1 — the policy is already approved; go to "Continuous mode" → C6 re-entry |

**If NONE of the four paths applies** (the owner invoked this skill cold), ALWAYS run sprint-proposer Steps 0-3
FIRST, then return here. A loop planned without the cadence check and the marker check is a loop
that can silently skip a due audit or overwrite an in-flight continuation.

**When the owner's request does not name the mode** ("run the backlog in autonomous mode"), the
request is ambiguous between a SEGMENT and CONTINUOUS mode:
- **ALWAYS ASK which mode, in ONE question, after the entry steps and before Step 1 or C1** —
  segment ("the eligible tasks now, then stop") or continuous ("keep taking tasks as they arrive,
  checkpoint every 10").
- **NEVER default to continuous mode on an ambiguous request** — it is the wider authorization, and
  opt-in means the owner names it.
- **Words that DO name continuous mode:** continuous, "while there are tasks", "keep going as tasks
  arrive", "pick up new tasks". A request carrying one of them needs no question.

**ALWAYS REPORT which path was taken in one line** — `entry: fresh (sprint-proposer Steps 0-3 ran)`
or `entry: resume (LOOP CONTINUATION marker, phase X of Y)` or
`entry: fresh continuous (sprint-proposer Steps 0-3 ran)` or
`entry: continuous resume (state S, window N of M closed)` or
`entry: cold — ran sprint-proposer Steps 0-3 now`. NEVER emit nothing: a silence cannot be
distinguished from a skipped entry.

---

## Step 1 — The LOOP PLAN

The loop plan replaces the sprint batch. It is a DIFFERENT artifact with a different cut, and the
distinction is load-bearing:

> A **sprint** is capped at 3-5 tasks because that is the limit of a human APPROVAL's attention.
> A **phase** has no such cap: the owner approves the whole segment ONCE, so the only forces left
> to cut on are dependency order and resource disjointness. **NEVER carry the 3-5 number into a
> loop phase** — a count inherited from a different constraint produces phase boundaries that cut
> through a dependency chain or fuse two tasks that fight over the same test environment.

### 1a. Gate — verify the segment is loop-eligible BEFORE planning

ALWAYS check all four, and ALWAYS report the outcome. Any ❌ → do NOT enter the loop; propose a
sprint-approved batch instead, naming the disqualifying task.

- [ ] No **large** task in the segment (large tasks require individual plan approval — out of loop scope).
- [ ] No **architecture/security** task that would force a model switch mid-loop.
- [ ] Dependencies are resolvable in sequence (no cycle, no dependency on an unstarted out-of-scope task).
- [ ] The component liveness guard passes — `node scripts/check-agent-frontmatter.mjs` (or
      `npm run check:agents`). A reviewer whose frontmatter fails to parse VANISHES from the
      registry silently (component-design §8), and the loop's entire rigor rests on those
      reviewers. See session-rules → "Autonomous loop watchdog".

### 1b. Cut the segment into phases

ALWAYS cut on these two forces, in this order:

1. **Dependency order** — a task NEVER shares a phase with its own prerequisite.
2. **Resource disjointness** — tasks in the same phase SHOULD have disjoint file sets and MUST NOT
   both need the live test environment (see "Resource contention" below).

A phase may hold two tasks or nine. ALWAYS state the reason for each boundary in one clause
(`phase 3 ends here — task 14 depends on task 12`), so the owner reviews a cut, not a number.

### 1c. Present the loop plan for approval

```
## Loop Plan: [segment name]
### Entry: fresh | resume — [detail]
### Gate: large ✅/❌ | model-switch ✅/❌ | dependencies ✅/❌ | liveness ✅/❌ (N components OK)
### Phases:
- Phase 1 — tasks [N..M]: [one line] — boundary: [why it ends here]
- Phase 2 — tasks [N..M]: [one line] — boundary: [why it ends here]
### Model & effort per task (MUST include — never omit): [complexity → model + effort — why]
### Out of loop scope (explicit): [large tasks, architecture/security tasks, anything deferred]
### Pacing: per-task persistence (max ONE task in flight; each CLOSED to disk before the next)
### What I need from you: approve the plan — approval covers EVERY phase, until the segment
    completes or you revoke it.
```

Owner approval of the loop plan = prior approval for every phase. There is no per-phase re-approval.

---

## Step 2 — Per-phase rhythm

1. **RE-MEASURE every phase premise an existing instrument can measure** (quality/size scripts,
   suite counts, greps), THEN announce the phase (tasks N..M) in one line. Numbers inherited from
   an audit or a task block are HYPOTHESES, not contract — a phase planned on stale numbers burns
   an exception stop on work that no longer exists (seconds of re-measuring convert that stop into
   a silent scope adjustment). Companion of "a rule without an instrument is not a rule": an
   instrument without a RE-READ at the moment of use isn't one either.
2. Execute each task per Step 3 below, then per `sprint-proposer` → "Between Tasks" (commit,
   pendencias/done_tasks move, context health check).
3. At the phase boundary: run the **task-closure check** (below) for EVERY task in the phase —
   these are the CONDITION for opening the next phase, not good practice. Report the phase to the
   owner (1 line per task + discoveries).
4. Proceed DIRECTLY to the next phase — no re-approval. The ONLY pauses are the exception stops
   (`sprint-proposer` → "Exception stops", plus the loop guardrails below).
5. Segment done OR emergency degradation signal → final report + full `/session-end` ONCE (never a
   heavyweight session-end per phase).

**Audit-cadence equivalence:** for `AUDIT_CADENCE` counting, a loop session counts as ONE session
PER COMPLETED PHASE. A loop session ships several sessions' worth of code — counting it as one would
silently thin audit coverage exactly when code volume spikes.
- **ALWAYS WRITE `counts as N sessions for audit cadence` (N = completed phases) in the final report
  AND hand it to `/session-end`, so `project-md-updater` → step 1 writes it into the Progress Log
  row.** sprint-proposer Step 0 reads the Progress Log, never a final report — a count left only in
  the report is read by nobody, and the session counts as 1.

**The loop NEVER runs an audit autonomously.** If sprint-proposer Step 0 reported an audit due, the
resume announcement says so ("audit due — say 'pause for audit' to run it now, otherwise I'll
propose it after the loop") and the final report proposes it. Audits stay owner-gated.

---

## Step 3 — Per-task execution: the orchestrator role

The main agent does NOT implement medium tasks.

### 3a. Before dispatch — the ORCHESTRATOR owns "Before Implementing"

`validation-orchestrator` → "Before Implementing" has three steps. In loop mode their ownership
splits, and ALWAYS this way:

| Step | Owner in loop mode | Why |
|------|-------------------|-----|
| 1. criteria-enforcer | **ORCHESTRATOR**, before dispatch | Criteria are the implementer's CONTRACT and the validator's yardstick. An implementer that strengthens its own criteria is grading its own exam. |
| 2. Classify + route | **ORCHESTRATOR** | Complexity decides whether to dispatch at all (small = do it directly) and which validation geometry applies. |
| 3. Git checkpoint | **ORCHESTRATOR** | The rollback boundary belongs to whoever owns the working tree. |
| Implementation PLAN | **IMPLEMENTER** (see 3b) | This is the step that moves. |

**ALWAYS SPAWN criteria-enforcer before dispatching each medium task, and ALWAYS REPORT its
outcome** — `criteria-enforcer: ran — [N criteria strengthened]` or `skipped — [reason]`. NEVER
emit nothing.

**When criteria-enforcer changes a task's SCOPE — not only its wording — ALWAYS RE-CHECK the plan
before dispatching it.** The task grew: more call sites to fix, a sibling write path of worse
consequence, a new file in its set. The plan was built on the OLD scope, so the widened task can now
collide with another task, or cross the medium/large line.
- **Segment mode — RE-CHECK the phase cut (Step 1b) AND the gate (Step 1a):**
  - a new collision with, or dependency on, a task INSIDE the segment → RE-CUT the remaining phases under "Bounded re-sequencing authority" (reordering, no stop);
  - a new dependency on an UNSTARTED task outside the segment, or the task is now LARGE or architecture/security → STOP and re-propose. Each fails a Step 1a gate item, and dropping the task changes WHAT is in the segment.
- **Continuous mode — there is no phase cut (C1 replaces Step 1): RE-APPLY admission (C1, C3):** the task is now large, architecture/security, or depends on a held task → HOLD it (C3).
- **ALWAYS REPORT — `scope: unchanged` or `scope: widened — [what] — [phase cut unchanged | re-sequenced | stopped]` (segment) / `[admission unchanged | held]` (continuous)**, beside the `criteria-enforcer:` line. NEVER emit nothing.

Measuring the task before delegating is the highest-leverage step of a loop; this rule only gives a
destination to what that step already produces and would otherwise discard.

### 3b. Dispatch — the plan-first implementer contract

- **Small tasks** (single file, routine): implement DIRECTLY — spawning costs more than doing.
- **Medium tasks:** ALWAYS spawn ONE implementer subagent per task.
- **Large tasks** stay OUT of loop scope.

**ALWAYS give the implementer a PLAN-FIRST contract.** The plan is produced INSIDE the
implementer's isolated context, never in the orchestrator's:

```
1. PLAN — read the target files, then state: the change per file, the order, and the
   risk you consider most likely to bite.
2. SELF-CHECK — map each acceptance criterion to the step of your plan that satisfies it.
   A criterion with no step is a plan gap: say so BEFORE writing code.
3. IMPLEMENT — execute the plan. If reality contradicts it, say what changed and why.
4. REPORT — the output contract below.
```

> **Why the plan lives down here:** the orchestrator's long horizon is bought by NEVER absorbing
> implementation reasoning into its own context. A plan drafted upstairs is exactly that reasoning,
> paid for in the one context that must survive the whole segment. Planning per task is not
> optional — it is RELOCATED.

**Input — ALWAYS exactly this, never more:** the task's full block from pendencias
(Context/State/Constraints/Criteria, criteria already strengthened), the NAMES of the relevant rules
files (path-scoped rules load when the implementer READS a matching file — NEVER paste them), CLAUDE.md
Key Patterns, and target file paths. NEVER the session history, the loop plan, or other
tasks' reasoning.

**Output contract — ALWAYS require:** the plan and its self-check, files changed, diff summary,
build/test results WITH EXECUTED COUNTS (session-rules → "Execution proof": exit 0 with zero units
executed is ❌, never ✅), and anything NOT done or discovered.

**Anti-silent-death clause — ALWAYS include it verbatim in the implementer prompt:** "NEVER end the
turn waiting on a background process; if the final result is not available, report the explicit
PARTIAL STATE (what is done, what is running, where the log is)." An implementer that dies waiting
on a monitor returns a useless report over real, possibly irreversible work.

**Resource declaration — ALWAYS require it in the prompt:** the implementer DECLARES the exclusive
resources it touches (file set, shared test environment/database, phase docs, scratchpad files) and
whether it MUTATES the working tree — its MUTATOR or READER class, decided by what its prompt allows
("Resource contention").

### 3c. After return — trust but verify, from the DISK

After EVERY implementer return, ALWAYS verify state from the DISK before any commit or validation:
working-tree status plus a spot-check of the report's central claims (report says "migration
applied" → check the target; says "suite green" → check the log/output and its COUNT). The report
GUIDES the verification; it never substitutes for it. This is what turns a dead or partial report
into a recoverable state instead of a blind commit — or a falsely-failed phase.

### 3d. Validation geometry (hybrid by risk)

- **Routine/small:** ONE merged review+validation subagent (single report: checklist review +
  criteria verification) — plus security-reviewer when the diff touches client-bound data or an agent tool gate
  (`validation-orchestrator` → Route 2; those triggers hold on every route). The implementer is already an isolated subagent, so the two-judge split
  loses its main justification for low-risk diffs.
- **Logic-heavy:** full Route 2 (code-reviewer → validator), unchanged.
- **Security-relevant:** full chain including security-reviewer (+ red-team when high-risk), unchanged.
- **NEVER skip a money-path reviewer on a `production-financial` task citing another's APPROVE or a
  clean mutation score — the reviewers are COMPLEMENTARY.** code-reviewer, the data-integrity checker (when
  installed) and red-team each find a class the others cannot — a test that counts a compensating
  write but never checks what it restored; an inconsistent state no existing query detects; an
  escalation reproduced live — and a fully-killed mutation round can omit the one mutant a reviewer names.
- ❌ handling, the 3-retry cap, and arbitrator escalation are inherited unchanged.
- **NEVER downgrade this geometry because previous tasks validated clean.** A run of green is the
  state in which rigor is cheapest to drop and most expensive to have dropped; the geometry is
  fixed by the task's risk class, never by the streak.

---

## Task closure — the discipline that replaces a context gate

> Supersedes the original "~80% context budget" stop condition (framework v2.5.0). That rule was
> INEXECUTABLE as written: the model has no reliable perception of its own context usage, so an
> instructed "estimate" produces confabulation dressed as measurement (a first real loop session
> emitted three self-estimated percentages, all invented, >20 points off the real meter). A rule
> without an instrument is not a rule.

- The session task limit does NOT apply in loop mode — and neither does any numeric cap on context %,
  autocompact cycles, or subagent-report counts (a count is a stand-in for the same unobservable
  quantity).
- **The orchestrator NEVER emits self-estimated context percentages.** If budget state must be
  communicated, use countable units ("phase N closed; 7 subagent reports ingested") or ask the owner
  for the real meter — never an invented "% used".
- The four CONDITIONS (not good practices):
  1. **Max ONE task in flight** (uncommitted) at a time.
  2. **A task is CLOSED only when it is on disk:** code committed + LOOP CONTINUATION marker
     reflecting the next state + every discovery filed in pendencias + every new decision recorded
     in the doc that owns it. Nothing load-bearing may exist only in the conversation.
  3. **After an autocompact, re-anchor from the DISK** — re-read the marker + pendencias before
     continuing. Canonical docs are the anchor; the compact summary is derived. Re-anchoring every
     cycle means successive compacts do NOT compound drift (each re-reads the original, not the
     previous summary).
     **ALWAYS re-Read the in-flight task's target files before its next edit** — path-scoped rules
     entered the context as attachments to earlier Reads, and a compact can drop them.
  4. **A subagent report is NOT state to protect:** the implementation lives in the working tree
     (re-derivable from the diff); a read-only verdict is re-runnable (idempotent). If a compact
     intervenes between a reviewer's verdict and acting on it, RE-RUN the reviewer — NEVER commit
     on a verdict the compact blurred.
- With this discipline, an autocompact is a NON-EVENT (lossy compression, not death): a mid-task
  compact costs at most the single in-flight task. The loop runs until the approved segment is done
  or an emergency degradation signal fires (session-rules "Signals of exceeding" — in loop mode they
  are the EMERGENCY stop → `/context-recovery`, never a pacing knob), and it ends only at a natural
  TASK boundary, never mid-task.

### The task-closure check (MECHANICAL — run it, never assert it)

Condition 2 is prose, and prose is exactly what end-of-session context pressure erodes
(component-design §6). **ALWAYS RUN this at every task boundary and REPORT its output:**

```bash
# 1. working tree clean (the task's code is COMMITTED, not merely written)
git status --porcelain | grep -q . && echo "RED — uncommitted work at task boundary" || echo "OK — tree clean"
# 2. the continuation marker exists and is active   → expected: 1
grep -c "LOOP CONTINUATION — active" .claude/phases/project.md
```

Expected result: `OK — tree clean` AND `1`. **Any other output is RED and the next task does NOT
open.** A `0` on line 2 means the marker was never written or was consumed — the loop has no
resumable anchor, and a session that ends there loses the segment's position.

**ALWAYS REPORT the two outputs literally** (`closure: OK — tree clean | marker 1`). A closure
asserted from memory is the same evidence class as a review verdict written from memory —
see session-rules → "Autonomous loop watchdog" (RECEIPT discipline).

---

## Bounded re-sequencing authority

A discovery that breaks the planned ORDER is not the same event as a discovery that changes the
SCOPE, and collapsing them costs an exception stop for something the orchestrator can resolve.

- **ALLOWED without stopping — REORDERING within the approved segment.** If a discovery reveals
  that task 14 must precede task 11, or that two tasks in one phase now collide on the same file
  set, the orchestrator RE-CUTS the remaining phases and continues. **ALWAYS REPORT the re-cut in
  one line** (`re-sequenced: task 14 before task 11 — [discovered dependency]`) at the phase
  boundary. NEVER silently.
- **STOP and re-propose — anything that changes WHAT is in the segment:** adding a task, dropping a
  task, or a discovery that contradicts the segment's premise.
- **Scope integrity is unchanged:** discoveries added during the loop are NEVER absorbed into the
  approved segment — they queue in pendencias and the final report proposes them as the next loop.
  Re-sequencing moves the ORDER of approved work; it NEVER widens the set. Without this line the
  authority above becomes the scope creep the integrity rule exists to forbid.
- **In CONTINUOUS mode the SET is defined by the approved admission POLICY, not by a list** — see
  "Continuous mode" → C1 and C3. A task that passes the policy IS approved work; a task that fails
  it still queues for the owner. The policy replaces the list; it NEVER removes the rule that only
  approved work runs.

---

## Resource contention — the loop creates concurrency the serial flow never had

Parallel subagents (implementers, session-end steps) collide on shared resources in ways a serial
session never exercised: two test runs against the same live environment produce ROTATING flakes;
two writers on the same phase doc clobber each other; one session-end step can hold a file another
step needs. The orchestrator MUST keep an explicit RESOURCE map when dispatching:

- Each subagent's prompt MUST DECLARE the exclusive resources it touches — its FILE set, the shared
  TEST ENVIRONMENT/database, the PHASE DOCS (pendencias/project.md).
- **At most ONE live-test process at a time**, always owned by the orchestrator — never an
  implementer running the suite in parallel with another agent's run (rotating flakes cost multiple
  re-runs just to tell flake from regression).
- **NEVER run two writers on the same phase doc at once** — including session-end's own steps, which
  were written for serial execution and CAN conflict with each other (one step editing a file
  another step targets is a skip/collision, not a hypothetical).
- **NEVER run an agent that MUTATES the working tree in parallel with an agent that READS it.**
  A mutator writes files others read — a validator's mutation round (it injects mutants into real
  files and reverts them), a fixer, a formatter, a mass-edit script. Disjoint WRITERS is not enough:
  while a mutant sits on disk the tree is sabotaged for every reader, and a verdict issued in that
  window is about code that does not exist — and looks legitimate.
  **ALWAYS order it: readers first, then mutators, then `git status` / `git diff` before any verdict
  or commit.**
- **ALWAYS CLASSIFY an agent by what its PROMPT allows it to DO, NEVER by its NAME.** Before
  dispatching, ask of each prompt: may it write files, inject a mutant, run a mutation check, apply a
  fix, or run a test that writes files? If YES it is a MUTATOR — a code-reviewer or red team
  included — and it either runs SERIALIZED against every agent that touches the same tree, or runs
  with worktree isolation so its mutants never reach the shared tree. Only a strictly read-only prompt
  makes a READER.
  - **ALWAYS WRITE the class into the report's `### Parallel dispatches:` slot** (digest and final
    report) — `code-reviewer — MUTATOR (mutation check) — serialized` — so a misclassification is
    visible instead of silent.
  - **Self-check (execute and report per parallel dispatch group):** grep each prompt of the group for
    `mutant|mutation|apply the fix|fix it|run the test` (case-insensitive); a group with ≥1 hit and ≥2
    agents on the same tree without worktree isolation is a violation — serialize it.
- **ALWAYS put the SCRATCHPAD on the resource map.** It is one directory shared by every subagent
  of the session, so a helper there is a shared resource: a subagent that rewrites a helper under the
  same name can silently drop a safety guard (a read-only check on a database script) the
  orchestrator relies on — a lost control no test catches, because the script still "works".
  - **ALWAYS give each subagent its own scratchpad file names**, declared in its prompt.
  - **ALWAYS re-verify a shared helper's guards before reusing it** — never trust the file name.
- Minimal practical rule when the full map feels heavy: parallelize only work with DISJOINT file
  sets that runs NO live tests and MUTATES nothing another agent reads; serialize everything else.

> The mutator/reader and scratchpad rules come from ONE observed loop session in a production
> project; the classify-by-prompt rule from that project's later meta-audit, which found the
> name-based wording still permitted the original incident — two reviewers, both named as readers,
> had injected mutants into the shared tree and collided. They are cheap to follow and
> kept as HYPOTHESES. **Their measurer is `framework-audit` →
> Q4 → the HYPOTHESIS check**, which counts the typed `- mutator/reader overlap:` and
> `- scratchpad collision:` lines in the `## Orchestration lessons` section `session-log-creator`
> writes into `.claude/logs/` (a mutator/reader overlap is, for example, a reviewer verdict discarded
> for having read a mutant). A window with zero occurrences is
> "not exercised", never "effective". **`framework-audit` is installed only at `production`+: below it
> NOTHING measures these rules, and they stay unmeasured hypotheses, never validated ones**
> (`/audit` 2026-09-15 B-11).

---

## Loop guardrails (in addition to the exception stops)

The exception-stop list lives in `sprint-proposer` → "Exception stops" and is inherited unchanged.
These are ADDITIONAL:

- STOP the loop if 2 CONSECUTIVE tasks fail validation after retries — that is a systemic signal
  (wrong assumptions, degraded context), not a task-local one.
- STOP if a discovery invalidates the approved loop plan in SCOPE (see "Bounded re-sequencing" —
  an ORDER change is not a stop).
- STOP on a review-agent spawn returning "Agent type not found" — a HARD STOP, never a silent
  fallback to a general-purpose agent (session-rules → "Autonomous loop watchdog").
- Discovery cap: max 3 per PHASE (the sprint-approved cap, applied per phase).

---

## Continuation across sessions — one approval covers the whole segment

The loop approval is for the SEGMENT, not for one session. When the loop stops with approved phases
remaining (session ended at a natural task boundary, owner pause, or an emergency degradation
signal), ALWAYS write a LOOP CONTINUATION block below the Progress Log table in `project.md` (same
mechanism as the MODEL SWITCH marker) before running session-end:

```
<!-- LOOP CONTINUATION — active -->
### [date] — Session N (AUTONOMOUS LOOP — in progress)
**Approved scope:** [the phases as approved, with status per phase]
**Completed:** [phases/tasks done this session]
**Next phase:** [tasks N..M]
**Stop reason:** natural task boundary (session end) / owner pause / [emergency degradation signal]
```

On the NEXT session, `sprint-proposer` Step 1 detects this marker and hands off HERE. On resume:
- Re-enter at the next phase — NO new approval (the original approval stands until the approved
  scope is done or the owner revokes it).
- ALWAYS announce the resume in one line: "Resuming autonomous loop: phase X of Y ([tasks]). Say
  'cancel the loop' to revoke." — visibility, not an approval gate.
- Remove the marker when the approved scope completes (final report) or the owner revokes.
- **In continuous mode the marker carries extra fields** (`**Mode:** continuous`, policy, window
  counters, held list, state) — defined ONCE in "Continuous mode" → C4, never restated here.

---

## Continuous mode — a standing POLICY instead of a fixed SEGMENT

Segment mode ends when its approved list ends, and anything registered meanwhile waits for a new
approval. Continuous mode removes that wait: the owner approves an ADMISSION POLICY once, the
orchestrator re-reads the backlog at every task boundary, and every task that passes the policy is
executed — including tasks the owner registers mid-session. The owner stops COMMANDING execution
and SUPERVISES it: the policy up front, the digest at each checkpoint.

**Opt-in, NEVER default — exactly as segment mode.** It activates ONLY when the owner explicitly
asks for continuous mode.

**NEVER infer continuous mode from a segment ending or from a growing backlog.**

| | Segment mode | Continuous mode |
|---|---|---|
| What the owner approves | a task LIST cut into phases | an admission POLICY (C1) |
| Task registered mid-session | queues for the next loop | admitted at the next task boundary if it passes (C2) |
| Task discovered by the agent | never absorbed | admitted only in a restricted class, capped (C3) |
| Large or architecture/security task | disqualifies the segment (Step 1a) | HELD for the owner; the rest continues (C3) |
| When it ends | the segment is done | revocation or a stop (C5); an empty queue is IDLE, not an end (C6) |
| Human contact | once per loop | policy approval + a digest at every checkpoint (C5) |

**Inherited UNCHANGED — NEVER relaxed in this mode:** Step 3 (orchestrator role, plan-first
contract, verify from disk, validation geometry), "Task closure" and its mechanical check,
"Resource contention", "Loop guardrails", sprint-proposer's exception stops, and the rule that the
loop NEVER runs an audit autonomously. **NOT used:** Step 1b's phase cut — the queue is re-read at
every boundary, so a cut would be stale one task later.

> **Why the policy has brakes a list does not need:** a list is bounded by construction; a queue the
> executor can ADD to is a feedback loop. The framework's own audit series shows fixes introducing
> defects that the next pass files as new work — run unattended, that is fix → discover → file →
> implement → discover, with the backlog growing while the product drifts from intent. The
> discovery class (C3), the discovery brake and the checkpoint (C5) are the damping.

### C1. The admission policy — present it ONCE, for approval

**ALWAYS run sprint-proposer Steps 0-3 and the liveness guard (Step 1a, last item) BEFORE presenting
the policy.**

**ALWAYS RUN the tagging-writer check BEFORE presenting the policy — continuous mode FAILS CLOSED
without it.** Admission reads an untagged task as `owner`, so a project whose task-writing
components predate the `origin:` field would admit every AI-filed task uncapped:

```bash
# Every installed skill/agent that mentions pendencias is a candidate writer — DERIVED, never a typed
# list (a hand-typed list reads GREEN for any writer outside it). READERS names the components that
# only read pendencias or edit an existing task in place; a project component of that kind is added
# HERE, with its reason, never exempted silently.
READERS=" config-file-updater context-recovery project-md-updater criteria-enforcer "  # read / edit in place, never add a task
n=0
for f in $(grep -l pendencias .claude/skills/*/SKILL.md .claude/agents/*.md 2>/dev/null); do
  case "$f" in .claude/agents/*) c=$(basename "$f" .md) ;; *) c=$(basename "$(dirname "$f")") ;; esac
  case "$READERS" in *" $c "*) continue ;; esac
  n=$((n+1)); grep -q "origin:" "$f" || echo "UNTAGGED WRITER: $f"
done; echo "writers checked: $n"
```

**Expected: no `UNTAGGED WRITER` line, and `writers checked:` at least 1.** `writers checked: 0` means
no task writer is installed at all — a broken install, never a healthy one: continuous mode is
UNAVAILABLE. A tier-gated component
that is not installed is never listed, so it is never reported. **KNOWN LIMIT:** the test is per
FILE — a second, untagged write site inside a file that already carries a tag reads GREEN. Every
writer's tag instruction therefore lives next to its write site, and a new write site in an existing
writer MUST carry its own.
- **Any `UNTAGGED WRITER` line, or `writers checked: 0` → continuous mode is UNAVAILABLE — NEVER present the policy.**
- **ALWAYS name the untagged writers and offer segment mode instead** — a fixed list cannot absorb an
  untagged discovery.
- The remedy is `/existing_project_adaptation`, which refreshes these writers as one set.
- **ALWAYS REPORT — `tagging writers: N checked, 0 untagged` or `tagging writers: K untagged — continuous mode unavailable` or `tagging writers: 0 checked — continuous mode unavailable`, with N taken from the `writers checked:` line. NEVER emit nothing.**

Then ALWAYS present:

```
## Continuous Mode Policy: [project]
### Entry: fresh continuous | cold — [detail]
### Liveness: [N components OK]
### Tagging writers: [N checked, 0 untagged]
### Admission — a task enters the queue ONLY when ALL hold:
- complexity small or medium (NEVER large)
- `Complexity:` is NOT architecture/security
- every `depends:` is in done_tasks.md or admitted ahead of it
- acceptance criteria present, with at least 1 `BUILD:`
- `origin: owner` (or no origin line) → admitted | `origin: discovered` → C3 class only
### Discovery cap: 3 admitted discoveries per checkpoint window
### Checkpoint: every 10 closed tasks OR audit due — whichever comes first
### Discovery brake: STOP when discovered > closed in the window, once closed >= 3
### Queue now: [N admitted — task list] | Held: [task — reason, or "none"]
### Model & effort per admitted task (MUST include — never omit): [complexity → model + effort — why]
### Pacing: per-task persistence (max ONE task in flight; each CLOSED to disk before the next)
### Re-entry: `/loop /sprint-proposer continuous` (see C6), or re-invoke manually
### What I need from you: approve the policy — it stands until you say "cancel continuous mode".
```

The owner MAY change any value (a lower cap, a shorter checkpoint, excluding logic-heavy tasks).
**ALWAYS WRITE the approved values into the marker (C4) before the first task** — the next session
applies the marker, never a remembered conversation.

### C2. The per-task cycle

At EVERY task boundary — after the task-closure check reads OK — ALWAYS run, in this order:

1. **RE-READ `pendencias.md` and `done_tasks.md` FROM DISK** — the owner is a concurrent writer,
   and an in-memory backlog is a stale premise.
   - **NEVER write `pendencias.md` from an in-memory copy — ALWAYS re-read it immediately before
     each write** ("Resource contention": two writers, one doc).
2. **APPLY the admission policy (C1, C3) to every task not yet classified.**
   **ALWAYS REPORT — `admission: +A admitted, +H held, +D deferred (queue N)`. NEVER emit nothing.**
3. **CHECK the stops (C5).** Any that fires → stop per C5; do NOT open a task.
4. **RE-MEASURE the next task's premises** (Step 2 item 1, applied per task instead of per phase).
5. **PICK the next admitted task** — dependency order first, then pendencias order — and execute it
   per Step 3.
6. **CLOSE it** per "Task closure", updating the marker's window counters IN THE SAME closure (C4).

Queue empty after step 2 → C6 (idle).

### C3. Held tasks and self-discovered tasks

- **HOLD, never skip silently and never implement,** every task that fails admission for its KIND
  (large, architecture/security, no criteria).
  - **ALWAYS write each held task to the marker's `Held for owner` list, with its reason.**
  - **ALWAYS HOLD every task whose `depends:` includes a held task, and NAME the chain.**
- **ALWAYS tag every task this mode files** with `origin: discovered (sN, task M)` in its header block
  (the `origin:` field of the pendencias template). An untagged task is treated as `origin: owner`:
  it predates this mode or was registered by hand, and the owner saw the queue in C1.
- **A discovered task is ADMITTED automatically ONLY when ALL hold:**
  1. complexity small;
  2. it is a bug or debt in code that a task CLOSED in this mode touched — never a new feature,
     never a new module;
  3. not architecture/security;
  4. the window's admitted-discovery count is below the cap.
- **Everything else is DEFERRED** — it stays in pendencias for the owner and is listed in the next
  digest. Deferring is not a stop; the loop continues.

### C4. The marker — continuous-mode fields

Continuous mode reuses the SAME marker string, so sprint-proposer Step 1 detects it with no change.
**ALWAYS write it with these fields:**

```
<!-- LOOP CONTINUATION — active -->
### [date] — Session N (AUTONOMOUS LOOP — continuous)
**Mode:** continuous
**Policy:** cap [3] | checkpoint [10] | brake discovered>closed (min 3) | [owner changes, or "defaults"]
**Window:** closed [N] | discovered [D] | admitted-discoveries [A]
**Held for owner:** [task — reason, or "none"]
**Deferred discoveries:** [task numbers, or "none"]
**State:** running | idle — queue empty | checkpoint pending | stopped — [reason]
**Last closed:** task [N] ([sHASH])
```

**The `Window` and `Last closed` lines are part of closure condition 2** — they ARE the loop's
position, and nothing load-bearing may live only in the conversation.

**ALWAYS COMMIT every change to the `Window` line** — at a C6 reset, and at task closure IN THE
TASK'S LAST COMMIT (the marker change MUST be in `HEAD` when the boundary is checked). The previous
value then lives in git history, on disk, where an autocompact or a re-entry cannot lose it; a value
remembered from the previous boundary is exactly what a compact erases.

In continuous mode the task-closure check ALWAYS runs these lines IN ADDITION to its own:

```bash
grep -c "^\*\*Mode:\*\* continuous" .claude/phases/project.md                        # expected: 1
w() { grep -oE "^\*\*Window:\*\* closed [0-9]+" | grep -oE "[0-9]+$"; }
chg() { git log -"$1" --format=%H -G'^\*\*Window:\*\* closed' -- .claude/phases/project.md; }
prevc=$(chg 2 | sed -n 2p); lastc=$(chg 1)
prev=$( [ -n "$prevc" ] && git show "$prevc":.claude/phases/project.md | w )
cur=$(w < .claude/phases/project.md)
# commits AFTER the counter moved, other than the owner's concurrent backlog writes and merges
after=$( [ -n "$lastc" ] && git log --first-parent --no-merges --format=%h "$lastc"..HEAD -- . ':(exclude).claude/phases' ':(exclude).claude/logs' | wc -l )
[ -n "$lastc" ] && [ "${after:-1}" -eq 0 ] && [ -n "$cur" ] && [ "$cur" = "$(( ${prev:-0} + 1 ))" ] \
  && echo "OK — window ${prev:-0} -> $cur" \
  || echo "RED — window ${prev:-none} -> ${cur:-none}; marker last changed in ${lastc:0:7}, ${after:-?} later commit(s) outside .claude/phases and .claude/logs"
```

**Expected: `1`, and `OK — window N -> N+1`.** RED also when the task's code was committed without
the marker change: no commit after the one that moved the counter may touch anything outside
`.claude/phases/` and `.claude/logs/`. The owner is a declared concurrent writer of the backlog (C2
step 1), and an idle `/session-end` writes the log and the Progress Log — those commits, and merge
commits, never read RED. The previous value is read from the previous commit
that changed the `Window` line, so a C6 reset (committed as `closed 0`) makes the next boundary read
`OK — window 0 -> 1`. **KNOWN LIMIT:** an owner commit to any OTHER file after the counter moved reads
RED — the check cannot tell it from the loop's own late commit; the disposition below resolves it.

**Anything else is RED — the next task does NOT open.**
**ALWAYS treat a closure RED as a C5 STOP — write `State: stopped — closure check RED at task N` and
do the rest of C5's four steps.** It is never a silent pause: without a `State` the next re-entry cannot
tell a RED boundary from a healthy one.

**ALWAYS REPORT both outputs literally**, beside the two lines of the base check.

### C5. Stops — the checkpoint, the brake, revocation

Every stop below ends at a TASK boundary — revocation included. Every stop EXCEPT revocation ALWAYS
does all four: write `**State:**`, run `/session-end`, emit the digest, and **END THE RECURRING
TRIGGER**. A stop that re-fires on its own schedule is not a stop.
**ALWAYS EMIT THE `### Orchestration lessons` BLOCK BEFORE RUNNING `/session-end` — at every stop below,
revocation included, and at every idle `/session-end` (C6).** `session-log-creator` copies that block
into the log and has no other source; the digest is emitted AFTER `/session-end`, and revocation and
idle emit no digest at all, so the lessons of those stops reached no log (`/audit` 2026-09-15 B-11,
found by its pre-commit verifier).

**ALWAYS END THE TRIGGER WITH THE MECHANISM THAT TRIGGER PROVIDES, and NAME it in the digest:**
- a self-paced `/loop` → do NOT schedule its next wake-up (tell the loop to stop);
- a fixed-interval `/loop` → delete its scheduled job;
- a scheduled session → disable its schedule.

A trigger is owned by the session that armed it.

**NEVER claim a trigger ended when this session does not own it** — say `still armed — owned by
another session; it ends at its next firing`.

- **Checkpoint** — `closed` reaches the policy's checkpoint value, OR sprint-proposer Step 0 reports
  an audit due → `State: checkpoint pending`. An audit is PROPOSED in the digest, NEVER run.
- **Discovery brake** — `discovered > closed` with `closed >= 3` → `State: stopped — discovery
  brake`. The backlog is growing faster than it drains: that is the loop feeding itself.
- **Every segment guardrail and exception stop** ("Loop guardrails"; sprint-proposer → "Exception
  stops") → `State: stopped — [which]`.
- **Closure check RED** (C4) → `State: stopped — closure check RED at task N`.
- **Revocation** — the owner says "cancel continuous mode" → close the in-flight task at its boundary,
  remove the marker, run `/session-end`, end the trigger. Three steps, not four: there is no `State`
  to write once the marker is gone, and no digest is emitted — ALWAYS say so in the one-line
  revocation report (`revoked — no digest; trigger [ended — which mechanism]`).
  - **A marker removed MID-TASK by another session is a revocation.** The task-closure check then
    reads `0` on its marker line.
    - **ALWAYS commit the in-flight task, run `/session-end` and end the trigger; NEVER re-create
      the marker.**
  - **A revocation said in ANOTHER session cannot end this session's trigger.** That trigger ends at
    its next firing, through sprint-proposer Step 1's no-marker branch (the arming rule is in C6).

**On a resume whose state is `checkpoint pending` or `stopped`, NEVER open a task.** ALWAYS
re-present the digest and wait. Only an explicit owner answer resumes, and resuming ALWAYS runs
C6's reset step first.

**Audit-cadence equivalence in this mode** — segment mode's "one per phase" has no phases to count:
- **ALWAYS COUNT `ceil(closed / 3)` sessions per window** — the lower bound of the sprint cap, so
  audit coverage NEVER thins as volume grows.
- **ALWAYS WRITE `counts as N sessions for audit cadence` (N = `ceil(closed / 3)` over the window)
  into the Progress Log entry of EVERY stop's `/session-end`** — checkpoint, brake, guardrail,
  exception stop, closure RED and revocation alike. The C6 reset then zeroes the window, so a stop
  that did not write its count erases it for good. sprint-proposer Step 0 is the reader, and
  `project-md-updater` → step 1 is the writer that carries the phrase into the row.
- The idle entry's `counts as 0` is written by C6's idle step, which owns that moment.

**The digest — ALWAYS this format** (it replaces segment mode's final report):

```
## Continuous Checkpoint: [date]
### Stop reason: checkpoint (N closed) | audit due | discovery brake | closure check RED at task N | [guardrail / exception stop]   (revocation emits no digest)
### Closed this window: [N] — one line each: task, result, commit
### Admission (C2 step 2, summed over the window): [+A admitted, +H held, +D deferred]
### Admitted discoveries: [A of cap] — [tasks]
### Deferred discoveries (need you): [task — one line each, or "none"]
### Held for owner: [task — reason, or "none"]
### Closure checks: [N task boundaries, all OK | RED at task X — what was done]
### Scope changes (Step 3a): [task — widened what — admission unchanged | held, or "none"]
### Orchestration lessons (ALWAYS present, "none" is a valid entry): [one line each, `- <type>: <what>`, type ∈ subagent collision | mutator/reader overlap | scratchpad collision | implementer-report gap | stale-premise surprise — distinct from code discoveries; or `none`]
### Parallel dispatches: [group — agent CLASS (MUTATOR/READER, why) — serialized | isolated | parallel; self-check hits N, or "none — every dispatch serial"]
### Audit cadence: counts as [ceil(N/3)] sessions | audit due: [no | yes — proposed]
### Trigger: [ended — which mechanism | still armed — owned by another session; ends at its next firing]
### Tagging writers (re-checked at the last re-entry): [N checked, 0 untagged]
### What I need from you: "continue" | adjust the policy | triage held/deferred | "cancel continuous mode"
```

### C6. Idle and re-entry

- **An empty queue is IDLE, not an end.** When C2 step 2 leaves nothing admitted, ALWAYS write
  `State: idle — queue empty`, run `/session-end` if any task closed since the last one, and end at
  the boundary. The approval stands: the next re-entry picks up newly registered tasks with NO new
  approval. **Idle does NOT end the recurring trigger** — that is the difference from a C5 stop.
  - **ALWAYS WRITE `counts as 0 sessions for audit cadence — continuous window, counted at checkpoint`
    into every idle `/session-end` Progress Log entry.** The window is counted once, by the stop that
    closes it (C5); without the `0`, a reader counting the idle entry as 1 counts the window twice.
  - **A session-scoped trigger dies with its session, and the approval does NOT re-arm it.** ALWAYS
    say so when going idle: `idle — re-entry needs this session open, or /loop /sprint-proposer
    continuous in a new session`.
- **The framework defines the re-entry PROTOCOL — the marker — and NEVER a scheduler**
  (component-design §7: do not rebuild native mechanisms). The recommended trigger is the native
  `/loop /sprint-proposer continuous` in self-paced mode: each firing runs sprint-proposer Steps 0-1,
  which detect the marker and hand off here. A manual invocation or a scheduled session re-enters
  identically, because the marker is the only state.
  - **ALWAYS ARM the recurring trigger — `/loop` or a scheduled session — with the `continuous`
    argument.** It tells sprint-proposer Step 1 that the firing came from this mode's trigger, so a
    firing that finds no marker ends the trigger instead of proposing a sprint — the only way a
    revocation said in another session reaches this trigger (C5).
  - **NEVER pass `continuous` on a manual start of the mode** — the owner starting continuous mode
    asks for it in words (Entry, "Words that DO name continuous mode"), and a bare manual
    `/sprint-proposer continuous` with no marker is read as a trigger firing and ends instead of starting.
  - **ALWAYS fire again immediately while `State: running`.**
  - **ALWAYS wait 20 minutes or more between firings while `State: idle`** — nothing changes faster
    than the owner types.
- **On an owner "continue" OR a policy adjustment after a checkpoint or a stop, ALWAYS RESET BEFORE
  opening a task** — for an adjustment, write the new values into the marker's `**Policy:**` line in
  the same commit. Set
  `**Window:** closed 0 | discovered 0 | admitted-discoveries 0` and `**State:** running`, and
  COMMIT that marker change on its own. It is the `0` the next closure check counts from (C4).
- **ALWAYS re-run the liveness guard AND the C1 tagging-writer check on every re-entry** (Step 1a,
  last item; C1) — a registry can break, and a project can be partially refreshed, between two
  firings. The watchdog's "at loop start" means every start.
- **ALWAYS re-run the task-closure check on every re-entry whose state is `running`, BEFORE opening
  a task.** The previous firing may have died between a commit and its closure check.
  - **Marker `Window` reads `closed 0`** (a fresh marker or a C6 reset, no task closed since) → run
    the BASE check plus this line, which still sees a task committed after the reset without moving
    the counter; the full C4 lines would compare `0` with the value before the reset and read RED on
    a healthy state:
    `git log --first-parent --no-merges --format=%h "$(git log -1 --format=%H -G'^\*\*Window:\*\* closed' -- .claude/phases/project.md)"..HEAD -- . ':(exclude).claude/phases' ':(exclude).claude/logs' | wc -l` → expected `0`.
  - **Otherwise** → the base check AND the C4 lines. A RED here is a C5 stop like any other.
  - **ALWAYS REPORT it in the re-entry announcement** (`closure on re-entry: OK | window 0 — base + later-commit line OK | RED — [output]`).
- **ALWAYS announce the re-entry in one line:** `Resuming continuous mode: state [S], window [N] of
  [checkpoint] closed, queue [Q], closure on re-entry [OK | window 0 — base + later-commit line OK]. Say 'cancel continuous mode' to revoke.`

---

## Final report

Produce the sprint report format from `sprint-proposer` → "Between Tasks", plus these loop-only
lines:

```
### Phases completed: [N/N]  (counts as N sessions for audit cadence)
### Re-sequencing events: [one line each, or "none"]
### Closure checks: [N task boundaries, all OK | RED at task X — what was done]
### Scope changes (Step 3a): [task — widened what — phase cut unchanged | re-sequenced | stopped, or "none"]
### Parallel dispatches: [group — agent CLASS (MUTATOR/READER, why) — serialized | isolated | parallel; self-check hits N, or "none — every dispatch serial"]
### Orchestration lessons (ALWAYS present, "none" is a valid entry):
[one line each, `- <type>: <what>`, type ∈ subagent collision | mutator/reader overlap | scratchpad collision | implementer-report gap | stale-premise surprise — distinct from code discoveries; or `none`]
### Next loop proposal: [the discoveries that queued during this segment]
```

**Why the orchestration-lessons section exists:** the diff-pattern-extractor captures CODE lessons
(it scans the diff) and the session log captures decisions — but "two subagents collided on the
same file" appears in NO diff. Multi-agent execution produces a lesson type the framework's
collectors don't otherwise catch; this fixed section is the capture route, and session-end persists
it (session log + rules-agents-updater routing when a lesson should harden a skill/rule).
**ALWAYS WRITE EACH LESSON AS ONE TYPED LINE, `- <type>: <what>`, with the type taken from the slot's list.**
**NEVER write a typed line for a type that did not occur** (`- scratchpad collision: none`) — the
section's `none` stands alone. A typed negation still matched the counter (this rule's pre-commit
verifier, 2026-09-16).
`session-log-creator` copies these lines into the log's `## Orchestration lessons` section, and
`framework-audit`'s HYPOTHESIS check counts them there by type. Untyped prose counted a negated
"none — no scratchpad collision" as an occurrence and missed a real one phrased differently, and
until 2026-09-16 no log section received the lessons at all, so "session-end persists it" was a claim
with no producer (`/audit` 2026-09-15 B-11, found by its pre-commit verifier).
