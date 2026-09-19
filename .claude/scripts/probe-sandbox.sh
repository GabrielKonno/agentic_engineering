#!/usr/bin/env bash
# PROBE SANDBOX — the ONE definition of WHERE a check that WRITES, a negation proof, a planted bad state
# or a persisted script may execute. `/audit` (Authorized operations, Phase 1, D7.6, D10.0) and
# `/maintenance` (checklist items 5, 6 and 10) run probes THROUGH this file; never copy its logic into prose.
#
# Why it exists (`/audit` 2026-09-16 A-1, A-2): an audit agent executed persisted negation-proof
# scripts from the live repo. Their scratch `cd` failed, nothing stopped them, and the lines after it
# committed planted states in the LIVE repo and PUSHED two of them to the real remote. The contract
# said "NEVER push" only in session text no agent receives, and the only isolation proof on disk,
# `git status --porcelain` unchanged, cannot see a commit that was made, pushed and reset away.
#
# NOT FOR READ-ONLY SCANS. The D16 gate (`d16-gate.sh staged | log | dir`) and read-only git inspection
# run IN PLACE: a clone carries no stash, no live index unless `--staged`, and no gitignored
# `.claude/docs/`, so inside the sandbox they read LESS and report a false 0 (pre-commit verifier,
# 2026-09-17). `d16-gate.sh selftest` already confines itself.
#
# Usage (from anywhere inside the LIVE repository, subdirectories included):
#   bash .claude/scripts/probe-sandbox.sh run [--staged] [--keep] -- <command> [args...]
#   bash .claude/scripts/probe-sandbox.sh selftest     # negation proof: one case per fingerprint part
# Give a persisted script by ABSOLUTE path, extracted OUTSIDE the repo: the sandbox holds only committed
# files (plus the index with --staged), so a relative `negation_proof.sh` does not exist inside it.
#
# `run` does, in this order, and FAILS CLOSED (exit 2, command never started) if any step fails:
#   1. fingerprints the live repo in NON-OVERLAPPING parts, so a RED names what changed and the selftest
#      can prove each part alone: HEAD · refs · reflog (every file under logs/, remote-tracking included)
#      · config (the raw file, so include.path and url.*.pushInsteadOf count) · hooks (hooks/ + info/)
#      · worktrees · objects (loose/packed counts) · index (staged content + skip-worktree/assume flags)
#      · worktree (diff + status incl. untracked) · remote:<name> (`git ls-remote`, or `unreachable`);
#   2. clones the live HEAD into a fresh `mktemp -d` (core.longpaths on — the incident's clone died on
#      "Filename too long"), applies the live index when `--staged` is given, replaces the clone's
#      `refs/remotes/*` with the LIVE repo's own remote-tracking refs and then disables BOTH the fetch and
#      the push URL (a clone of a local path names the live LOCAL branches `origin/*`, so a check reading
#      `origin/main` in the sandbox read the live unpushed `main` — verifier, 2026-09-19), installs a
#      refusing pre-push hook, and mirrors `projects/*/` as EMPTY folders (names only, so the D16 gate
#      can derive its blocklist; no project content is copied);
#   3. asserts the sandbox top level is not the live top level, then runs the command with the sandbox
#      as its working directory and PROBE_SANDBOX set to it;
#   4. fingerprints the live repo again and compares.
# Output: the command's own output (a missing final newline is added), then exactly ONE final line —
#   `probe-sandbox: GREEN — live repo unchanged; command exit N`            (exit = the command's)
#   `probe-sandbox: RED — live repo changed during the probe: <parts>`      (exit 3, whatever the command did)
#   `probe-sandbox: RED — <reason> — nothing was run`                       (exit 2, a setup step failed)
#   `probe-sandbox: RED — command exit N: not found or not executable, or it exited N itself — treat it as not run`
#                                                                           (exit 2, N = 126 or 127; the live repo WAS compared first)
# With --keep, `probe-sandbox: kept at <path>` precedes the verdict on EVERY outcome after the clone.
# Branch on the printed verdict, never on `&&`: a probe that is SUPPOSED to fail exits non-zero on GREEN.
#
# KNOWN LIMITS — stated, never silent:
#   - gitignored paths of the live WORKING TREE (`projects/`, `.claude/docs/`, `settings.local.json`) are
#     not fingerprinted: a probe writing there reads GREEN.
#   - a push BY URL (not by remote name) whose remote ref is restored before the command ends leaves no
#     local trace unless it created local objects: GREEN, while the remote keeps the objects.
#   - a background process the command leaves running is not waited for; a write it makes after the
#     command returns reads GREEN.
#   - anything else writing the live `.git` meanwhile (an IDE's auto-fetch, another session) reads RED:
#     a false RED, never a false GREEN. So does a remote that becomes (un)reachable mid-run.
#   - the clone is checked out under the live repo's `core.autocrlf`, so its line endings can differ from
#     a live worktree checked out under another setting: a probe that counts CR bytes can read differently
#     inside. Text tools that ignore CR (grep, awk, sed on Git Bash) read the same.
set -u
# The CALLER's locale is saved and restored for the command, never the script's own `LC_ALL=C`: under a C
# locale GNU grep refuses `-P`, and a sandboxed D7.6 loop then read "none installed" with a GREEN verdict
# (`/audit` 2026-09-19 C-1). The script keeps `LC_ALL=C` for its OWN fingerprints only.
if [ "${LC_ALL+set}" = set ]; then CALLER_LC_SET=1; CALLER_LC_ALL=$LC_ALL; else CALLER_LC_SET=0; CALLER_LC_ALL=; fi
export LC_ALL=C GIT_TERMINAL_PROMPT=0
with_caller_locale() { if [ "$CALLER_LC_SET" = 1 ]; then LC_ALL=$CALLER_LC_ALL "$@"; else ( unset LC_ALL; "$@" ); fi; }   # never `env -u`: it cannot run a builtin

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
SELF="$SELF_DIR/$(basename "$0")"

