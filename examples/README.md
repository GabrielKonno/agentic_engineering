# Examples

Quality reference templates for creating agents, skills, and rules. The AI consults these before creating new on-demand agents or skills to calibrate structure, depth, and conventions.

**These are templates, not active configuration.** They are always copied to each project's `assets/examples/` during bootstrap (Step 1.5) as read-only reference. When creating new agents or skills, adapt these templates to the project's stack and domain — do not copy verbatim if they are not perfectly suitable.

## Structure

```
examples/
├── README.md                      # This file
├── agents/                        # Agent templates (20 — all categories)
│   ├── accessibility-checker.md   # WCAG 2.1 AA compliance
│   ├── api-security-scanner.md    # Tiered model (Tier 1/2/3), auth, injection, data exposure
│   ├── compliance-auditor.md      # LGPD/GDPR audit, consent, data lifecycle
│   ├── concurrency-tester.md      # Race conditions, transactions, locking, idempotency
│   ├── config-schema-validator.md # Env var validation, type checking, cross-variable consistency
│   ├── data-integrity-checker.md  # Referential integrity, transactions, consistency
│   ├── dependency-auditor.md      # Security vulnerabilities, outdated packages, licenses
│   ├── deploy-validator.md        # Pre-deploy checklist, environment, rollback plan
│   ├── iac-scanner.md             # Infrastructure security: IAM, Docker, network, CI/CD
│   ├── integration-contract-tester.md  # External API contracts, error handling, retry
│   ├── load-tester.md             # Performance under load, p50/p95/p99 latency, throughput
│   ├── migration-runner.md        # Safe migration execution, rollback, verification
│   ├── multi-tenancy-auditor.md   # Tenant isolation, RLS, cross-tenant leak detection
│   ├── oauth-flow-tester.md       # OAuth/OIDC/SAML: state, PKCE, token validation
│   ├── performance-auditor.md     # Data fetching, rendering, DB, bundle optimization
│   ├── sast-scanner.md            # Static analysis: injection, deserialization, path traversal
│   ├── secrets-scanner.md         # Credential detection, high-entropy, lifecycle checks
│   ├── state-machine-verifier.md  # Status workflows, transition matrix, guards
│   ├── test-quality-reviewer.md   # Test quality, false positives, coverage gaps
│   └── visual-regression-tester.md # UI visual regressions, CSS impact, pixel diff
├── skills/                        # Skill templates (9 — Anthropic folder format)
│   ├── nextjs-supabase/
│   │   └── SKILL.md               # Next.js App Router + Supabase (Auth, RLS, Storage)
│   ├── django-postgres/
│   │   └── SKILL.md               # Django + PostgreSQL (ORM, CBV, middleware)
│   ├── express-mongodb/
│   │   └── SKILL.md               # Express.js + MongoDB (Mongoose, JWT, middleware)
│   ├── e-commerce-patterns/
│   │   └── SKILL.md               # Cart, pricing, inventory, orders, payments, refunds
│   ├── scheduling-patterns/
│   │   └── SKILL.md               # Appointments, availability, recurring events, timezones
│   ├── multi-tenancy-patterns/
│   │   └── SKILL.md               # Isolation strategies, data model, scoping patterns
│   ├── api-design-patterns/
│   │   └── SKILL.md               # REST conventions, status codes, pagination, versioning
│   ├── database-migration-guide/
│   │   └── SKILL.md               # Safe operations, data migration, rollback
│   └── ci-cd-pipeline/
│       └── SKILL.md               # GitHub Actions, environments, deploy strategies
└── rules/                        # Domain rules templates (11)
    ├── auth-rules.md              # Auth levels, password reset, token management
    ├── compliance-rules.md        # LGPD/GDPR: consent, erasure, audit trail, retention
    ├── distributed-systems-rules.md # Sagas, idempotency, eventual consistency, event sourcing
    ├── e-commerce-rules.md        # Monetary values, cart, stock, orders, discounts
    ├── frontend-backend-integration-rules.md # Shared types, auth flow E2E, CORS, hydration
    ├── i18n-rules.md              # String extraction, date formatting, RTL, Unicode
    ├── multi-tenancy-rules.md     # Inviolable rules, query patterns, new table checklist
    ├── observability-rules.md     # Structured logging, PII sanitization, tracing, alerts
    ├── rate-limiting-rules.md     # Public endpoint limits, Retry-After, abuse patterns
    ├── resilience-rules.md        # Timeouts, backoff, retry, circuit breaker, error boundaries
    └── scheduling-rules.md        # UTC storage, IANA timezone, DST handling, date boundaries
```

