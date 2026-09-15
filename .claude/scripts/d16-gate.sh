#!/usr/bin/env bash
# D16 ISOLATION GATE — the ONE definition. `/maintenance` checklist item 3 (pre-commit + receipts)
# and its push gate run THIS file; `/audit` D16 cites it. Never copy its logic into prose.
#
# It reads WHAT GIT PUBLISHES — index blobs, index paths, commit patches, raw commit objects — never
# the working tree, and it never interpolates a pattern into a command line. Both properties are
# the specification change `/audit` 2026-09-14 Run 3 asked for: the previous gate was a shell
# pipeline patched one input class at a time (a path starting with `-`, a staged-then-cleaned leak,
# a `_`-glued part, a regex metacharacter in a folder name, a name present only in a PATH), and each
# verification found the next class (Y-1..Y-7, Y-11).
#
# Usage (from anywhere inside the repository to scan):
#   bash .claude/scripts/d16-gate.sh staged           # the WHOLE index: every blob and every path the next commit carries
#   bash .claude/scripts/d16-gate.sh log <rev-args>   # patches + messages + raw commits + paths: origin/main..HEAD, <first>~1..<last>, --all
#   bash .claude/scripts/d16-gate.sh dir <path>...    # untracked surfaces: .claude/docs/, the agent memory directory
#   bash .claude/scripts/d16-gate.sh selftest         # negation proof: seeds every form in throwaway repos
#
# Output: `staged` / `log` / `dir` print exactly ONE line — `D16 <scope>: N <unit> scanned, H hits`
# (GREEN iff H is 0) or `D16 RED: <reason>`; `selftest` prints one line per case and ends with
# `selftest: K of K cases as expected`. Exit 0 = 0 hits, 1 = hits, 2 = could not check (fails CLOSED).
# It NEVER prints a pattern, a matched line or a matched path: evidence must not paste the value
# (`/audit` 2026-09-10 U-48). Branch on the printed H, never on `&&`.
#
# Every byte is read as TEXT with NUL bytes stripped, in the C locale, with replace refs disabled and
# every git option a user config can flip pinned on the command line. Two independent diff-only
# verifier rounds made earlier versions of this file read 0 over a real leak: a UTF-16 file, a
# `binary` attribute, a NUL byte, color.ui=always, log.showRoot=false, a diff textconv,
# i18n.logOutputEncoding (round 1); a CamelCase folder name, an all-caps part, i18n.commitEncoding,
# an author e-mail, `git replace`, an annotated tag message, a hidden folder (round 2). None wrote to
# stderr. Each is now a selftest case; ADD a case with every new class.
#
# KNOWN LIMITS — each FAILS CLOSED or is out of the scope's contract, never a silent 0:
#   - a folder name with non-ASCII letters: `D16 RED` (case folding is ASCII-only); rename the folder.
#   - a full folder name shorter than 4 characters matches as a substring everywhere: false RED; rename.
#   - a sparse index (index.sparse=true) makes `staged` fail closed on stderr.
#   - `log <range>` reads commits, not tags; tag objects are read only when the args carry --all/--tags.
#     A branch push (`git push origin main`) publishes no tag.
#
# The blocklist is derived from the mother repo's `projects/*/` folder names (hidden ones included)
# at run time, with CamelCase names split like separators (`AcmePortal` -> `Acme_Portal`):
#   FULL  — each name as written, `_`<->`-` swapped, separator-less, space-joined. Regex-escaped, substring.
#   PARTS — split on `_` `-` space, >= 4 chars, generic words stoplisted. Matched at LETTER
#           boundaries, case-insensitive (so `<part>_table` and `x-<part>` hit, "Grafana" does not),
#           plus case-sensitive CamelCase forms (`get<Part>Table`, `<part>Id`, `get<PART>Id`).
# Extend the STOP list for a false positive on an ordinary word; NEVER shrink the identifier set.
set -u
export LC_ALL=C
export GIT_NO_REPLACE_OBJECTS=1
# Pinned git: no colour, no pager, unquoted paths, no signature lines — whatever the user config says.
G() { git -c color.ui=never -c core.quotepath=off -c log.showSignature=false -c diff.relative=false --no-pager "$@"; }

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
SELF="$SELF_DIR/$(basename "$0")"
ROOT=$(cd "$SELF_DIR/../.." && pwd)
STOP='system|page|site|core|base|main|data|admin|trabalho|projeto'