red() { echo "probe-sandbox: RED — $1 — nothing was run"; exit 2; }
sum_files() { # $1 = dir; cksum of every file's path and content under it, stable order
  [ -d "$1" ] || { echo none; return; }
  (cd "$1" && find . -type f ! -name '*.lock' | LC_ALL=C sort | while IFS= read -r f; do printf '%s ' "$f"; cksum < "$f"; done) | cksum
}

# One line per part; the parts never overlap (see the header). Paths are ABSOLUTE: `--git-path` is
# relative to the CALLER's directory, and from a subdirectory the reflog part read nothing (verifier, 2026-09-17).
fingerprint() { # $1 = repo top level
  local r=$1 gd rem o
  gd=$(git -C "$r" rev-parse --absolute-git-dir) || return 1
  printf 'HEAD %s %s\n' "$(git -C "$r" symbolic-ref -q HEAD || echo detached)" "$(git -C "$r" rev-parse -q --verify HEAD || echo none)"
  printf 'refs %s\n' "$(git -C "$r" for-each-ref --format='%(refname) %(objectname)' | cksum)"
  printf 'reflog %s\n' "$(sum_files "$gd/logs")"
  printf 'config %s\n' "$(cksum < "$gd/config")"
  printf 'hooks %s %s\n' "$(sum_files "$gd/hooks")" "$(sum_files "$gd/info")"
  printf 'worktrees %s\n' "$(git -C "$r" worktree list --porcelain | grep '^worktree ' | cksum)"   # paths only: the main entry also names HEAD's branch
  printf 'objects %s\n' "$(git -C "$r" count-objects -v | grep -E '^(count|in-pack|packs):' | tr '\n' ' ')"
  printf 'index %s\n' "$( { git -C "$r" diff --cached --binary; git -C "$r" ls-files -v | grep -v '^H '; } | cksum)"
  printf 'worktree %s\n' "$( { git -C "$r" diff --binary; git -C "$r" status --porcelain=v1 --untracked-files=all; } | cksum)"
  for rem in $(git -C "$r" remote); do
    if o=$(git -C "$r" ls-remote "$rem" 2>/dev/null); then printf 'remote:%s %s\n' "$rem" "$(printf '%s' "$o" | cksum)"
    else printf 'remote:%s unreachable\n' "$rem"; fi
  done
}