## How to use

### During bootstrap (automatic)
The session0 prompt copies this entire directory to `assets/examples/` in the project. No manual action needed.

### During bootstrap — pre-installation (Step 12.5 + Step 13)
After copying examples, the bootstrap also pre-installs relevant components directly into the project:
- **Specialist agents** (Step 12.5): agents matching kept Coverage Gap Declarations are copied from `assets/examples/agents/` to `.claude/agents/` so the activation chain works from session 1.
- **Domain rules** (Step 13): rules matching PRD domain signals are copied from `assets/examples/rules/` to `.claude/rules/` so code-reviewer conditional checks activate from session 1.

Both are seeded from example templates and refined by `rules-agents-updater` as project-specific patterns emerge.

### When creating on-demand agents/skills (AI reference)
The framework instructs the AI to check `assets/examples/` before creating any new agent or skill:

1. AI identifies need for new agent/skill (reactive or proactive trigger)
2. AI checks `assets/examples/` for a relevant template
3. If found: use as structural reference — adapt to project's stack and domain
4. If not found: create from scratch following the conventions visible in other examples

### Key conventions to follow — PER KIND, verify, do not assume

**A convention stated for one kind is NEVER automatically true of another.** The `**Frontmatter:**`
block below is the AGENT and SKILL contract; **rules examples do not use it at all** — 11 of 11
carry `domain:` / `applies_to:` instead, with no `name:`, `effort:` or `invocation:` field. Read
the per-kind sections and measure before citing any of these as universal (`/audit` K-29, L-31).

**Frontmatter:**
- `name:` — lowercase, hyphenated
- `effort:` — `medium` for checklists and patterns, `high` for security, financial, architectural
- `description:` — explains when to use. Two conventions:
  - **Process skills** (workflow steps): pushy format — `[What]. MUST [trigger]. [Consequence of skipping].`
  - **Knowledge skills** (reference patterns): contextual format — explains when the skill is useful, no imperative trigger
- `invocation:` — how the agent/skill is activated:
  - `subagent` — spawned as an independent process via Agent tool. Isolated context, no access to implementing agent's reasoning. Required for all validation/review/security agents.
  - `inline` — read as a reference document by another agent. Default for skills and knowledge documents.
  - `user` — invoked by the owner as a slash command (`/sprint-proposer`, `/autonomous-loop`,
    `/session-end`, `/context-recovery`, `/commit`, and the tier-gated audits). Used by lifecycle
    skills that OPEN or CLOSE a unit of work rather than being read mid-task by another agent.
- `receives:` — (subagent only) what the orchestrating agent passes: git diff, reports, criteria, file paths
- `produces:` — (subagent only) what the subagent returns: structured report format
- **Lineage fields** (added at creation, maintained during evolution):
  - `created:` — session and context (e.g., `s0 (bootstrap)`, `s5 (reactive: recurring migration pattern)`)
  - `last_eval:` — session of last eval run (e.g., `s0 (2/2 passed)`). Omitted for `invocation: inline` skills.
  - `fixes:` — (optional) list of FIX evolutions applied
  - `derived_from:` — (optional) parent component this was derived from
- **Evolution classification** (logged when components are updated):
  - `FIX` — something failed that should have worked (bug missed, pattern violated)
  - `DERIVED` — something works but can be consolidated (3+ patterns → rules file)
  - `CAPTURED` — pattern observed in real usage (diff-based extraction)