T=$(mktemp -d 2>/dev/null) || { echo "D16 RED: mktemp failed — nothing was checked"; exit 2; }
trap 'rm -rf "$T"' EXIT
: > "$T/err"

fail() { echo "D16 RED: $1 — nothing reliable was checked"; exit 2; }

# Case-insensitivity is built INTO the pattern (`a` -> `[aA]`), never asked of grep with `-i`:
# GNU grep 3.0 (Git for Windows) ABORTS, rc 134, on `-i` with several literal patterns under
# LC_ALL=C, for `-F` and `-E` alike — found by running this file. An abort fails closed, but a gate
# that can never pass gets bypassed.
FOLD='{ o = ""; for (i = 1; i <= length($0); i++) { c = substr($0, i, 1); u = toupper(c); l = tolower(c)
        o = o (u != l ? "[" l u "]" : c) } print o }'
ESC='s/[][\.*^$+?(){}|]/\\&/g'

build() {
  for d in "$ROOT"/projects/*/ "$ROOT"/projects/.[!.]*/; do [ -d "$d" ] && basename "$d"; done \
    | sed 's/^\.*//' | grep -v '^$' | sort -u > "$T/names"
  [ -s "$T/names" ] || fail "no projects/*/ folders under the mother repo — the blocklist is empty"
  grep -q '[^ -~]' "$T/names" && fail "a projects/ folder name has non-ASCII characters, which case folding cannot cover — rename it"
  sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\2/g' "$T/names" > "$T/split"
  cat "$T/names" "$T/split" | sort -u | awk '{ print
         a=$0; gsub(/_/,"-",a); print a
         b=$0; gsub(/-/,"_",b); print b
         c=$0; gsub(/[-_ ]/,"",c); print c
         e=$0; gsub(/[-_]/," ",e); print e }' | sort -u | sed "$ESC" | awk "$FOLD" > "$T/full"
  tr '_ -' '\n\n\n' < "$T/split" | tr 'A-Z' 'a-z' | awk 'length($0)>=4' \
    | grep -vxE "$STOP" | sort -u > "$T/rawparts"
  sed "$ESC" "$T/rawparts" > "$T/parts"
  awk "$FOLD" "$T/parts" | awk '{ print "(^|[^[:alpha:]])" $0 "([^[:alpha:]]|$)" }' > "$T/pi"
  awk '{ c = toupper(substr($0,1,1)) substr($0,2); u = toupper($0)
         print "[a-z]" c "([^a-z]|$)"
         print "(^|[^[:alpha:]])" c "[A-Z]"
         print "(^|[^[:alpha:]])" $0 "[A-Z]"
         print "[a-z]" u "([^A-Za-z]|[A-Z][a-z]|$)"
         print "(^|[^[:alpha:]])" u "[A-Z][a-z]" }' "$T/parts" > "$T/pc"
}

# Three pattern classes: flags then pattern file.
# All three are case-folded or case-sensitive EREs — no `-F`, no `-i` (see FOLD above).
CLASSES='-E:full
-E:pi
-E:pc'

# Count matching lines of a plain text FILE (paths list, log stream). grep rc 0/1 = ok, >1 = error.
count_file() {
  total=0
  while IFS= read -r spec; do
    flags=${spec%%:*}; pf="$T/${spec##*:}"
    [ -s "$pf" ] || continue
    # shellcheck disable=SC2086
    n=$(grep -a $flags -c -f "$pf" -- "$1" 2>>"$T/err"); rc=$?
    [ "$rc" -le 1 ] || return 2
    total=$((total + ${n:-0}))
  done <<EOF
$CLASSES
EOF
  echo "$total"
}

# NUL-stripped text of every blob in the INDEX (gitlinks excluded). Read with cat-file, never
# `git grep`: grep honours `binary` attributes, `-I` and colour config, and each read 0 over a leak.
# Stripping NUL turns UTF-16 text into its ASCII bytes.
index_text() {
  G ls-files -s 2>>"$T/err" | awk '$1 != "160000" { print $2 }' | sort -u \
    | G cat-file --batch 2>>"$T/err" | tr -d '\000'
}

stderr_closed() {
  [ -s "$T/err" ] && fail "$(wc -l < "$T/err" | tr -d ' ') stderr line(s) from the scan (withheld: they may carry a pattern)"
  return 0
}

report() {
  echo "D16 $1: $2 scanned, $3 hits"
  [ "$3" -eq 0 ] && exit 0
  exit 1
}

