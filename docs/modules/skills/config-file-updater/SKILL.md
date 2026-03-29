---
name: config-file-updater
invocation: inline
effort: medium
description: >
  Updates CLAUDE.md when module status, patterns, rules, or File Map change.
  Runs at end of session (item 4) when relevant changes occurred. Keeps the project
  contract accurate — stale config means the AI works with wrong assumptions next session.
created: framework-v1.6.0 (pre-validated)
derived_from: session_protocol end-of-session item 4
---

# Config File Updater (CLAUDE.md)

## When to run
At the END of every session, after pendencias-updater. Only if changes are relevant.

## Process

### 1. Check what changed this session
Review git diff for changes that affect config file sections.

### 2. Update sections as needed

| Section | Update when... |
|---------|---------------|
| **Current state** | Module status changed (⏳ → ✅ or ❌) |
| **Architecture** | Stack choice confirmed or changed |
| **Key Patterns** | New pattern discovered that should be in every review |
| **Build Order** | Phase completed or reordered |
| **File Map** | New files/directories created |
| **Commands** | New dev/build/test commands discovered |
| **MCP Servers** | MCPs added or removed |
| **Skills** | Skills created or installed |
| **Environment Variables** | New env vars needed |

### 3. File Map accuracy
If new files were created, update the File Map section. Run file-map-scan.sh if available:
```bash
bash .claude/skills/config-file-updater/scripts/file-map-scan.sh
```
(Scripts require bash — Git Bash on Windows, native on macOS/Linux. If unavailable, the AI executes the equivalent steps manually.)

### 4. Do NOT update
- Session Protocol (behavior change — requires human approval)
- Execution Protocol (behavior change — requires human approval)
- Information already covered by rules files
