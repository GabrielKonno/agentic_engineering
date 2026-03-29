#!/usr/bin/env bash
# Generates a validation report template structure
# Usage: bash validation-report.sh [feature-name]

FEATURE="${1:-unnamed-feature}"
DATE=$(date +%Y-%m-%d)

cat <<EOF
## Validation Report: ${FEATURE}
### Date: ${DATE}
### What was implemented:
- [describe changes]
### Tests written:
- [test file]: [N] tests covering [what]
### Verification results:
- Build:      ⬜
- Tests:      ⬜
- Review:     ⬜
- Security:   ⬜
- Mutation:   ⬜
- DB:         ⬜
- UI:         ⬜
- Regression: ⬜
- Validation: ⬜
### Items for human verification:
- [MANUAL criteria]
### Next from pendencias.md:
- [next task]
EOF
