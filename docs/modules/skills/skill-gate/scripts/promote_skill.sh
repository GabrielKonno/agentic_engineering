#!/usr/bin/env bash
# Promotes an approved draft to its official directory.
# REFUSES without a fresh approving verdict — this script, not the hook, is the
# real anti-bypass gate. Run from the project root.
#
# usage: promote_skill.sh <draft-path> [--confirmed]
#   --confirmed  required while rubric.md is in observation mode (owner approved)

set -u
GATE_DIR=.claude/skill-gate
REPORTS="$GATE_DIR/review_reports"
RUBRIC=.claude/skills/skill-gate/rubric.md

refuse() { echo "REFUSED: $1" >&2; exit 1; }

DRAFT="${1:-}"
CONFIRMED="${2:-}"
[ -z "$DRAFT" ] && refuse "usage: promote_skill.sh <draft-path> [--confirmed]"
DRAFT="${DRAFT//\\//}"
[ -f "$DRAFT" ] || refuse "draft not found: $DRAFT"

# --- Resolve source and destination -----------------------------------------
case "$DRAFT" in
  *.claude/drafts/skills/*/SKILL.md)
    NAME=$(basename "$(dirname "$DRAFT")")
    SRC=$(dirname "$DRAFT")
    DEST=".claude/skills/$NAME"
    ;;
  *.claude/drafts/rules/*.md)
    NAME=$(basename "$DRAFT")
    SRC="$DRAFT"
    DEST=".claude/rules/$NAME"
    ;;
  *) refuse "path is not a recognized draft layout: $DRAFT" ;;
esac
[ -e "$DEST" ] && refuse "destination already exists: $DEST (updates are in-place per evolution-policy, not via drafts)"

# --- Verdict checks (the anti-bypass core) -----------------------------------
VERDICT=$(grep -ls "\"draft_path\": \"$DRAFT\"" "$REPORTS"/*.json 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
[ -z "$VERDICT" ] && refuse "no verdict in $REPORTS references this draft — spawn the skill-reviewer first"
[ -n "$(find "$VERDICT" -mmin -60 2>/dev/null)" ] || refuse "newest verdict is older than 60 min ($VERDICT) — re-review before promoting"
grep -q '"approved": true' "$VERDICT" || refuse "newest verdict is not approving ($VERDICT)"
grep -q '"degree": "duplicate"' "$VERDICT" && refuse "verdict flags a duplicate overlap — consolidation is a human decision (register a pendency)"

if ! grep -q '"empirical_claims": \[\]' "$VERDICT"; then
  grep -q '^verified: false' "$DRAFT" || refuse "verdict lists empirical claims but draft frontmatter lacks 'verified: false' — apply the flag first (SKILL.md Step 4)"
fi

if grep -qs '^mode: observation' "$RUBRIC" && [ "$CONFIRMED" != "--confirmed" ]; then
  refuse "gate is in observation mode — promotion needs owner confirmation, then re-run with --confirmed"
fi

# --- Promote (lockfile suppresses the hook during the move) -------------------
mkdir -p "$GATE_DIR" "$(dirname "$DEST")"
trap 'rm -f "$GATE_DIR/.promoting"' EXIT
touch "$GATE_DIR/.promoting"

sed -i '/^status: ready-for-review$/d' "$DRAFT"
mv "$SRC" "$DEST"

FLAGS="none"
grep -qs '^verified: false' "$DEST" "$DEST/SKILL.md" 2>/dev/null && FLAGS="verified:false"
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) PROMOTED $DRAFT -> $DEST verdict=$(basename "$VERDICT") flags=$FLAGS" >> "$GATE_DIR/promotion.log"
echo "Promoted $DRAFT -> $DEST (flags: $FLAGS). Logged in $GATE_DIR/promotion.log."
