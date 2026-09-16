#!/usr/bin/env bash
# Creates a session log file with pre-filled git data
# Usage: bash create-log.sh [session-number] [slug]
# Example: bash create-log.sh 12 financial-closing-sprint

SESSION="${1:?Usage: create-log.sh <session-number> <slug>}"
SLUG="${2:?Usage: create-log.sh <session-number> <slug>}"
DATE=$(date +%Y%m%d)
COMMIT=$(git log --oneline -1 2>/dev/null | cut -d' ' -f1 || echo "0000000")
FILENAME="${DATE}_s${SESSION}_${SLUG}_${COMMIT}.md"
LOGS_DIR=".claude/logs"

# Create logs directory if needed
mkdir -p "$LOGS_DIR"

# Generate the log file
cat > "${LOGS_DIR}/${FILENAME}" <<EOF
# Session ${SESSION} — $(date +%Y-%m-%d)

## Summary
[1-2 sentences: goal and outcome]

## Session entry
[the PRD sync:, audit cadence: and loop marker: lines copied verbatim from sprint-proposer, or: none — sprint-proposer did not run (reason)]

## Review receipts
[this session's lines copied from .claude/logs/review-reports/receipts.md, or: none — no reviewer ran]

## Owner decisions
[normative propagation: N owner decisions recorded — K propagated to the PRD | owner decision with no normative effect — (reason) | none — no owner decision recorded]

## Tasks completed
- [task]: [approach, key decisions]

## Decisions made (and why)
- [decision]: [reasoning, alternatives, trade-offs]

## Bugs found and fixed
- [bug]: [root cause, fix, pattern added?]

## Discoveries
- [unexpected findings]

## Orchestration lessons
- none

## Files changed
$(git diff --stat HEAD~1 2>/dev/null || echo "(no prior commit)")

## Commits
$(git log --oneline -20 2>/dev/null || echo "(no commits)")

## Evolutions applied
- [FIX/DERIVED/CAPTURED]: [component] — [what changed and why]

## PRD version: v
## Next session should: [specific next step]
EOF

echo "Created: ${LOGS_DIR}/${FILENAME}"
