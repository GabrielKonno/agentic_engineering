#!/usr/bin/env bash
# Generates a pre-filled session entry with git stats
# Usage: bash session-entry.sh [session-number]

SESSION="${1:-N}"
DATE=$(date +%Y-%m-%d)

echo "### ${DATE} — Session ${SESSION}"
echo ""
echo "**What was done:**"
echo ""
echo "**Decisions made:**"
echo ""
echo "**Bugs found:**"
echo ""

echo "**Files changed:**"
echo '```'
git diff --stat HEAD~1 2>/dev/null || echo "(no prior commit to diff against)"
echo '```'

echo ""
echo "**Commits this session:**"
echo '```'
git log --oneline -10 2>/dev/null || echo "(no commits yet)"
echo '```'

echo ""
echo "**PRD version:** v"
echo ""
echo "**Next step:**"
