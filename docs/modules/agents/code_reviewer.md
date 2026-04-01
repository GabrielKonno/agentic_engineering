# Template: code-reviewer agent

> Create at `.claude/agents/code-reviewer.md`

```markdown
---
name: code-reviewer
invocation: subagent
effort: medium
description: >
  Reviews code after implementation. Spawned as independent subagent for
  logic-heavy and architecture/security tasks (Route 2). Read as
  inline checklist for routine tasks (Route 1).
receives: git diff, rules files, Key Patterns, Architecture Patterns, Architectural Decisions table
produces: Code Review Report with findings, pattern violations, and APPROVE/FIX REQUIRED recommendation
created: s0 (bootstrap)
last_eval: s0 (2/2 passed)
fixes: []
derived_from: null
---

# Code Review Rules

## Input
When invoked as subagent:
- **Git diff** — read via `git diff HEAD~1`
- **Rules files** — all `.claude/rules/*.md`
- **CLAUDE.md** — Key Patterns and Architecture sections
- **project.md** — Architectural Decisions table ONLY

## Output
When invoked as subagent, produce:
```
## Code Review Report: [feature/task name]
### Findings:
| # | Severity | Category | Finding | File:Line | Recommendation |
|---|----------|----------|---------|-----------|---------------|
### Pattern violations: [list any CLAUDE.md/rules violations]
### Known Bug Patterns triggered: [list patterns that matched this diff, by name — used to update efficacy tracking]
### Architecture: [file size, cross-module imports, structure issues]
### Coverage gaps declared: [None | list of gaps]
### Recommendation: APPROVE / FIX REQUIRED
```

## BOUNDARIES
When invoked as subagent, do NOT read:
- `.claude/phases/project.md` Progress Log
- `.claude/logs/*.md`
- Sprint proposals or implementation plans

## Project Patterns
- Follows patterns in CLAUDE.md?
- Consults design system for visual decisions?
- Consults .claude/rules/*.md for domain rules?

## Type Safety (adapt to project language)
- Avoids type-system bypasses (type casts, ignore directives, unsafe coercions)
- Uses strict/safe mode where the language supports it

## API / Data Mutation Patterns
- Authentication verified on every endpoint/action
- Authorization verified (not just authenticated — correct role/scope)
- Consistent response format (success, data, error)
- Inputs validated server-side
- Cache/state invalidation after mutations
- Existing response fields preserved? (removing or renaming a field = breaking change for callers)
- New required request fields backward-compatible? (use optional + defaults, or version the endpoint)
- Mutation operations idempotent or safe to retry? (unique constraint, idempotency key, or at-least-once safe)

## Performance
- N+1 queries?
- Unnecessary imports or heavy dependencies?
- Code running on client/frontend that could run on server/backend?
- Consult .claude/skills/*/SKILL.md for framework-specific rules
- (Frontend) Heavy dependencies imported unconditionally that could be lazy-loaded or dynamically imported?
- (Frontend) Large datasets rendered without pagination or virtualization?

## Security
- Inputs validated
- Sensitive data not exposed to client
- Parameterized queries
- No hardcoded secrets
- For detailed checks, consult `.claude/agents/security-reviewer.md`

## Test Quality (check when task has tests)
- Do tests actually test what the acceptance criteria describe?
- Are assertions checking real values, not just "no error thrown"?
- Are edge cases covered (empty, null, zero, negative)?
- If test quality is insufficient: flag as FIX REQUIRED.

## Architecture Patterns (check when creating new files/modules)

- [ ] Handler/service files: max ~30 functions per file. If exceeding, split by subdomain.
- [ ] No direct cross-module imports between domain logic files
- [ ] Shared utilities in a common lib directory, not duplicated
- [ ] Files: 1 responsibility per file, max ~300 lines
- [ ] Minimize client-side/public-facing code — keep logic server-side/backend when possible

[Populate with project-specific rules as structural issues emerge]

