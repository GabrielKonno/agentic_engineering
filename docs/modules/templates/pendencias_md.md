# Template: pendencias.md

> Create at `{CONFIG_DIR}/phases/pendencias.md`

```markdown
# [Project] — Backlog

Last updated: [date]

---

## In Progress

- [ ] Session 0: bootstrap and configuration (THIS SESSION)

---

## Next Steps (in order)

[Derive from Build Order. Every task MUST have acceptance criteria with verifiable tags.]

**Acceptance criteria tags:**
- `BUILD:` — verifiable via build command (zero errors)
- `VERIFY:` — verifiable via browser automation (web) or command execution (non-web). Format: `[page/command] → [action] → [expected result]`
- `QUERY:` — verifiable via database tool (SQL with expected result). Format: `[query] → [expected result]`
- `REVIEW:` — verifiable via code review (pattern in code). Format: `[what to check]`
- `MANUAL:` — NOT automatically verifiable (design, UX, business judgment). For human only.

**Rules:**
- Every task needs at least 1 `BUILD:` criterion
- UI tasks need at least 1 `VERIFY:` criterion with specific page and expected result
- Data tasks need at least 1 `QUERY:` criterion with specific query and expected value
- `MANUAL:` sparingly — only for things truly requiring human judgment
- Criteria describe WHAT to verify, not HOW to implement

**Criteria quality standard (every criterion must have 3 parts):**
1. **Action** — what to do
2. **Expected result** — what success looks like, specifically
3. **Failure signal** — how to know it truly succeeded (not a false positive)

```
❌ WEAK: VERIFY: /clients → click New → form appears
✅ STRONG: VERIFY: /clients → click "New Client" → form with fields name (required),
   phone (optional), email (required). Submit empty → validation errors on name+email.
   Submit valid → redirect to /clients/[id], client visible in list.
```

**Specificity inheritance:** Every criterion must be at least as precise as its source (PRD, design system, rules file, migration schema). If the source defines exact values, the criterion must contain those values. A criterion vaguer than its source is WEAK regardless of having 3 parts.

**Dependency mapping (optional — enables parallelism for multi-agent tools):**
- `depends: [task numbers]` — tasks that must be DONE before this one starts
- `parallel: true` — can run simultaneously with other parallel tasks at same dependency level
- If not declared: defaults to sequential (always safe)

### 1. Project Setup
depends: none
parallel: false

**Context:** Bootstrap task — first step in Build Order. Creates the foundation all other modules depend on.
**State:** Empty project folder, no code exists yet.
**Constraints:** No application code in this task — only scaffolding, configuration, and tooling setup.
**Complexity:** routine

**Changes:**
- Scaffold application ([framework])
- Install dependencies
- Configure database
- Configure environment variables
- Configure deploy pipeline (if applicable)
- Create design system (or import reference)

**Acceptance criteria:**
- [ ] `BUILD:` Project builds with zero errors
- [ ] `VERIFY:` Dev server starts → index page renders with framework default content (not a blank page or error)
- [ ] `QUERY:` Database connection works: `SELECT 1` → returns 1 (if applicable)
- [ ] `MANUAL:` Project structure matches architecture in {CONFIG_FILE} — verify folder layout and key files exist

### 2. [First module from Build Order]
depends: [1]
parallel: true (if independent of task 3)

**Context:** [WHY this task exists — business problem it solves, who uses it, from PRD section X.X]
**State:** [What exists when this starts — which modules are done, what data/tables exist]
**Constraints:** [What NOT to do — known anti-patterns, things that seem right but aren't, architectural limits]
**Complexity:** routine | logic-heavy | architecture/security

**Changes:**
[Features from PRD for this module]

**Acceptance criteria:**
- [ ] `BUILD:` Zero build errors, all tests pass
- [ ] `VERIFY:` [page/endpoint/command] → [main action] → [expected result with specific values/elements]
- [ ] `VERIFY:` [page/endpoint/command] → empty state → [specific empty state message/response]
- [ ] `QUERY:` [specific query] → [specific expected value — this criterion should also become an executable test]
- [ ] `REVIEW:` API handlers follow authentication and authorization patterns defined in {CONFIG_FILE}
- [ ] `MANUAL:` Visual matches design system

### 3. [Second module]
[Same format]

---

## Future Improvements

[Features from PRD marked as out of scope / Phase 2+:]
- [Feature A — PRD section 2.2]

---

## Done

> Completed tasks are moved to `{CONFIG_DIR}/phases/done_tasks.md` with full metadata intact.
> This section stays empty between sessions. The pendencias-updater skill handles the move
> at end of every session (or between tasks during a sprint).
> To check completed tasks: read `done_tasks.md`. To check dependencies on old tasks:
> the sprint-proposer will check `done_tasks.md` automatically.

- [x] PRD created and approved
```
