#!/usr/bin/env bash
# Generates a File Map from the project's directory structure
# Usage: bash file-map-scan.sh [max-depth]

DEPTH="${1:-3}"

echo "## File Map"
echo ""
echo '```'
find . -maxdepth "$DEPTH" -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.next/*' \
  -not -path '*/.git/*' \
  -not -path '*/venv/*' \
  -not -path '*/__pycache__/*' \
  -not -path '*/dist/*' \
  -not -path '*/build/*' \
  -not -path '*/.claude/logs/*' \
  -not -name '*.pyc' \
  -not -name '.DS_Store' \
  | sort
echo '```'
