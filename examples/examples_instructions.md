# Examples

Quality reference templates for creating agents, skills, and rules. The AI consults these before creating new on-demand agents or skills to calibrate structure, depth, and conventions.

**These are templates, not active configuration.** They are copied to each project's `assets/examples/` during bootstrap (Step 1.5) if not perfectly suitable for the project. In this case, will serve as read-only reference.

## Structure

```
examples/
├── agents/
│   ├── quality/                    # Code quality and review agents
│   │   ├── performance-auditor.md  # Data fetching, rendering, DB, bundle optimization
│   │   ├── accessibility-checker.md # WCAG 2.1 AA compliance
│   │   └── test-quality-reviewer.md # Test quality, false positives, coverage gaps
│   ├── domain/                     # Domain-specific verification agents
│   │   ├── state-machine-verifier.md # Status workflows, transition matrix, guards
│   │   ├── data-integrity-checker.md # Referential integrity, transactions, consistency
│   │   └── multi-tenancy-auditor.md  # Tenant isolation, RLS, cross-tenant leak detection
│   ├── ops/                        # Operations and infrastructure agents
│   │   ├── dependency-auditor.md   # Security vulnerabilities, outdated packages, licenses
│   │   ├── migration-runner.md     # Safe migration execution, rollback, verification
│   │   └── deploy-validator.md     # Pre-deploy checklist, environment, rollback plan
│   └── security/                   # Security-focused agents
│       └── api-security-scanner.md # Tiered model (Tier 1/2/3), auth, injection, data exposure
├── skills/
│   ├── stack/                      # Stack-specific patterns
│   │   ├── nextjs-supabase.md      # Next.js App Router + Supabase (Auth, RLS, Storage)
│   │   ├── django-postgres.md      # Django + PostgreSQL (ORM, CBV, middleware)
│   │   └── express-mongodb.md      # Express.js + MongoDB (Mongoose, JWT, middleware)
│   ├── domain/                     # Domain knowledge skills
│   │   ├── e-commerce-patterns.md  # Cart, pricing, inventory, orders, payments, refunds
│   │   ├── scheduling-patterns.md  # Appointments, availability, recurring events, timezones
│   │   └── multi-tenancy-patterns.md # Isolation strategies, data model, scoping patterns
│   └── process/                    # Process and methodology skills
│       ├── api-design-patterns.md  # REST conventions, status codes, pagination, versioning
│       ├── database-migration-guide.md # Safe operations, data migration, rollback
│       └── ci-cd-pipeline.md       # GitHub Actions, environments, deploy strategies
└── rules/                          # Domain rules templates
    ├── multi-tenancy-rules.md      # Inviolable rules, query patterns, new table checklist
    ├── e-commerce-rules.md         # Monetary values, cart, stock, orders, discounts
    └── auth-rules.md               # Auth levels, password reset, token management

## How to use

### During bootstrap (automatic)
The session0 prompt copies this entire directory to `assets/examples/` in the project. No manual action needed.

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
- `description:` — one sentence explaining when to use

**Agents (WHAT to verify):**
- "When to invoke" section — clear triggers
- Checklist with `- [ ]` items — actionable, verifiable
- Output format with structured report template
- Recommendation line: APPROVE / FIX REQUIRED / BLOCK

**Skills (HOW to do):**
- Key patterns with code examples
- Common pitfalls table (Pitfall | Symptom | Fix)
- Testing section with framework and conventions
- STRONG criteria examples where applicable

**Rules (WHAT constraints apply):**
- Inviolable rules numbered — non-negotiable boundaries
- Checklists for new entities (new table, new endpoint, etc.)
- Testing section with verification queries
- Domain-specific edge cases
```