cmd_run() {
  local staged=0 keep=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --staged) staged=1; shift ;;
      --keep) keep=1; shift ;;
      --) shift; break ;;
      *) red "usage: probe-sandbox.sh run [--staged] [--keep] -- <command> [args...]" ;;
    esac
  done
  [ $# -gt 0 ] || red "no command given"
  local live; live=$(git rev-parse --show-toplevel 2>/dev/null) || red "not inside a git repository"
  live=$(cd "$live" && pwd -P) || red "cannot resolve the live top level"

  local before; before=$(fingerprint "$live" 2>/dev/null) || red "cannot fingerprint the live repo"
  # GLOBAL, never `local`: the EXIT trap fires after this function returns, when a local is gone.
  sb=$(mktemp -d 2>/dev/null) && [ -n "$sb" ] && [ -d "$sb" ] || red "mktemp failed (unusable TMPDIR?)"
  if [ "$keep" = 0 ]; then trap 'rm -rf "${sb:-}"' EXIT; fi
  git clone -q --no-hardlinks -c core.longpaths=true -c core.autocrlf="$(git -C "$live" config core.autocrlf || echo false)" \
    "$live" "$sb/r" 2>/dev/null || red "clone into the sandbox failed"
  [ "$keep" = 1 ] && echo "probe-sandbox: kept at $sb/r"
  if [ "$staged" = 1 ]; then
    git -C "$live" diff --cached --binary > "$sb/staged.patch" || red "cannot read the live index"
    if [ -s "$sb/staged.patch" ]; then
      git -C "$sb/r" apply --index "$sb/staged.patch" 2>/dev/null || red "the staged patch does not apply to HEAD"
    fi
  fi
  # Remote-tracking refs: drop the clone's (they are the live LOCAL branches), copy the live repo's own,
  # then cut both URLs, so an offline `origin/main` read is truthful and a fetch fails closed.
  git -C "$sb/r" remote remove origin 2>/dev/null || red "cannot drop the clone's remote"
  git -C "$sb/r" fetch -q --no-tags "$live" '+refs/remotes/*:refs/remotes/*' 2>/dev/null || red "cannot copy the live remote-tracking refs"
  git -C "$sb/r" remote add origin PROBE-SANDBOX-FETCH-DISABLED || red "cannot disable the fetch URL"
  git -C "$sb/r" remote set-url --push origin PROBE-SANDBOX-PUSH-DISABLED || red "cannot disable the push URL"
  printf '#!/bin/sh\necho "probe-sandbox: push refused inside the sandbox" >&2\nexit 1\n' > "$sb/r/.git/hooks/pre-push" \
    && chmod +x "$sb/r/.git/hooks/pre-push" || red "cannot install the pre-push hook"
  local d
  for d in "$live"/projects/*/ "$live"/projects/.[!.]*/; do
    [ -d "$d" ] && mkdir -p "$sb/r/projects/$(basename "$d")"
  done
  local top; top=$(cd "$sb/r" && cd "$(git rev-parse --show-toplevel)" && pwd -P) || red "cannot resolve the sandbox top level"
  [ "$top" != "$live" ] || red "the sandbox resolves to the live repository"

  local rc
  ( cd "$sb/r" && PROBE_SANDBOX="$sb/r" with_caller_locale "$@" ) | sed -e '$a\'   # a missing final newline would glue the verdict to the output
  rc=${PIPESTATUS[0]}

  local after changed; after=$(fingerprint "$live" 2>/dev/null) || after="fingerprint failed"
  if [ "$before" != "$after" ]; then
    changed=$(diff <(printf '%s\n' "$before") <(printf '%s\n' "$after") | sed -n 's/^> \([^ ]*\) .*/\1/p' | tr '\n' ' ')
    echo "probe-sandbox: RED — live repo changed during the probe: ${changed% }"
    exit 3
  fi
  # 126/127 cannot tell "never started" from "ran and exited 126/127", so the verdict says both (verifier, 2026-09-19).
  case "$rc" in 126|127) echo "probe-sandbox: RED — command exit $rc: not found or not executable, or it exited $rc itself — treat it as not run"; exit 2 ;; esac
  echo "probe-sandbox: GREEN — live repo unchanged; command exit $rc"
  exit "$rc"
}