scope=${1:-}
case "$scope" in
  staged)
    build
    top=$(git rev-parse --show-toplevel 2>/dev/null) || fail "not inside a git repository"
    cd "$top" || fail "cannot enter the repository top level"
    G ls-files > "$T/paths" 2>>"$T/err" || fail "git ls-files failed"
    files=$(grep -c '' "$T/paths")
    index_text > "$T/text" || fail "cannot read the index blobs"
    c1=$(count_file "$T/text") || fail "grep error over the index blobs"
    c2=$(count_file "$T/paths") || fail "grep error over the index paths"
    stderr_closed
    report "staged (index blobs + paths)" "$files files" $((c1 + c2))
    ;;
  log)
    shift
    [ $# -gt 0 ] || fail "log needs revision arguments (e.g. origin/main..HEAD)"
    build
    git rev-parse --git-dir > /dev/null 2>&1 || fail "not inside a git repository"
    G rev-list "$@" > "$T/revs" 2>>"$T/err" || fail "git rev-list rejected the revision arguments"
    commits=$(grep -c '' "$T/revs")
    # Patches (with their diff headers, i.e. paths), full messages in UTF-8, root commits, merges
    # against first parent, binary bodies as text, no textconv / external diff. Added-then-removed
    # inside the range is visible here and in no tree.
    { G log -p --text --root --no-textconv --no-ext-diff --no-color --encoding=UTF-8 \
        --diff-merges=first-parent --format='%H%n%B' "$@" || echo "__D16_LOG_FAILED__"; } 2>>"$T/err" \
      | tr -d '\000' > "$T/text"
    grep -q '^__D16_LOG_FAILED__$' "$T/text" && fail "git log failed"
    # RAW commit objects: author and committer identities, and the message bytes exactly as stored
    # whatever i18n.commitEncoding declared — what a push actually transfers.
    G cat-file --batch < "$T/revs" 2>>"$T/err" | tr -d '\000' >> "$T/text"
    case " $* " in
      *" --all "*|*" --tags"*)
        G for-each-ref --format='%(objectname) %(objecttype)' refs/tags 2>>"$T/err" \
          | awk '$2 == "tag" { print $1 }' | G cat-file --batch 2>>"$T/err" | tr -d '\000' >> "$T/text" ;;
    esac
    G log --name-only --root --format= --diff-merges=first-parent "$@" \
      2>>"$T/err" | sort -u | grep -v '^$' > "$T/paths"
    c1=$(count_file "$T/text") || fail "grep error over the log stream"
    c2=$(count_file "$T/paths") || fail "grep error over the touched paths"
    stderr_closed
    report "log (patches + messages + paths)" "$commits commits" $((c1 + c2))
    ;;
  dir)
    shift
    [ $# -gt 0 ] || fail "dir needs at least one path"
    build
    for p in "$@"; do [ -e "$p" ] || fail "a path argument does not exist (a missing surface reads 0)"; done
    find "$@" -type f > "$T/paths" 2>>"$T/err" || fail "find failed"
    files=$(grep -c '' "$T/paths")
    { find "$@" -type f -exec cat -- {} + || echo "__D16_CAT_FAILED__"; } 2>>"$T/err" | tr -d '\000' > "$T/text"
    grep -q '^__D16_CAT_FAILED__$' "$T/text" && fail "cannot read a file under the directories"
    c1=$(count_file "$T/text") || fail "grep error over the directories"
    c2=$(count_file "$T/paths") || fail "grep error over the file paths"
    stderr_closed
    report "dir (contents + paths)" "$files files" $((c1 + c2))
    ;;
  selftest)
    build
    S=$(mktemp -d 2>/dev/null) || fail "mktemp failed"
    trap 'rm -rf "$T" "$S"' EXIT
    cd "$S" || fail "cannot enter the scratch repo"
    # core.autocrlf OFF and every git stderr discarded: git's CRLF warning quotes the SEEDED PATH,
    # and on its first run this selftest printed all three folder names that way. The whole
    # selftest log is ALSO scanned by this gate before a line of it is printed (below).
    newrepo() { git init -q . && git config core.autocrlf false && git config core.safecrlf false \
      && git config user.email selftest@invalid && git config user.name selftest \
      && git config commit.gpgsign false && git commit -q --allow-empty -m init; }
    newrepo 2>/dev/null || fail "cannot initialise the scratch repo"
    run_selftest() {
    pass=0; total=0; GATE=$SELF
    hits_of() { printf '%s\n' "$1" | sed -n 's/.*, \([0-9][0-9]*\) hits$/\1/p'; }
    reset_index() { git read-tree --empty; find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +; }
    # expect <label> <want: red|green|closed> <scope args...>
    expect() {
      label=$1; want=$2; shift 2
      out=$(bash "$GATE" "$@"); h=$(hits_of "$out"); total=$((total + 1))
      if [ "$want" = closed ]; then
        case $out in "D16 RED:"*) pass=$((pass + 1)); echo "  $label -> fails closed (want closed) ok" ;;
                     *) echo "  $label -> did not fail closed (want closed) FAILED" ;; esac
      elif [ -z "$h" ]; then echo "  $label -> COULD NOT CHECK (want $want)"
      elif [ "$want" = red ] && [ "$h" -gt 0 ]; then pass=$((pass + 1)); echo "  $label -> $h hits (want red) ok"
      elif [ "$want" = green ] && [ "$h" -eq 0 ]; then pass=$((pass + 1)); echo "  $label -> 0 hits (want green) ok"
      else echo "  $label -> $h hits (want $want) FAILED"; fi
    }
    stage_one() { reset_index; mkdir -p -- "$(dirname -- "$1")"; printf '%s\n' "$2" > "./$1"; git add -- "$1"; }
    i=0
    while IFS= read -r name; do
      i=$((i + 1)); echo "project $i:"
      swapped=$(printf '%s' "$name" | tr '_-' '-_')
      sepless=$(printf '%s' "$name" | tr -d '_ -')
      spaced=$(printf '%s' "$name" | tr '_-' '  ')
      stage_one a.md "text $name text";            expect "full name, contents"          red staged
      stage_one a.md "text $swapped text";         expect "swapped _/- form"             red staged
      stage_one a.md "old_${name}_v2";             expect "full name glued by _"         red staged
      stage_one a.md "text $sepless text";         expect "separator-less full name"     red staged
      stage_one a.md "text $spaced text";          expect "space-joined full name"       red staged
      stage_one "notes/$name.md" "clean text";     expect "full name in a PATH only"     red staged
      stage_one "-lead.md" "text $name text";      expect "leak under a path starting -" red staged
      stage_one "sp ace ç.md" "text $name text";   expect "leak under space/accent path" red staged
      stage_one a.md "text $name text"; printf 'clean\n' > a.md
                                                   expect "staged then cleaned on disk"  red staged
      reset_index; printf 'text %s\n' "$name" | iconv -f UTF-8 -t UTF-16LE > a.md; git add a.md
                                                   expect "UTF-16LE file"                red staged
      reset_index; printf '*.md binary\n' > .gitattributes; printf 'text %s\n' "$name" > a.md; git add .gitattributes a.md
                                                   expect "file marked binary"           red staged
      reset_index; printf 'text %s\n\000\n' "$name" > a.md; git add a.md
                                                   expect "file with a NUL byte"         red staged
      stage_one a.md "text $name text"; git config color.ui always
                                                   expect "color.ui=always"              red staged
      git config --unset color.ui
      stage_one a.md "text $name text"; L=$(git rev-parse :a.md); C=$(printf 'clean\n' | git hash-object -w --stdin)
      git replace "$L" "$C";                       expect "blob hidden by git replace"   red staged
      git replace -d "$L" > /dev/null
      part=$(printf '%s\n' "$name" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1_\2/g' | tr '_ -' '\n\n\n' \
             | tr 'A-Z' 'a-z' | awk 'length($0)>=4' | grep -vxE "$STOP" | head -1)
      if [ -n "$part" ]; then
        cap=$(printf '%s' "$part" | awk '{ print toupper(substr($0,1,1)) substr($0,2) }')
        upp=$(printf '%s' "$part" | tr 'a-z' 'A-Z')
        stage_one a.md "an ordinary sentence with $part in it"; expect "surviving part in a sentence" red staged
        stage_one a.md "select * from ${part}_table";          expect "part glued by _"              red staged
        stage_one a.md "const x = get${cap}Table()";           expect "part in CamelCase"            red staged
        stage_one a.md "const x = get${upp}Id()";              expect "all-caps part in CamelCase"   red staged
      else
        echo "  (no part survives the length/stoplist filters — part cases not applicable)"
      fi
      reset_index; git commit -q --allow-empty -m base
      printf 'text %s\n' "$name" > b.md; git add b.md; git commit -q -m add
      git rm -q b.md; git commit -q -m remove
      expect "added then removed inside a range" red log HEAD~2..HEAD
      git commit -q --allow-empty -m "message naming $name"
      expect "full name in a commit MESSAGE"     red log HEAD~1..HEAD
      git config i18n.logOutputEncoding UTF-16
      git commit -q --allow-empty -m "second message naming $name"
      expect "message under logOutputEncoding"   red log HEAD~1..HEAD
      git config --unset i18n.logOutputEncoding
      git -c i18n.commitEncoding=UTF-16 commit -q --allow-empty -m "third message naming $name"
      expect "message under commitEncoding"      red log HEAD~1..HEAD
      git -c user.email="dev@$name.example" commit -q --allow-empty -m plain
      expect "full name in the author e-mail"    red log HEAD~1..HEAD
      reset_index; printf '*.md diff=hide\n' > .gitattributes; git config diff.hide.textconv 'sed d'
      printf 'text %s\n' "$name" > c.md; git add .gitattributes c.md; git commit -q -m textconv
      expect "patch hidden by a textconv"        red log HEAD~1..HEAD
      git config --unset diff.hide.textconv
      reset_index; git commit -q --allow-empty -m base2
      printf 'text %s\n' "$name" > e.md; git add e.md; git commit -q -m leak
      L=$(git rev-parse HEAD); C=$(git commit-tree "HEAD~1^{tree}" -p HEAD~1 -m clean)
      git replace "$L" "$C"
      expect "commit hidden by git replace"      red log HEAD~1..HEAD
      git replace -d "$L" > /dev/null
      R=$(mktemp -d) && ( cd "$R" && newrepo && git config log.showRoot false \
        && printf 'text %s\n' "$name" > r.md && git add r.md && git commit -q -m root ) 2>/dev/null
      cd "$R" && expect "root commit, log.showRoot=false" red log --all
      cd "$S" && rm -rf "$R"
      R=$(mktemp -d) && ( cd "$R" && newrepo && git tag -a v1 -m "tag naming $name" ) 2>/dev/null
      cd "$R" && expect "annotated tag message (--all)"   red log --all
      cd "$S" && rm -rf "$R"
      mkdir -p d && printf 'text %s\n' "$name" > d/n.md
      expect "full name in an untracked dir"     red dir d
      printf 'text %s\n' "$name" | iconv -f UTF-8 -t UTF-16LE > d/n.md
      expect "UTF-16LE file in an untracked dir" red dir d
      rm -rf d
    done < "$T/names"
    echo "invented folder names (a copy of this file under a synthetic mother repo):"
    SM=$(mktemp -d) && mkdir -p "$SM/.claude/scripts" "$SM/projects/AcmePortal" "$SM/projects/.hidden_vault" \
      && cp "$SELF" "$SM/.claude/scripts/d16-gate.sh" && GATE="$SM/.claude/scripts/d16-gate.sh"
    stage_one a.md "select * from acme_portal";     expect "CamelCase folder, snake form"     red staged
    stage_one a.md "see the Acme Portal";           expect "CamelCase folder, spaced form"    red staged
    stage_one a.md "const x = getACMEId()";         expect "CamelCase folder, all-caps part"  red staged
    stage_one a.md "text hidden-vault text";        expect "hidden folder"                    red staged
    stage_one a.md "Grafana systematic pages";      expect "synthetic control"                green staged
    mkdir -p "$SM/projects/Ürsula";                 expect "non-ASCII folder name"            closed staged
    GATE=$SELF; rm -rf "$SM"
    echo "controls:"
    stage_one a.md "Grafana systematic pages database administration"; expect "ordinary words"      green staged
    reset_index; expect "empty index"                                   green staged
    echo "selftest: $pass of $total cases as expected"
    }
    run_selftest > "$T/stlog" 2>/dev/null
    # The selftest's OWN output is evidence and must not paste the value: scan it before printing.
    leak=$(count_file "$T/stlog") || fail "grep error while scanning the selftest output"
    [ "$leak" -eq 0 ] || fail "the selftest output carries $leak identifier line(s) — withheld"
    cat "$T/stlog"
    [ "$total" -gt 0 ] && [ "$pass" -eq "$total" ] && exit 0
    exit 1
    ;;
  *)
    fail "usage: d16-gate.sh staged | log <rev-args> | dir <path>... | selftest"
    ;;
esac
