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

### Key conventions to follow (visible in all examples)

**Frontmatter:**
- `name:` — lowercase, hyphenated
- `effort:` — `medium` for checklists and patterns, `high` for security, financial, architectural
- `description:` — explains when to use. Two conventions:
  - **Process skills** (workflow steps): pushy format — `[What]. MUST [trigger]. [Consequence of skipping].`
  - **Knowledge skills** (reference patterns): contextual format — explains when the skill is useful, no imperative trigger
- `invocation:` — how the agent/skill is activated:
  - `subagent` — spawned as an independent process via Agent tool. Isolated context, no access to implementing agent's reasoning. Required for all validation/review/security agents.
  - `inline` — read as a reference document by another agent. Default for skills and knowledge documents.
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

**Agents (WHAT to verify):**
- `invocation: subagent` for review/validation/security agents
- `## Input` section — what the agent receives (file paths, reports, criteria)
- `## Output` section — structured report format with examples
- "When this agent is invoked" section — clear triggers (passive: the orchestrator decides invocation)
- Checklist with `- [ ]` items — actionable, verifiable
- `## BOUNDARIES` section — what the agent must NOT read (anti-bias firewall)
- Recommendation line: APPROVE / FIX REQUIRED / BLOCK

**Skills (HOW to do) — Anthropic folder format:**
- Each skill is a folder: `skill-name/SKILL.md`
- `invocation: inline` (read by whichever agent needs the knowledge)
- Optional subdirectories:
  - `scripts/` — deterministic executable code (executed without loading into context)
  - `references/` — heavy docs loaded on demand (progressive disclosure)
  - `assets/` — templates, icons, files used in output
- Key patterns with code examples
- Common pitfalls table (Pitfall | Symptom | Fix)
- Testing section with framework and conventions
- STRONG criteria examples where applicable

**Rules (WHAT constraints apply):**
- Inviolable rules numbered — non-negotiable boundaries
- Checklists for new entities (new table, new endpoint, etc.)
- Testing section with verification queries
- Domain-specific edge cases
