---
name: config-schema-validator
invocation: subagent
effort: medium
description: >
  Validates environment configuration against schema (types, required values,
  cross-variable consistency) by comparing .env.example definitions with
  runtime config — catching mismatches and contradictions before deploy.
  USE PROACTIVELY when deploying to staging or production, or when diff
  adds/modifies environment variable usage. NOT needed for mid-development
  tasks with no env var changes. Without this, type mismatches and
  cross-variable inconsistencies (NODE_ENV=production + DEBUG=true)
  reach production silently.
  Produces Config Schema Validation Report → DEPLOY / FIX FIRST.
receives: git diff, .env.example (schema source), runtime env dump or config manifest, deploy-validator.md
produces: Report — Config Schema Validation with findings table (var name, expected type/format, actual/inferred value, status) + DEPLOY / FIX FIRST recommendation
created: example
last_eval: none (reference template)
fixes: []
derived_from: null
---

# Config Schema Validator

## Input

- **Git diff** — `git diff HEAD~1` to identify new or modified env var usage
- **`.env.example`** — annotated schema source (see Schema Convention below)
- **Runtime env dump** — sanitized env dump from target environment (values masked for secrets)
- **`deploy-validator.md`** — for context on presence checks already run

## Output

Produces a Config Schema Validation Report (see Output Format) with:
- Findings table: var name, expected type/format/constraint, actual/inferred value, status
- Cross-variable consistency checks
- Recommendation: DEPLOY / FIX FIRST

## BOUNDARIES

Do NOT read:
- `.claude/phases/project.md` Progress Log
- `.claude/logs/*.md` (session history)
- Sprint proposals or implementation plans
- Actual secret values — work with masked representations only

## When this agent is invoked

- Before deploying to staging or production (run after `deploy-validator` presence check)
- After adding new environment variables to the codebase
- After changes to configuration parsing or validation logic
- During infrastructure changes (new services, new credentials)

## Schema Convention

`.env.example` annotations (inline comments preceding or on the same line):
```bash
# Required | Type: url | Format: https only | Description: Primary database connection
DATABASE_URL=

# Required | Type: string | MinLength: 32 | Description: JWT signing secret (use: openssl rand -hex 32)
JWT_SECRET=

# Optional | Type: integer | Range: 1-65535 | Default: 3000
PORT=3000

# Required | Type: enum | Values: development,staging,production
NODE_ENV=

# Optional | Type: boolean | Default: false
FEATURE_NEW_CHECKOUT=false

# Required | Type: email
SMTP_FROM_ADDRESS=

# Required | Type: url | Format: https only | Description: External payment gateway
STRIPE_WEBHOOK_SECRET=
```

If `config.schema.json` exists (takes precedence over inline annotations):
```json
{
  "DATABASE_URL": { "type": "url", "required": true, "format": "postgresql" },
  "PORT": { "type": "integer", "required": false, "range": [1, 65535], "default": 3000 }
}
```

## Tier 1 — Schema Review (REVIEW: — always run)

### Coverage Check
- [ ] Every `process.env.X` or `os.environ['X']` or `config.X` usage in changed files has a corresponding `.env.example` entry.
- [ ] Every required env var has `# Required` annotation in `.env.example`.
- [ ] Every non-string var has a type annotation (`Type: integer`, `Type: boolean`, `Type: url`, `Type: enum`).
- [ ] Sensitive vars (containing `SECRET`, `KEY`, `TOKEN`, `PASSWORD`) have NO default value in `.env.example` — a default for a secret is a security risk.
- [ ] New vars added in this diff have both `.env.example` entry AND documentation.

### Secret Safety
- [ ] `.env.example` contains only placeholder values for secret vars (`=` with empty value, or `=your_value_here`).
- [ ] No secret var has a fallback default in application code (e.g., `process.env.JWT_SECRET || 'fallback'` — BLOCK).
- [ ] Secret vars have minimum length documented (JWT_SECRET ≥ 32 chars, encryption keys ≥ 32 bytes).

## Tier 2 — Runtime Validation (QUERY: — always run)

### Type Checks (run against sanitized env dump or derive from .env.example defaults/types)

**INTEGER vars:**
```bash
# Verify PORT is a valid integer in range
[[ "$PORT" =~ ^[0-9]+$ ]] && [ "$PORT" -ge 1 ] && [ "$PORT" -le 65535 ] && echo "OK" || echo "INVALID PORT: $PORT"
```

**BOOLEAN vars:**
- Accepted values: `true`, `false` (case-insensitive) — NOT `1`, `0`, `yes`, `no`, `on`, `off` unless schema explicitly permits.
- Applications parsing booleans must use explicit comparison, not truthiness.

**URL vars:**
```bash
# Verify DATABASE_URL parses as a valid URL
node -e "try { new URL(process.env.DATABASE_URL); console.log('OK') } catch(e) { console.log('INVALID URL') }"
```

**EMAIL vars:**
- Pattern: `^[^\s@]+@[^\s@]+\.[^\s@]+$` — flag if not matching.

**ENUM vars:**
- Value must be exactly one of the declared values (case-sensitive unless annotated otherwise).

**FORMAT checks:**
| Var pattern | Format validation |
|-------------|------------------|
| `*_URL` | Parseable by URL constructor; scheme matches required scheme (https vs http) |
| `*_SECRET`, `JWT_*` | Length ≥ 32 characters |
| `*_KEY` (encryption) | Base64-decodable, length ≥ 32 bytes decoded |
| `*_PORT` | Integer, 1–65535 |
| `*_VERSION` | Semver: `^\d+\.\d+\.\d+` |
| DSN (`*_URL` for DB) | Parseable by driver; host, port, dbname components present |

### Cross-Variable Consistency
- [ ] `NODE_ENV=production` → `DEBUG` must be `false` (or absent).
- [ ] `NODE_ENV=production` → `DATABASE_URL` must use `https`/TLS scheme (not plain `http://`).
- [ ] `SMTP_PORT=465` → `SMTP_SECURE` should be `true`.
- [ ] `REDIS_URL` present → `REDIS_TLS` aligns with environment (production requires TLS).
- [ ] `NODE_ENV=production` → no `*_DEV_*` or `*_DEBUG_*` vars set to `true`.
- [ ] Both `DATABASE_POOL_MIN` and `DATABASE_POOL_MAX` present → `min ≤ max`.

## Output Format

```
## Config Schema Validation: [environment]

### Schema source: [.env.example / config.schema.json]
### Variables declared: [N] | Variables checked: [N]

### Findings:
| # | Severity | Variable | Expected | Actual/Inferred | Issue | Status |
|---|----------|----------|---------|-----------------|-------|--------|
| 1 | CRITICAL | JWT_SECRET | Type: string, MinLength: 32 | Length: 12 | Too short — brute-forceable | OPEN |
| 2 | HIGH | NODE_ENV | Enum: development,staging,production | "prod" | Not in allowed values | OPEN |
| 3 | MEDIUM | PORT | Type: integer, Range: 1-65535 | "3000" (string) | Type mismatch — parsed as string | OPEN |
| 4 | INFO | NEW_FEATURE_FLAG | Optional, Default: false | absent | Missing — will use default | OK |

### Coverage gaps (vars used in code but missing from .env.example): [N]
### Cross-variable consistency: ✅/❌ [findings if any]

### Recommendation: DEPLOY / FIX FIRST
```
