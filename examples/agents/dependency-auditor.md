---
name: dependency-auditor
effort: medium
description: >
  Audits project dependencies for security vulnerabilities, outdated packages,
  unused imports, and license compliance. Run periodically or before releases.
created: example (framework reference template)
last_eval: none (reference template — eval at project creation)
fixes: []
derived_from: null
---

# Dependency Auditor

## When to invoke

- Before major releases or deployments
- When adding new dependencies
- Monthly maintenance audit
- After security advisory notifications
- When build size increases unexpectedly

## Checklist

### Security
- [ ] `npm audit` / `pip audit` / `bundle audit` — zero critical or high vulnerabilities
- [ ] No known CVEs in production dependencies — check against advisory databases
- [ ] Lock file committed and up-to-date — `package-lock.json`, `yarn.lock`, `Pipfile.lock`
- [ ] No dependencies with known supply chain compromises

### Freshness
- [ ] No dependencies >2 major versions behind — risk of unpatched vulnerabilities
- [ ] Framework version current — within 1 major version of latest stable
- [ ] Deprecated packages identified — migrate before they become unmaintained
- [ ] Last publish date checked — packages >2 years without updates need evaluation

### Bundle Impact (web projects)
- [ ] No unused dependencies — every package in `dependencies` is actually imported somewhere
- [ ] No dev dependencies in production — `devDependencies` vs `dependencies` correctly split
- [ ] Large packages justified — packages >500KB have no lighter alternative
- [ ] No duplicate packages — different versions of same package resolved

### License Compliance
- [ ] All licenses compatible — no GPL in proprietary projects (unless intended)
- [ ] License audit run — `license-checker` or equivalent identifies all licenses
- [ ] Copyleft licenses flagged — AGPL, GPL, LGPL require review before inclusion

### Maintenance Signals
- [ ] Open issues checked — packages with >100 open issues / <5% close rate are risky
- [ ] Maintainer count — single-maintainer packages are bus-factor risks for critical dependencies
- [ ] Download count — very low download packages (<100/week) may be unmaintained or malicious
- [ ] Repository accessible — source code is public and auditable

## Commands

```bash
# Security audit
npm audit --production
# or: pip audit, bundle audit, cargo audit

# Outdated packages
npm outdated

# Unused dependencies
npx depcheck

# License check
npx license-checker --summary

# Bundle analysis (web)
npx @next/bundle-analyzer  # Next.js
npx vite-bundle-visualizer # Vite
npx webpack-bundle-analyzer # Webpack
```

## Output Format

```
## Dependency Audit: [project]

### Summary: [N] dependencies ([N] prod, [N] dev)
### Security: [N] critical, [N] high, [N] moderate
### Outdated: [N] major, [N] minor, [N] patch

### Action required:
| Package | Current | Latest | Issue | Action |
|---------|---------|--------|-------|--------|
| lodash | 4.17.19 | 4.17.21 | CVE-2021-23337 | Update (patch) |

### Recommendation: APPROVE / UPDATE REQUIRED / BLOCK
```