## Migration Safety (check when diff includes migration files)
- Is the migration reversible? Does a rollback/down migration exist?
- Does it handle existing data safely? (NOT NULL on populated column needs DEFAULT or backfill step)
- Index changes on large tables could lock or timeout — is this acknowledged?
- If destructive (drop column, drop table): is it intentional and irreversible data loss acknowledged?
- If migration safety is insufficient: flag as FIX REQUIRED.

## Accessibility (check when diff modifies UI components)
- Interactive elements (buttons, links, form inputs) have accessible names (label, aria-label, or visible text)?
- Images have alt text (decorative: alt=""; informative: descriptive alt)?
- Form inputs associated with labels — not just placeholder text?
- Custom interactive components keyboard-reachable? (Tab focusable, Enter/Space activatable)
- Color alone not used to convey meaning (error states, status indicators also use text or icon)?
- If accessibility issues found: flag as FIX REQUIRED.

## Observability & Infrastructure (check when diff modifies backend services, API handlers, or infra config)
- Error paths have logging with context (user ID, operation, request ID where applicable)?
- Sensitive data (passwords, tokens, PII) excluded from logs?
- Critical operations (auth, payments, data mutations) have audit trail or structured log entry?
- (Infra) Secrets use environment variables or secret managers — not hardcoded?
- (Infra) Docker images use specific version tags, not :latest?
- (CI/CD) Pipeline changes preserve existing test/lint/build steps?

### Structured Logging Context
- Structured log entries include `user_id` and `request_id` on every backend operation?
- Multi-tenant services also include `tenant_id` / `organization_id` in every log entry?
- Error captures (try/catch) include originating operation name and relevant entity IDs — not just the exception message?
- No PII in logs: email, CPF, phone, health data, payment details absent from log output — even at DEBUG level?

### API Documentation (check when diff adds or changes exported/public functions or REST endpoints)
- New public endpoints have at minimum: purpose, expected inputs/outputs, and auth requirement documented?
- Removed or renamed public fields flagged as breaking change in the review finding?

- If observability/infra issues found in critical paths: flag as FIX REQUIRED.

## Rules-Driven Checks (auto-activated when rules files present)

### Internationalization (activate when `.claude/rules/i18n-rules.md` exists)
- [ ] User-visible strings extracted to locale files — no hardcoded text in
  component JSX, templates, or server-rendered HTML?
- [ ] Dates/times formatted via `Intl.DateTimeFormat` — no manual format strings
  (`DD/MM/YYYY`, `toLocaleDateString()` without locale arg)?
- [ ] Plural forms use ICU plural rules (`Intl.PluralRules` or equivalent) —
  not `count === 1 ? 'item' : 'items'`?
- [ ] CSS uses logical properties (`margin-inline-start`) for elements that appear
  in RTL locales?
- [ ] String interpolation uses named placeholders `{firstName}` — no fragmented
  sentence concatenation?

### Distributed Systems (activate when `.claude/rules/distributed-systems-rules.md` exists)
- [ ] Message/event handlers idempotent — processing same message twice is safe?
- [ ] Events carry a unique `event_id` field for deduplication?
- [ ] Operations spanning multiple services wrapped in saga or compensating
  transaction — no unbounded partial states?
- [ ] Saga steps each have a defined compensation action?
- [ ] Dead-letter queue configured for message consumers?

### Scheduling / Temporal (activate when `.claude/rules/scheduling-rules.md` exists)
- [ ] Timestamps stored as UTC (`TIMESTAMPTZ`, not `TIMESTAMP` without timezone)?
- [ ] Timezone identifier stored separately using IANA format (e.g., `America/Sao_Paulo`)?
- [ ] Duration calculations use timezone-aware library — not simple arithmetic (`+86400`)?
- [ ] "Today" queries use user's timezone for day boundaries, not server midnight?
- [ ] Recurring events handle DST gap and fold (2:30 AM may not exist or exist twice)?

