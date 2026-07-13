#!/usr/bin/env bash
# PostToolUse hook (Write|Edit) — skill-gate enforcement.
# Fires ONLY for drafts under .claude/drafts/ whose frontmatter carries the
# ready-for-review marker. exit 2 returns stderr to the agent as blocking
# feedback (exit 1 would NOT block — platform semantics).
# Registered in .claude/settings.json guarded by this file's existence, so an
# uninstalled gate (prototype tier) is a silent no-op.

FP="${CLAUDE_TOOL_FILE_PATH:-}"
[ -z "$FP" ] && exit 0
FP="${FP//\\//}"

case "$FP" in
  */.claude/drafts/skills/*|*/.claude/drafts/rules/*|.claude/drafts/skills/*|.claude/drafts/rules/*) ;;
  *) exit 0 ;;
esac

# Anti-recursion: promotion in progress
[ -f .claude/skill-gate/.promoting ] && exit 0

[ -f "$FP" ] || exit 0
grep -q '^status: ready-for-review' "$FP" || exit 0

{
  echo "Skill-gate: draft '$FP' is marked ready-for-review."
  echo "Before continuing, spawn the skill-reviewer subagent per .claude/skills/skill-gate/SKILL.md Step 2"
  echo "(input: the draft + .claude/skills/skill-gate/rubric.md + component index — NOTHING else; sensitive drafts route to red-team)."
  echo "Then act on the verdict: fix and re-review (max 3 cycles), or promote via scripts/promote_skill.sh."
} >&2
exit 2