**Instruction style (all components):**
- Behavioral instructions (steps that must always happen) → imperative: "When [trigger], ALWAYS [action] with [format]"
- Mechanism explanations (how the system works) → descriptive: "The system uses X to achieve Y"
- Never bury a behavioral requirement inside a rationale paragraph — give it its own line
- See `component-design.md` § 6 for the full pattern and anti-patterns

**Agents (WHAT to verify):**
- `invocation: subagent` for review/validation/security agents
- `## Input` section — what the agent receives (file paths, reports, criteria)
- An OUTPUT section — structured report format with examples. **Every one of the 20 agent examples
  carries `## Output Format`**; 10 of them ALSO carry a shorter `## Output` summary section ahead of
  it, and 10 carry only `## Output Format`. So it is a STRUCTURAL variance (one output section or
  two), not a spelling variance — grep for `## Output Format` when verifying presence, and for
  either heading when verifying what immediately follows `## Input`
- **`## Input` ALWAYS IMMEDIATELY PRECEDES the output section** — the pair is the agent's contract
  and is read as one unit (verified: 20/20 examples have `## Input` immediately followed by an
  output heading, zero headings between them; that heading is `## Output` in 10 and
  `## Output Format` in 10). The PAIR's position is
  deliberately NOT fixed: it sits near the top in agents whose contract is the first thing a
  reader needs, and just before the verdict line in agents whose checklist dominates the file.
  Either placement is correct; SPLITTING the pair is not
- `## When this agent is invoked` section — clear TRIGGERS (passive: the orchestrator decides invocation)
- `## When spawned` section — a DIFFERENT section, and not a naming variant of the one above: it is
  the activation-chain contract required by component-design §1 (which reviewer gap routes here,
  what context the prompt must carry, what main Claude does with each report outcome). Agents
  reached through a gap declaration carry BOTH sections
- Checklist with `- [ ]` items — actionable, verifiable
- `## BOUNDARIES` section — what the agent must NOT read (anti-bias firewall)
- Recommendation line: APPROVE / FIX REQUIRED / BLOCK — or the domain's equivalent verdict
  vocabulary when a binary approve/fix reads wrong for the measurement (e.g. `load-tester` uses
  WITHIN SLA / DEGRADED / BREACH). The requirement is a single explicit verdict line, not the
  exact words

**Skills (HOW to do) — Anthropic folder format:**
- Each skill is a folder: `skill-name/SKILL.md`
- `invocation: inline` (read by whichever agent needs the knowledge)
- Optional subdirectories:
  - `scripts/` — deterministic executable code (executed without loading into context)
  - `references/` — heavy docs loaded on demand (progressive disclosure)
  - `assets/` — templates, icons, files used in output
- Key patterns with code examples
- Common pitfalls table (Pitfall | Symptom | Fix) — **stack skills**; domain/process-pattern
  skills may carry a domain-appropriate equivalent instead (e.g. `## Verification Queries`)
- **`## Testing` section with framework and conventions — REQUIRED for STACK skills**
  (a stack has a test runner and conventions to state). Domain and process-pattern skills
  (`e-commerce-patterns`, `multi-tenancy-patterns`, `scheduling-patterns`,
  `database-migration-guide`, `ci-cd-pipeline`, `api-design-patterns`) describe patterns that are tested BY the stack,
  not by themselves — for those the section is OPTIONAL and its absence is not a violation
- STRONG criteria examples where applicable

**Rules (WHAT constraints apply):**
- Inviolable rules numbered — non-negotiable boundaries
- Checklists for new entities (new table, new endpoint, etc.) — **where the domain HAS an
  entity-creation flow: **1 of 11** examples carries one; 6 of 11 carry a `- [ ]` checklist of some kind, the other five being `REVIEW:` criteria. The unit is stated because only the looser reading produced 6 (`/audit` 2026-09-04 Q-43).** Its absence is not a violation
- Testing section with verification queries
- Domain-specific edge cases