cmd_selftest() {
  local pass=0 total=0
  S=$(mktemp -d 2>/dev/null) || { echo "selftest: RED — mktemp failed"; exit 2; }   # GLOBAL, for the EXIT trap
  trap 'rm -rf "${S:-}"' EXIT
  # A throwaway LIVE repo: a local bare origin, a second branch at the same commit, a subdirectory,
  # and an ignored project folder holding content.
  ( git init -q --bare "$S/origin.git" && git init -q "$S/live" && cd "$S/live" \
    && git config user.email selftest@invalid && git config user.name selftest && git config commit.gpgsign false \
    && git config core.autocrlf false && printf 'projects/\n' > .gitignore && mkdir sub && echo s > sub/s.txt \
    && echo seed > seed.txt && git add -A && git commit -qm seed && git branch -M main && git branch other \
    && git remote add origin "$S/origin.git" && git push -q -u origin main && git fetch -q origin \
    && mkdir -p projects/zzq-probe && echo content > projects/zzq-probe/inner.txt ) >/dev/null 2>&1 \
    || { echo "selftest: RED — cannot build the throwaway live repo"; exit 2; }
  local L="$S/live"
  restore() {
    ( cd "$L" && git symbolic-ref HEAD refs/heads/main && git reset -q --hard main && git clean -qfd -e projects \
      && git config --unset-all url.x.pushInsteadOf; git worktree remove --force "$S/wt"; git worktree prune \
      ; git update-index --no-skip-worktree seed.txt; rm -f .git/hooks/pre-commit \
      ; git remote set-url origin "$S/origin.git"; git push -q -f origin main; git push -q origin :refs/heads/leak ) >/dev/null 2>&1
  }
  # expect <name> <verdict green|red|closed> <exit or -> <parts expected on RED or -> <dir> <command string>
  expect() {
    local name=$1 want=$2 wantrc=$3 wantparts=$4 dir=$5 cmd=$6 out rc verdict got parts
    total=$((total+1))
    out=$(cd "$dir" && with_caller_locale bash "$SELF" run -- bash -c "$cmd" 2>/dev/null); rc=$?
    got=$(printf '%s\n' "$out" | tail -1)
    case "$got" in
      "probe-sandbox: GREEN"*) verdict=green ;;
      "probe-sandbox: RED — live repo changed during the probe: "*) verdict=red; parts=${got#*the probe: } ;;
      "probe-sandbox: RED"*"nothing was run"|"probe-sandbox: RED"*"treat it as not run") verdict=closed ;;
      *) verdict=none ;;
    esac
    if [ "$verdict" = "$want" ] && { [ "$wantrc" = - ] || [ "$rc" = "$wantrc" ]; } \
       && { [ "$wantparts" = - ] || [ "${parts:-}" = "$wantparts" ]; }; then
      pass=$((pass+1)); echo "ok    $name ($verdict${parts:+: $parts}, exit $rc)"
    else
      echo "FAIL  $name — wanted $want/$wantparts/exit $wantrc, got $verdict/${parts:-}/exit $rc"
    fi
    restore
  }
  echo "contained (the probe misbehaves inside the sandbox — GREEN):"
  expect "benign read"                            green 0 - "$L" 'git status >/dev/null'
  expect "commit inside the sandbox"              green 0 - "$L" 'git commit -q --allow-empty -m probe'
  expect "push from the sandbox is refused"       green - - "$L" 'git push -q origin HEAD:main'
  expect "fail-open cd, then commit (A-2 shape)"  green 0 - "$L" 'cd /nonexistent-probe-dir 2>/dev/null; git commit -q --allow-empty -m rec'
  expect "sandbox is not the live top level"      green 0 - "$L" "[ \"\$(git rev-parse --show-toplevel)\" != \"$L\" ] && [ -n \"\$PROBE_SANDBOX\" ]"
  expect "projects mirrored as names only"        green 0 - "$L" 'test -d projects/zzq-probe && ! test -e projects/zzq-probe/inner.txt'
  expect "output without a final newline"         green 0 - "$L" 'printf abc'
  ( cd "$L" && git commit -q --allow-empty -m ahead ) >/dev/null 2>&1   # live main now AHEAD of its origin/main
  local om; om=$(git -C "$L" rev-parse refs/remotes/origin/main)
  expect "origin/main is the live remote ref, fetch fails closed" green 0 - "$L" "[ \"\$(git rev-parse refs/remotes/origin/main)\" = \"$om\" ] && ! git fetch -q origin 2>/dev/null"
  # SAME ANSWER INSIDE AS IN PLACE: a locale-sensitive probe (`grep -P`) and the locale itself, measured in
  # place under the caller's environment first, then compared inside the sandbox (`/audit` 2026-09-19 C-1).
  PS_EXPECT=$(with_caller_locale bash -c 'printf "%s|%s" "${LC_ALL-unset}" "$(printf "ab\n" | grep -cP "a(?=b)" 2>&1; echo rc=$?)"')
  export PS_EXPECT
  expect "probe sees the caller's locale (grep -P as in place)" green 0 - "$L" '[ "$(printf "%s|%s" "${LC_ALL-unset}" "$(printf "ab\n" | grep -cP "a(?=b)" 2>&1; echo rc=$?)")" = "$PS_EXPECT" ]'
  echo "escapes — each caught by exactly the part named (RED, exit 3):"
  expect "HEAD file rewritten, same commit"       red 3 HEAD      "$L" "printf 'ref: refs/heads/other\n' > \"$L/.git/HEAD\""   # no reflog entry: only HEAD sees it
  expect "tag created"                            red 3 refs      "$L" "git -C \"$L\" tag probe-tag"
  expect "branch switched and back"               red 3 reflog    "$L" "git -C \"$L\" checkout -q other && git -C \"$L\" checkout -q main"
  expect "url.pushInsteadOf planted"              red 3 config    "$L" "git -C \"$L\" config url.x.pushInsteadOf y"
  expect "hook written"                           red 3 hooks     "$L" "printf '#!/bin/sh\n' > \"$L/.git/hooks/pre-commit\""
  expect "worktree added"                         red 3 worktrees "$L" "git -C \"$L\" worktree add -q --detach \"$S/wt\""
  expect "loose object written"                   red 3 objects   "$L" "echo planted | git -C \"$L\" hash-object -w --stdin >/dev/null"
  expect "skip-worktree flag set"                 red 3 index     "$L" "git -C \"$L\" update-index --skip-worktree seed.txt"
  expect "untracked file planted"                 red 3 worktree  "$L" "echo planted > \"$L/leak.txt\""
  expect "push BY URL, no local trace"            red 3 remote:origin "$L" "git -C \"$L\" push -q \"$S/origin.git\" main:refs/heads/leak"
  expect "incident sequence, from a subdirectory" red 3 -         "$L/sub" "git -C \"$L\" commit -q --allow-empty -m leak && git -C \"$L\" push -q origin HEAD:main && git -C \"$L\" reset -q --hard HEAD~1 && git -C \"$L\" push -q -f origin HEAD:main && git -C \"$L\" update-ref refs/remotes/origin/main HEAD"
  echo "fails closed (the command never starts, or never ran):"
  total=$((total+1))
  out=$(cd "$L" && TMPDIR="$S/does-not-exist/deeper" bash "$SELF" run -- bash -c "touch \"$S/ran-anyway\"" 2>/dev/null); rc=$?
  if [ "$rc" = 2 ] && [ ! -e "$S/ran-anyway" ] && printf '%s' "$out" | grep -q 'nothing was run'; then
    pass=$((pass+1)); echo "ok    unusable TMPDIR (closed, exit 2, command not run)"
  else echo "FAIL  unusable TMPDIR — exit $rc, ran=$([ -e "$S/ran-anyway" ] && echo yes || echo no)"; fi
  expect "relative script absent from the sandbox" closed 2 - "$L" 'bash ./negation_proof.sh'
  total=$((total+1))
  ( cd "$L" && echo staged-probe > staged.txt && git add staged.txt ) >/dev/null 2>&1
  out=$(cd "$L" && bash "$SELF" run --staged -- bash -c 'test -f staged.txt && ! git diff --cached --quiet -- staged.txt' 2>/dev/null); rc=$?
  if [ "$rc" = 0 ] && printf '%s' "$out" | tail -1 | grep -q '^probe-sandbox: GREEN'; then
    pass=$((pass+1)); echo "ok    --staged carries the live index (green, exit 0)"
  else echo "FAIL  --staged — exit $rc"; fi
  ( cd "$L" && git reset -q && rm -f staged.txt ) >/dev/null 2>&1
  total=$((total+1))
  out=$(cd "$L" && bash "$SELF" run --keep -- bash -c "echo planted > \"$L/leak.txt\"" 2>/dev/null); rc=$?
  kept=$(printf '%s\n' "$out" | sed -n 's/^probe-sandbox: kept at //p')
  if [ "$rc" = 3 ] && [ -n "$kept" ] && [ -d "$kept" ]; then
    pass=$((pass+1)); echo "ok    --keep names the sandbox on a RED (red, exit 3)"; rm -rf "${kept%/r}"
  else echo "FAIL  --keep on RED — exit $rc, kept=${kept:-none}"; fi
  restore
  echo "selftest: $pass of $total cases as expected"
  [ "$pass" -eq "$total" ]
}

case "${1:-}" in
  run) shift; cmd_run "$@" ;;
  selftest) cmd_selftest ;;
  *) echo "probe-sandbox: RED — usage: probe-sandbox.sh run [--staged] [--keep] -- <command> [args...] | selftest — nothing was run"; exit 2 ;;
esac