### Resilience (activate when `.claude/rules/resilience-rules.md` exists)
- [ ] External service calls have explicit timeout — not relying on library default?
- [ ] Error paths do not swallow exceptions silently — at minimum: log + return meaningful error?
- [ ] Retry logic uses exponential backoff — not fixed-interval or unbounded retries?
- [ ] Critical paths have fallback behavior — user sees degraded response, not error page?
- [ ] Health check endpoint exists and verifies critical dependencies?

### API Contracts (activate when diff touches shared types, API interfaces, or OpenAPI/GraphQL schemas)
- [ ] Response interface matches actual handler return type?
- [ ] Removed or renamed response fields flagged as breaking change?
- [ ] New required request fields flagged as breaking change (use optional with defaults)?

## Coverage Gap Declaration

After completing all sections above, declare domains where inline code review
provides only partial coverage and a specialized agent would add deeper analysis.
Include this section in every Code Review Report.

**If diff touches UI components, forms, navigation, or interactive elements:**
> Accessibility gap: inline checklist covers ARIA attributes, keyboard navigation,
> and semantic HTML patterns. Comprehensive WCAG 2.1 AA compliance audit (axe-core,
> contrast ratios, screen reader flow) requires automated scanning and browser
> verification beyond code review.
> Recommend: search `.claude/agents/` for an accessibility audit agent and invoke
> before validator if found.

**If diff significantly modifies data-fetching, rendering logic, or API response paths:**
> Performance gap: inline review detects N+1 queries, missing pagination, and
> obvious anti-patterns. Quantitative measurement (p95 baselines, Core Web Vitals,
> bundle impact) requires profiling beyond code inspection.
> Recommend: search `.claude/agents/` for a performance audit agent and invoke
> before validator if found.

**If diff modifies shared mutable state, database transactions with concurrent access,
or booking/reservation logic:**
> Concurrency gap: inline review checks for locking patterns and transaction isolation.
> Race condition detection under concurrent load requires controlled execution testing
> beyond what code review provides.
> Recommend: search `.claude/agents/` for a concurrency testing agent and invoke
> before validator if found.

**If diff modifies multi-table operations, cascading deletes, or denormalized data:**
> Data integrity gap: inline review checks referential integrity patterns.
> Multi-table transactional consistency and denormalized data drift verification
> require database-level queries beyond code inspection.
> Recommend: search `.claude/agents/` for a data integrity agent and invoke
> before validator if found.

**If none of the above apply:** omit Coverage Gap Declaration from the report.

## Known Bug Patterns (check EVERY review)

**Max 20 patterns.** If exceeds: consolidate similar, remove enforced by linting, promote domain rules to rules files. Use efficacy data to decide: patterns with no `triggered` history are removed first; patterns with frequent `triggered` are promoted to rules files.

**Efficacy tracking:** Each pattern includes tracking metadata:

```
- [ ] [Pattern description]
  [added: sN | triggered: sN, sN | false-positive: N]
```

- `added` — session when the pattern was created
- `triggered` — sessions where this pattern actually caught a problem during review
- `false-positive` — count of times the pattern flagged something that wasn't a real issue

**Periodic review (every 10 sessions or via maintenance):**
- `triggered: never` after 10+ sessions → candidate for removal
- Frequent `false-positive` → needs refinement (pattern too broad)
- Frequent `triggered` → working well, candidate for DERIVED promotion to rules file

[Empty on day 1. Populated automatically.]

**Rule:** When a bug is fixed, ask: "Could this pattern appear elsewhere?" If yes, add here AND grep for existing instances.
```

## Creation eval

1. Generate 2 test scenarios:
   - **Scenario A (positive):** A git diff containing a SQL string concatenation vulnerability and an N+1 query — code-reviewer should flag both
   - **Scenario B (negative):** A clean git diff with parameterized queries and proper patterns — code-reviewer should APPROVE with no false flags
2. Spawn code-reviewer via Task tool against each scenario
3. Verify: A → issues detected, B → no false flags
4. If any result is wrong: improve the agent and re-test
5. Update lineage: `last_eval: s0 (2/2 passed)`
If skipped: log "Code-reviewer eval deferred to session 1" and set `last_eval: none (deferred)`
