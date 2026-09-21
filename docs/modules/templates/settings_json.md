# Template: settings.json

> Create at `.claude/settings.json`

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Edit(CLAUDE.md)",
      "Edit(.claude/**)",
      "Write(.claude/**)",
      "Read",
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(npx *)"
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "node -e \"let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{try{const j=JSON.parse(s),c=j.context_window||{},o=j.cost||{},m=j.model||{};process.stdout.write((m.display_name||'')+' | ctx '+(c.used_percentage!=null?c.used_percentage+'%':'?')+' | $'+Number(o.total_cost_usd||0).toFixed(2))}catch(e){}})\"",
    "padding": 0
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_TOOL_FILE_PATH\" == *.js || \"$CLAUDE_TOOL_FILE_PATH\" == *.ts || \"$CLAUDE_TOOL_FILE_PATH\" == *.jsx || \"$CLAUDE_TOOL_FILE_PATH\" == *.tsx || \"$CLAUDE_TOOL_FILE_PATH\" == *.json || \"$CLAUDE_TOOL_FILE_PATH\" == *.css || \"$CLAUDE_TOOL_FILE_PATH\" == *.md ]]; then npx prettier --write \"$CLAUDE_TOOL_FILE_PATH\" 2>/dev/null || true; fi",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "if [ -f .claude/skills/skill-gate/scripts/skill_gate_hook.sh ]; then bash .claude/skills/skill-gate/scripts/skill_gate_hook.sh; fi",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## Notes

**What this does:** After every file write/edit, if the file is `.ts`, `.tsx`, `.js`, `.jsx`, `.json`, `.css`, or `.md`, Prettier runs automatically. Uses `$CLAUDE_TOOL_FILE_PATH` (native Claude Code environment variable). Diffs stay clean without consuming context.

**Skill-gate hook (second entry):** enforces the component creation gate — when a draft in `.claude/drafts/` is marked `status: ready-for-review`, it blocks (exit 2) with an instruction to spawn the skill-reviewer. Safe to register on ALL tiers: the `[ -f ... ]` guard makes it a silent no-op when the skill-gate skill is not installed (prototype), so tier-gating stays file-presence-based. Exit 2 is required — exit 1 does NOT block.

**Statusline — a meter for the OWNER, never an input to the model.** The harness pipes a JSON
payload to the command on stdin; the command prints the model name, `context_window.used_percentage`
and `cost.total_cost_usd` for the session. It is display only.

**It does NOT touch the context rule, and the scope of that rule is narrower than it looks.**
`autonomous-loop` → "Task closure" (Level 5, **opt-in**) forbids the ORCHESTRATOR to emit
self-estimated context percentages and tells it to ask the owner for the real meter. That
prohibition lives in that skill, applies in loop mode only, and is UNCHANGED. This line simply
gives the owner something to answer with. A displayed measurement and an inferred one are
different things: this number is rendered for a human and never enters the model’s judgement.

**Dependency-free and fail-silent:** plain `node`, no package, no file. Every field is read
defensively — a malformed payload prints nothing and exits 0; an empty JSON object (`{}`) prints
placeholders. **A project without `node` needs no action:** the command is not found, prints
nothing, and the statusline renders empty (verified: exit 127, empty stdout). Dropping the key is
tidiness, never a requirement, and no control reads it either way. `padding: 0` is the documented
default, written out for clarity. No `refreshInterval` is set, so the meter updates on events
rather than on a timer — an idle session shows the last value, not a live one.

**Permissions:** The `allow` rules grant automatic approval for editing framework files (`CLAUDE.md`, `.claude/**`), reading files, and running common commands (`git`, `npm`, `npx`). Prevents permission prompts during end-of-session documentation updates. `bypassPermissions` is the fallback.

**Prerequisite — for the formatter hook only:** Prettier (`npm install -D prettier`). If the project does not use Prettier, drop the Prettier entry and KEEP the skill-gate entry — it has no dependency, and skipping the whole hooks section leaves an installed skill-gate unenforced.

**Merge rule:** If `.claude/settings.json` or `.claude/settings.local.json` already exists, merge the `statusLine` AND `hooks` keys into the existing file rather than overwriting. **An existing `statusLine` is the OWNER’S and is NEVER replaced** — leave it untouched; this one is a default for a project that has none.
