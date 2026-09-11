# Framework Maintenance Session

This is a framework maintenance session, not a project bootstrap.

**Authorized operations:**
- Edit files in `docs/` (framework documentation)
- Edit files in `examples/` (reference templates)
- Edit `CLAUDE.md` (framework contract)
- Edit `README.md`
- Edit this repo's OWN runtime under `.claude/` — `commands/`, `rules/`, `skills/`. The framework
  evolves its own session modes here, and several checklist items MANDATE it **by NAME, never by
  ordinal** (`/audit` 2026-09-02 M-52 — an ordinal list here is an inventory surface that goes
  stale on the next insertion): the class sweep, the back-sweep of this repo's own `.claude/`, the
  liveness guard over `.claude/skills/`, and the version bump, whose canonical set includes
  `.claude/commands/existing_project_adaptation.md`. So does the "New component creation"
  section, which places new components under this repo's own `.claude/` when the framework needs
  them at runtime.
- **`git commit` — always. `git push` — ONLY when the owner has asked for it in this session, and
  ONLY after D16 over the unpushed commits comes back GREEN.** NEVER push on your own initiative:
  the unpushed/pushed boundary is what makes a privacy hit cheap or expensive to fix
  (`CLAUDE.md` → Repository Lifecycle; `/audit` 2026-09-02 M-56).
  **ALWAYS REPORT `push:` in the session's closing report and in the persisted receipts** —
  `push: not requested` / `push: requested — D16 [GREEN | RED] over N unpushed commits → [pushed
  sHASH | BLOCKED, reason]`. **NEVER emit nothing.** The gate had a rule and no invoker, no report
  key and no receipt, and it went unhonoured on the very next push 108 seconds after it was
  written (`/audit` 2026-09-03 N-41).
  **THE `push:` VALUE IS A POINT-IN-TIME CLAIM AND IT DECAYS — WITHIN a session AND BETWEEN
  SESSIONS.** The next session ALWAYS re-checks before doing anything else: if `origin/main`
  moved, commits a persisted receipt calls unpushed are now published and the mandated GREEN
  never ran over them.
  **Run D16 over the newly-published range and record it** — that is how
  a live leak was found rather than shipped (`/audit` 2026-09-04 R-26, R-1).
  **ALWAYS RE-CHECK `git status -sb`
  IMMEDIATELY BEFORE WRITING THE CLOSING `push:` LINE.** If `origin/main` advanced during the
  session — someone else pushed, or another session did — then commits this session described as
  unpushed are now PUBLISHED, and the mandated GREEN D16 never ran over any of them. **Re-run D16
  over the newly-pushed range and say so**: `push: not requested; origin/main advanced to sHASH
  mid-batch — D16 re-run over the newly-published range: [GREEN | RED, findings]`. This is not
  hypothetical: it is exactly how an identifier crossed the unpushed→pushed boundary and became an
  accepted-risk record instead of a local fix, while six commits carried receipts reading
  `push: not requested` (`/audit` 2026-09-03 P-32).
  **A D16 hit that is an AUDIT REPORT naming its own OPEN finding does NOT block the push** — the
  finding is the point, and the identifier is already reachable through the instance the finding
  names. Say so explicitly in the `push:` line rather than reading it as GREEN
  (`/audit` 2026-09-03 N-49).
- Write lineage and audit records under `assets/docs/` — Upstream intake step 4 MANDATES the
  lineage doc, and `/audit` Phase 3 writes the dated report a later session applies.

> These last two were executed by nearly every maintenance session long before they were listed.
> The list is the authorization of record: an operation this file mandates elsewhere MUST appear
> here, or the command contradicts itself (found by `/audit` D17, 2026-08-31).

**Rules still in effect:**
- Never modify files inside `projects/` (those belong to project repos)
- All changes must be committed with descriptive messages
- Verify cross-references after modifying any document

**Workflow:** **FIRST re-check `git status -sb`** — if `origin/main` advanced since the last
session, commits a persisted receipt calls unpushed are now PUBLISHED and the mandated D16 GREEN
never ran over them. Mechanical, expected result stated:
`git fetch -q origin && git status -sb | head -1` — **expected: no `behind` segment and
`origin/main` where the last receipt left it; anything else means D16 is owed before any edit.**
The rule was written with no invoker in this sequence and no self-check
(`/audit` 2026-09-04 R-26; `/audit` 2026-09-09 T-29).
**ALWAYS REPORT — `push decay: origin/main unchanged` or `push decay: advanced to sHASH — D16
re-run over the newly-published range: [GREEN | RED, findings]`. NEVER emit nothing.**
Then run Step 0 (upstream discovery sweep) below, read the maintenance prompt/correction
plan provided by the user (an audit report → "Audit intake"; project evolution docs → "Upstream
intake"), apply all changes in order, then run the post-change checklist to completion — **EVERY numbered
item in it, counted in the file** — and commit. The checklist OWNS the version bump, the §5
classification and the new-component gate; **NEVER name those as separate steps here.** Doing so
re-externalizes what the checklist internalized, and enumerating item NUMBERS in this sentence
makes it an inventory surface that goes stale the moment an item is added
(`/audit` 2026-09-02 K-17, L-27).

## Step 0 — Upstream discovery sweep (runs FIRST, in EVERY maintenance session)

Discovery is the one link in the project→framework upstream chain with no mechanical owner:
the project writes the evolution doc and its own framework-audit reminds THE PROJECT, but the
repo that must ACT on it is this one. Without this sweep the chain depends on the owner
remembering — the exact failure class the upstream protocol exists to eliminate.

**ALWAYS run this sweep before any edit, in every maintenance session — including sessions
whose stated task has nothing to do with upstream:**

```bash
grep -L "STATUS.*upstreamed" projects/*/.claude/docs/framework-evolution-*.md 2>/dev/null
```

Expected result: **EMPTY output = nothing pending.** Every path printed is an evolution doc
whose disposition this repo still owes. (Reading `projects/` never violates the no-touch rule.)

**A printed path has TWO possible meanings — ALWAYS separate them before reporting.** The grep
only proves the project has not marked its own header yet; it cannot tell an un-absorbed doc from
one this repo already absorbed and that is merely awaiting the project's own discharge. For EVERY
printed path, grep this repo's lineage records for it:

```bash
grep -rl "$(basename <the printed path>)" assets/docs/framework-evolution-upstream-*.md
```

Anchor on the FULL FILENAME, never on a date or a slug fragment: intake step 4 requires the
lineage record to cite it verbatim, and dates collide across docs.

- **A lineage hit → `absorbed, awaiting project-side discharge`.** NEVER re-absorb it and never
  ask the owner to authorize it again — cite the lineage file and move on.
- **No lineage hit → genuinely `pending absorption`.**

**ALWAYS report the outcome to the owner in one line, even when empty:**
- Empty → `Upstream sweep: 0 pending.`
- Absorbed-but-undischarged only → `Upstream sweep: 0 pending (N awaiting project-side discharge —
  <paths>).` No question follows; nothing is owed by this repo.
- Genuinely pending → `Upstream sweep: N pending — <paths>`, followed by ONE question: does this
  session absorb them (→ "Upstream intake" below), or defer?

**NEVER absorb a pending doc without the owner's answer, and NEVER let the sweep displace the
session's stated task.** A pending doc is a REPORT, not a mandate — deferring is a valid
answer, and the sweep runs again next session.

## Post-change checklist (same session — the periodic /audit is the NET, never the primary)

**Run EVERY numbered item below before committing — count them in the file, never from this
sentence.** (A fixed number here goes stale the moment an item is added, and the items that go
missing are the newest ones — exactly what happened when items 4-6 were added under a header that
still said "three". This checklist is itself an inventory surface; see item 1.)

### EVERY RECEIPT KEY CARRIES ITS COMMAND AND ITS LITERAL STDOUT

**This is the one rule the defect series actually supports, and it is mechanical.**
Measured across the last batch: **every receipt key whose command is quoted in this file and is
re-runnable reproduced exactly — 4 of 4, verified independently by three parties. Every key whose
number was NARRATED failed reproduction — 7 of 7.** Not one control in that batch was discharged by
anyone other than its author (`/audit` 2026-09-04, meta-observation).

**ALWAYS discharge a receipt key as:**
```
**<key>:** <the one-line verdict>
    $ <the exact command, copy-pasteable>
    <its literal stdout, unedited>
```
**NEVER as a sentence containing a number.**
**THE `$` LINE MUST BE THE MANDATED COMMAND, BYTE-FOR-BYTE — NEVER A NARROWED, RE-SCOPED OR
RE-WRITTEN VARIANT OF IT.** `references: 9 of 9` was discharged with the first alternative of the
mandated regex silently DELETED; run verbatim the command returns 47 over that batch, and the
narrowed form returns 22 — neither is 9, and one of the nine printed targets appears nowhere in the
diff (`/audit` 2026-09-10 U-7, third consecutive occurrence of this class). Editing the command to
fit the number is exactly what T-24, installed in the same batch, forbids. **If the mandated command
returns a number you did not expect, the NUMBER is the finding — report it and investigate.**
A number a second reader cannot reproduce by pasting one line is not evidence — it is a claim, and every such claim in the audited batch was wrong.
**THE STDOUT MUST BE THE ACTUAL OUTPUT OF THE QUOTED COMMAND, PASTED — NEVER a parenthetical
standing in for it.** The first key discharged under this rule quoted a grep, showed
"(enumerated by hand)" where its output belonged, and the command actually returns a number
unrelated to the claim (`/audit` 2026-09-09 T-24). A quoted-but-unrun command is strictly WORSE
than a narrated number: it looks reproducible and reproduces something else.
**A key whose discharge has no `$` line is RED**, and `n/a` is a legitimate verdict that still needs
its command (the one that returned nothing).

**Where a key genuinely has no single command** — `classification:`, `new component:` — say so on
the `$` line (`$ n/a — judgement, not measurement`) rather than omitting it. That makes the absence
visible instead of indistinguishable from a forgotten one.

**ALWAYS PERSIST every report line this checklist produces — saying it in the session is not
reporting it.** Each numbered item below ends in an `ALWAYS REPORT` mandate, and a line that lives
only in a transcript cannot be re-read by the `/audit` that verifies this batch, by the next
maintenance session, or by you. Write them ALL, verbatim, into:
- **the audit report file**, under a `## Post-change checklist receipts (sHASH)` heading, when
  this session applied an audit batch (Audit intake's write-back step already writes to that
  file); OR
- **the commit message body**, when there is no report file.

**The receipts section heading is an H2 beginning `## Post-change checklist receipts (`.** THREE
completions are valid: `(sHASH)` for a single-commit batch, `(\`sHASH\`)` — the backticked form,
which 6 of 10 headings on disk actually use — and `(<batch name> — sHASH · sHASH · …)` for the
consolidated form item 6 authorises. **A trailing clause naming anything that is not a hash
(`· and this write-back`) is RED** — the batch is identified by its commits, and a write-back that
changed the report is one of them. The rule admitted two completions while the disk carried three,
and the mismatch was written back `applied` with the file byte-unchanged
(`/audit` 2026-09-04 R-15; re-filed 2026-09-09 T-10). **The self-check
greps the H2 PREFIX, never the full string** — an exact-string rule contradicted the consolidated
form authorised in this same file, and only 2 of 6 headings on disk satisfied it
(`/audit` 2026-09-04 Q-13). The self-check greps for it; writing it at any other level makes the check vacuous.

Mechanical self-check (expected result stated): after committing, over **THIS run's receipts
section only** — the text between that H2 and the next H1/H2, never the whole file — run

```bash
for k in "inventory sweep" "instruction style" "references" "fences" "isolation" \
         "class sweep" "back-sweep" "liveness" "negation proof" "version" \
         "classification" "new component" "gates" "push" \
         "audit" "verification audit" "placeholder" "control back-sweep" \
         "commit correction" "defect series" "applied-proof" "report deletions" "push decay"          "report restore"; do
  printf '%s -> %s
' "$k" "$(grep -cE "^\*\*$k:" <this run's section>)"
done
```

**Expected: every key exactly 1.** A missing key is RED; a duplicate is RED.

**AND, IN THE SAME LOOP, ASSERT THE `$` LINE — the rule above is not a control until this runs.**
```bash
  printf '%s -> keys %s | $-line %s\n' "$k" \
    "$(grep -cE "^\*\*$k:" <this run's section>)" \
    "$(awk -v k="$k" 'index($0,"**"k":")==1{f=1;next} /^\*\*[a-z]/{f=0} f&&/^ *\$ /{n++} END{print n+0}' <this run's section>)"
```
**Expected: every key `$-line >= 1`.** A key with `0` is RED — that is the rule's own stated verdict.
**A `$` line whose command is an angle-bracket description (`$ <the item-6 command>`) or an elision
(`$ for t in …; do ...; done`) counts as ZERO** — it satisfies the shape and defeats the purpose.
Grep them out — **BOTH alternatives ANCHORED to a `$` line**:
`grep -cE '^ *\$ *<|^ *\$ .*(\.\.\.|…)'` over the section → **expected 0**, and name any survivor
with the reason it cannot be written literally.
**NEVER leave the ellipsis alternative unanchored.**
Unanchored, `\.\.\.` matches any line containing three dots — including pasted `## main...origin/main`
stdout — so the check returned **5 where 0 was expected on a healthy section**, and its discharge
then quoted an unadvertised variant that returned 1 (`/audit` 2026-09-10 U-11). KNOWN FALSE
POSITIVE: a genuine git three-dot range (`git log a...b`) on a real `$` line — eyeball it and say so.
**This check did not exist when the `$`-line rule shipped, and the rule's own first discharge
scored 5 of 20 fully compliant — 9 keys with no `$` line at all, including both keys the rule
text explicitly anticipates** (`/audit` 2026-09-09 T-5). component-design §6: a banned process
anti-pattern needs a mechanical self-check, or it does not survive end-of-session context pressure.
**THE KEY LIST IS ITSELF A SURFACE THAT GOES STALE.** Whenever you add an `ALWAYS REPORT`
mandate anywhere in this file, ADD ITS KEY HERE IN THE SAME EDIT. The list stood at 14 while
two mandated keys (`audit:` and `verification audit:`) had no entry, so the check returned
14/14 on receipts that omitted or buried both (`/audit` 2026-09-03 P-1). Mechanical
cross-check, expected result stated:
`grep -oE 'ALWAYS REPORT[^`]*`[A-Za-z][A-Za-z0-9 ._-]*:' "$FILE"` — **every key it returns MUST
appear in the loop above.**
**TWO CHARACTER-CLASS RULES, both learned by this check failing silently:**
1. **Stop at the BACKTICK (`[^`]*`), never at the em-dash.** Nearly every mandate in this file
   reads ``ALWAYS REPORT — `<key>:` ``, and a class excluding `—` cannot reach past it. The
   original form harvested **1 key of 16** and could therefore never fail (`/audit` 2026-09-04
   Q-10).
2. **Key names contain `_`, `.` and `-` (`done_tasks.md:`, `back-sweep:`).** A class of
   `[A-Za-z ]` silently drops them — including the exact key of the finding that created Gate 4
   (`/audit` 2026-09-04 Q-39). Gate 4 below uses the SAME class for the same reason; **change
   both together or neither.**
**THE HARVESTER SEES ONE MANDATE SHAPE, AND THAT IS ITS STATED LIMIT.** It matches
``ALWAYS REPORT … `<key>:` `` on ONE line. Mandates phrased `ALWAYS REPORT all three results —` or
`ALWAYS REPORT the outcome —`, or wrapped across a line break, are invisible to it — **measured, it
reaches only a fraction of the registered keys, and three surfaces once carried three different
figures for this one number** (`/audit` 2026-09-04 R-3, R-4).
**NEVER QUOTE THE FIGURE — RE-MEASURE IT.** It goes stale the moment a key is registered, and it went stale inside the very batch that
changed it, three lines above the loop it describes (`/audit` 2026-09-10 U-33):
```bash
F=.claude/commands/maintenance.md
echo "harvested $(grep -ocE 'ALWAYS REPORT[^`]*`[A-Za-z][A-Za-z0-9 ._-]*:' "$F") of $(sed -n '/^for k in "inventory sweep"/,/^done$/p' "$F" | grep -oE '"[a-z][a-z ._-]*"' | wc -l) registered"
```
**Expected: the harvested number is LOWER than the registered number, and that gap is the stated
limit, not a defect.** Measured 2026-09-11, at the TIP: `harvested 14 of 24 registered`. So:
**ALWAYS write a new report mandate in the
harvestable shape**, on one line, and **ALWAYS report the harvest with its command and stdout**
rather than a remembered figure. The check is a NET for the shape it can see, never a census.
**Negation-proved when installed:** the corrected form went RED on `placeholder:` — a key mandated
in this file and absent from the loop — and the next batch's `commit correction:` escaped it by
wrapping, which is why the shape rule above now exists. A check whose first execution finds a real defect is a check; the one it replaced
had never found anything.

**TWO calibration rules, both learned by this check failing on itself:**
1. **ANCHOR ON THE LINE START (`^\*\*key:`), never the bare token.** The receipts legitimately
   QUOTE these key names — inside the per-fix table, inside the negation-proof prose — so a bare
   `grep -c "new component:"` counts the quotations and goes RED on a healthy discharge. That is
   exactly what happened on this check's first execution (`/audit` 2026-09-02 M-31).
2. **SCOPE TO THIS RUN'S SECTION.** An audit report accumulates one receipts section per run, so a
   whole-file grep counts prior runs' keys — the same miscalibration that shipped as K-8 and L-7,
   and the reason this clause exists.

Evidence this is not hypothetical: for `afccff3`, eight of the nine receipts existed nowhere on
disk, which is why that batch's `negation proof:` claim is unverifiable to this day
(`/audit` 2026-09-02 L-16). A control nobody can re-read afterwards is indistinguishable from one
that never ran — the same proposition `session_rules.md` → "Execution proof" makes about test
suites, which this checklist had never applied to itself.

Each item encodes a real miss that survived a first pass and was only caught by a later lens
(owner question / audit):

1. **Inventory propagation sweep.** When a change ADDS, REMOVES, or RENAMES any framework
   artifact (template, skill, agent, rule, script, command), ALWAYS sweep the FIXED set of
   inventory surfaces in the same session — grep the artifact's name AND the affected counts:
   - CLAUDE.md (Repository Structure tree + any counts)
   - README.md (structure diagram, flow-diagram counts, "What Bootstrap Creates" table)
   - docs/modules/README.md (directory enumerations)
   - docs/agentic_engineering_framework.md (components table + numeric claims)
   - examples/README.md (the conventions it CLAIMS every example exhibits — verify, never assume)
   - **This command file itself:** its Authorized-operations list and any count/enumeration in a
     header above a list you edited. Adding a checklist item, an authorized surface, or a phase to
     a command IS adding an artifact, and the sentence introducing the list is the surface that
     goes stale first.
   - **The sibling command twin:** anything `bootstrap.md` installs,
     `existing_project_adaptation.md` MUST also install (and vice versa) — an artifact added
     to one leaves upgraded-but-not-new projects (or the reverse) silently unprotected.
   Principle (graduated from a source project): correcting/adding a factual claim means
   correcting ALL live copies in the SAME session — executed surfaces first (commands,
   templates the AI obeys), descriptive surfaces second. Grep, never memory.
   **ALWAYS REPORT the result — `inventory sweep: N surfaces checked, M stale claims fixed` or
   `inventory sweep: N/A — no artifact added, removed, renamed or split`. NEVER emit nothing, and
   ALWAYS NAME THE SURFACES** — a bare count cannot be re-measured by the audit that reads it, and
   an unfalsifiable receipt is not a receipt (`/audit` 2026-09-02 M-54).
   A count that lives in PROSE (a NOTE paragraph, an intro sentence) is the one that survives a
   sweep of the diagram — grep the NUMBER across the file, never only the structure.
   **ORDINAL SWEEP — ALWAYS run it when you INSERT or REORDER a numbered item in any list.**
   Inserting an item renumbers every item after it, and every sentence that cites one by ordinal
   ("see step 7", "item 4's class sweep", "per Phase 3 item 5") silently starts pointing at the
   wrong thing. Mechanical self-check (expected result stated): grep the edited file AND the whole
   repo for `step N`, `item N`, `Phase \d item N` for every ordinal at or after the insertion
   point. **SWEEP `assets/docs/` TOO** — the audit reports cite ordinals ("per Phase 3 item 5") and
   one of the two instances this rule was written for lived there; a path list that omits them
   reports GREEN on a state it never measured. **MATCH ALL FIVE FORMS**: `step N`, `step N's`, `item N`, `item N's` and
   `Phase N item M`. **`step N` is not optional — it is the form that actually broke.** The widened
   sweep named three forms, omitted both `step` forms, and the one live casualty of the batch that
   widened it was an `Audit intake step 6` citation (`/audit` 2026-09-03 P-3) — a pattern requiring the possessive misses roughly 60% of real citations.
   **Expected: every hit still names the content it meant.** Two live instances were
   created this way before this rule existed (`/audit` 2026-09-02 L-9, L-15). Where a citation
   would be fragile, cite the item's NAME instead of its number.

2. **Instruction-style check on NEW normative text.** Every new or edited BEHAVIORAL
   instruction (a step the AI must execute every time — in commands, skills, agents, rules)
   MUST satisfy component-design §6 before commit: imperative verb in CAPS
   (ALWAYS/MUST/NEVER), its own dedicated line/bullet (never buried mid-paragraph), explicit
   output/format where applicable. Mechanical assist: re-read every bullet you WROTE this
   session and flag any whose verb is descriptive present tense ("keeps", "verifies",
   "declares") — that is the exact form the audit's dimension C fails.
   **ALWAYS REPORT the result — `instruction style: N of M added imperative lines checked, R
   rewritten, B buried` or `instruction style: N/A — no normative text written`.**
   **NEVER emit nothing.**
   **THE NUMBERS COME FROM THIS COMMAND, NEVER FROM READING** — this key was the LAST one in the
   checklist with neither a command nor a denominator, and it was the only key that failed
   independent re-measurement, at 11 claimed against 29 measured. Item 3 received both in the same
   batch and went from roughly ninefold wrong to roughly 1.2-fold wrong; this key received only a
   unit and stayed exactly as wrong (`/audit` 2026-09-03 P-35, P-22).
   ```bash
   D='git diff --cached -U0'
   M=$($D | grep '^+' | grep -cE '\b(ALWAYS|MUST|NEVER)\b')   # added imperative lines = denominator
   R=$($D | grep '^-' | grep -cE '\b(ALWAYS|MUST|NEVER)\b')   # removed ones = REWRITTEN, not zero
   B=$($D | grep '^+' | grep -cE '[^0-9][.:] +\**(ALWAYS|MUST|NEVER)\b')   # buried: opens a
   # NEW SENTENCE mid-line — a mandate appended to the end of a rationale, which is the exact
   # §6 anti-pattern. **DO NOT define B as "the imperative is not the first token"**: that form
   # fires on the healthy state, flagging this command's own source lines and every wrapped
   # continuation of a mandate that began on the line above. On the batch that installed it the
   # loose form said 10 of 14; the correct form says 2. Calibrated three ways — 8 on a commit an
   # independent re-measurement scored at ≥6 buried, 0 on a pure-record commit, 2 here.
   # `[^0-9]` excludes the ordinal of a numbered list item.
   # KNOWN FALSE-POSITIVE MODE, and it is the framework's own idiom: a mandate legitimately ends
   # ``…`key: value`. NEVER emit nothing.`` — a second imperative sentence closing the same line.
   # That form scores as buried and is NOT a defect; it is the mandated shape. **ALWAYS eyeball the
   # flagged lines before acting: a `B` composed only of `NEVER emit nothing` tails is GREEN.**
   # Measured: it flags 7 of 16 imperative lines in one shipped skill on that idiom alone
   # (`/audit` 2026-09-04 Q-28). Do NOT contort the prose to satisfy it.
   echo "instruction style: $M added, $R rewritten, $B buried"
   ```
   **SCOPE THE COMMAND TO THE SECTION'S OWN DENOMINATOR.** `git diff --cached` reads ONE staged
   diff. A consolidated receipts section covering N commits must run this over the WHOLE batch —
   `git diff <first>~1..<last>` — or its three numbers describe one commit while the section
   declares N. That mismatch shipped: a receipt claimed `14 added, 5 rewritten, 0 buried` over a
   seven-commit section whose true figures were 51 / 17 / 5, and `B` — the finding key — was
   reported as 0 against a measured 5 (`/audit` 2026-09-04 Q-27).
   **ALWAYS state the range the
   numbers came from, beside the numbers.**
   **`R` is almost never 0** — a batch that edits normative text removes imperative lines, and
   three consecutive receipts claimed `0 rewritten` against a measured 12, 13 and 19. **`B` is the
   finding**: an imperative that is not the first thing on its line is buried, which is exactly the
   §6 anti-pattern this item exists to catch. Report all three, and ALWAYS STATE THE UNIT (e.g. "a line carrying a CAPS imperative a session must
   execute") — without it the number is not reproducible and the receipt is unauditable
   (`/audit` 2026-09-02 M-54).

3. **Reference & isolation verification** (as already required by Upstream intake step 6,
   but for EVERY maintenance change, not only upstreams): cross-references resolve (grep
   each named section/file you cited), template fence extraction still works
   — **MATCH THE FENCE WIDTH THE TEMPLATE ACTUALLY USES, and ALWAYS STATE THE DENOMINATOR
   (`N of M templates`).** Templates carry 3-BACKTICK fences unless their content nests a code
   block, in which case they carry 4; a command hard-coded to one width returns 0 on the other
   and reports a silent pass on a surface it never read — the very failure this item's own
   closing sentence warns about, found live in this item's own command, where it returned 0 on
   4 of the 7 templates (`/audit` 2026-09-03 N-50). The 8 files bootstrap actually extracts by `sed` all carry 4 backticks, so nothing ships broken — the defect is in the CHECK, which reports a pass on templates it never read. Width-agnostic form — it reads each
   template's OWN opening fence instead of assuming one:
   ```bash
   for t in docs/modules/templates/*.md docs/modules/rules/*.md; do   # BOTH — rules are extracted too
     f=$(grep -m1 -oE '^`{3,5}[a-z]*' "$t"); c=${f%%[a-z]*}
     echo "$t -> $(sed -n "/^$f$/,/^$c$/p" "$t" | wc -l) lines"
   done
   ```
   **Expected: every template non-zero.** A `0` is RED — either the fence broke or the command
   does not match it, and BOTH are failures, and the D16 isolation grep runs over every touched file (no project names,
   no source-project session numbers, no single-project vocabulary).
   **ALWAYS REPORT all three results, EACH ON ITS OWN LINE** — the receipts self-check greps
   `^\*\*<key>:`, so a single pipe-joined line scores 1/0/0 and a format-compliant discharge reads
   RED (`/audit` 2026-09-03 P-5). Write them as:
   `**references:** N of M cited sections resolved`
   **M COMES FROM THIS COMMAND, NEVER FROM THE RECEIPT'S OWN ENUMERATION.** The denominator is
   every distinct citation target in the BATCH DIFF; counting the receipt's own list instead is how
   `9 of 9` was reported against a measured 22 (`/audit` 2026-09-09 T-21), one run after the same
   key was `14 of 14` against ≥42:
   ```bash
   git diff <first>~1..<last> | grep '^+' \
     | grep -ohE '`[A-Za-z0-9_./-]+\.md`|component-design §[0-9]+|D[0-9]+\.[0-9]+[a-z]?|Phase [0-9]+ item [0-9]+' \
     | sort -u | wc -l
   ```
   `**fences:** N of M templates extract non-empty`
   `**isolation:** N files scanned, 0 hits`.
   **ALWAYS STATE THE UNIT for `references:` and ALWAYS give it a DENOMINATOR** — the unit is
   *a distinct section or file path cited by text this session WROTE*, and M is every such citation
   in the diff, counted by a command. Without a denominator the number drifts free of the batch: a
   receipt reported `references: 4` for a batch whose diff carried ≥35 distinct citation targets,
   and the figure went DOWN as the batch grew (`/audit` 2026-09-03 N-3). The M-54 unit-stating fix
   reached items 1 and 2 and skipped this one. NEVER emit nothing, and
   NEVER collapse the three into one verdict** — a fence check that silently returned 0 lines is
   the failure this item exists to catch, and a merged "verified" hides it.

4. **Class sweep of every POINT FIX applied this session — the four directions.** Item 1
   fires on adding an *artifact*; item 5 fires on promoting a *rule*. Applying a fix named by an
   audit report or an owner correction fires NEITHER — and it is the most common maintenance
   operation there is. A report names ONE line; the line is almost never the only one. So for
   EVERY fix applied this session, ALWAYS sweep all four directions before committing:
   - **LATERAL** — the same defect class in sibling files. Grep the pattern, not the path
     (a subagent told to spawn a subagent; a redirect with no `mkdir`; a stale count).
   - **PARALLEL** — the sibling command twin, and sibling members of the same set (all 11 rules
     examples, all 20 agent examples), not only the one the report named.
   - **ADJACENT** — the lines immediately AROUND the edit: the header above the list, the
     authorization paragraph above the new permission, the intro sentence that states a count.
   - **DESCENDING** — the same defect one level down: if a step now MUST report something, does
     the report template have a field for it?
   **ALWAYS REPORT the result as a PER-FIX RECEIPT — one row per finding ID, never one aggregate
   line for the session.** An aggregate cannot be wrong about a single fix among thirty, which is
   precisely why three consecutive sessions emitted an honest aggregate while missing a direction
   on individual fixes. The table is the control; the total is not.

   | Fix ID | Commit | File touched | LATERAL | PARALLEL | ADJACENT | DESCENDING | Extra instances found |
   |--------|--------|--------------|---------|----------|----------|------------|----------------------|
   | [K-3]  | [sHASH] | [path, or `none — deferred`] | ✓ / ✗ / n/a | ✓ / ✗ / n/a | ✓ / ✗ / n/a | ✓ / ✗ / n/a | [what, where] |

   **THE TEMPLATE ROW HAS THE SAME CELL COUNT AS THE HEADER — COUNT THE PIPES BEFORE COMMITTING.**
   Mechanical self-check (expected result stated): over the three lines above,
   `awk -F'|' 'NF{print NF-2}'` → **expected: three identical numbers.** The fix for the
   missing 8th column instead left the row with THREE cells and welded the other five onto the
   end of the paragraph below — an insert made INSIDE a table row, which is strictly worse than
   the defect it repaired and survived a passing class sweep (`/audit` 2026-09-09 T-7).

   **A GROUP TABLE IS PERMITTED for a multi-commit batch ONLY WITH THESE COLUMNS:
   `Group | Commit | Findings | File(s) touched`**, plus the sweep and its result. **Gate 2
   checks `File(s) touched` against `git show --name-only` PER HASH**, so a group table without
   that column makes Gate 2 unrunnable — which is what shipped, and run per hash it went RED on
   a row attributing a finding to a commit that never touched that finding's file
   (`/audit` 2026-09-04 R-6). **Every finding appears in exactly one row's `Findings` cell, and
   the union of those cells MUST equal the ledger's disposed set** — check it, never assert it.

   Use `✓` (ran — and **ALWAYS QUOTE the actual grep pattern or command in the cell**, never a
   bare glyph: an unquoted `✓` is unverifiable by anyone but its author), `✗` (NOT run —
   legitimate ONLY with a stated reason on the same row), or `n/a` (the direction cannot apply,
   e.g. the artifact has no twin). **A row with a `✗` and no reason is RED. A `✓` with no quoted
   pattern is RED.**
   **Mechanical self-check (expected result stated), STATED PER FORM — the two tables count
   different things and one rule cannot govern both (`/audit` 2026-09-09 T-26):**
   - **PER-FIX table:** row count MUST equal the number of findings applied this session.
   - **GROUP table:** row count equals the number of COMMITS, and it is the union of the
     `Findings` cells that MUST equal the findings applied. Report BOTH —
     `rows N = commits N | findings-union M = disposed M`. A group table reporting
     `row-count 45 vs 45` over three rows is asserting the per-fix rule it does not satisfy.
     **DERIVE THE COMMIT COUNT FROM GIT, NEVER FROM THE TABLE.** Both sides of `rows N = commits N`
     were read off the same table, so the check had NO RED STATE and was discharged `4 = 4` over a
     SEVEN-commit batch, leaving two commits in no receipts table at all
     (`/audit` 2026-09-10 U-15, U-14):
     ```bash
     git log --oneline <first>~1..<last> | wc -l              # commits in the batch - FROM GIT
     git log --format=%s <first>~1..<last> \
       | grep -cE '^(chore: bump to v|chore: substitute s)'   # item-7 EXEMPT commits
     ```
     **Expected: `rows` = commits - exempt, and EVERY exempt commit NAMED on its own line.** An
     exemption that is not named is indistinguishable from a commit that was forgotten.

   **MERGING TWO FINDINGS INTO ONE ROW is how a fix whose sweep was skipped disappears into a
   neighbour** (`/audit` 2026-09-02 L-23: 17 findings reported in 14 rows) - **this rule governs
   the PER-FIX table**, and it sat inside the GROUP bullet as splice residue, carrying a
   form-agnostic rule inside the bullet that exists to say one rule cannot govern both forms
   (`/audit` 2026-09-10 U-37). If two findings genuinely share one fix, give them one row each
   and write "same edit as [ID]" in the last column.
   **ALWAYS NAME, IN EACH ROW, THE FILE THAT ROW EDITED** (a `File touched` column). A row that
   names no file cannot be checked against the commit, and that is what gate 2 below checks.
   Close with the total:
   `class sweep: N fixes × 4 directions, M extra instances found and fixed`, or
   `class sweep: N/A — no point fixes this session`. **NEVER emit nothing, and NEVER emit the
   total without the table.**

   ### The four PRE-COMMIT GATES — run all four, in this order, before `git commit`

   These are not sweeps and not judgement. Each is one command with one expected result, and each
   was written because a HIGH finding got past every other control in this checklist. **A RED gate
   BLOCKS the commit** — fix, re-run, then commit.

   **Gate 1 — TWIN PARITY.** For every `docs/modules/` ↔ `.claude/` twin pair:
   ```bash
   diff -r .claude/skills/cross-cutting-analysis docs/modules/skills/cross-cutting-analysis
   ```
   **Expected: no output (exit 0).** Editing one placement and not the other breaks
   CLAUDE.md's dual-placement rule, dimension A and D10.4 in a single edit — and it is invisible
   to every sweep that greps by pattern, because the pattern is present in one copy
   (`/audit` 2026-09-03 N-6).

   **Gate 2 — EVERY RECEIPT ROW NAMES A FILE THE COMMIT TOUCHED.**
   ```bash
   git show --name-only --format="" HEAD    # or the staged set, pre-commit
   # CONSOLIDATED FORM: a batch table spans several commits, so HEAD reaches only the last one.
   # Run it PER HASH from the `Commit` column, each row against ITS OWN commit. One HEAD run over
   # a six-commit table reaches 1 row of 36 and passes vacuously (`/audit` 2026-09-04 Q-12).
   ```
   **Expected: every `File touched` cell in the per-fix receipt appears in that list.** A row
   naming a file absent from the diff is RED and means the fix was not made. This is the ONLY gate
   that catches a fix that was declared, receipted, counted in a passing self-check and never
   applied — which happened, undetected, in a batch whose row-count check read `43 = 43`
   (`/audit` 2026-09-03 N-34).

   **PER FINDING, NOT ONLY PER ROW — NEVER WRITE `applied <hash>` FOR A FINDING WHOSE LINE THE
   BATCH DID NOT TOUCH.** The row-level form above compares the receipt's `File(s) touched` cell
   to the diff; it cannot see a finding sharing a row with others whose own line was never edited.
   **ALWAYS run this before writing any status back:**
   **STATE THE LINE NUMBERING, OR THE GATE READS RED ON A HEALTHY BATCH.** A ledger `Location`
   cell is a **PRE-BATCH** line number — it was written by the audit, against the tree BEFORE any
   fix. `git log -L` resolves its argument against the **TIP** of the range, where the same number
   points at different text. Run with the ledger's own numbers, the first form of this gate read
   RED on **23 of 38** parseable IDs of a batch four of which were independently confirmed FIXED:
   the K-8/L-7 inversion, in the gate installed to close that class (`/audit` 2026-09-10 U-1).
   **ALWAYS resolve the pre-batch line to its TEXT first, and pickaxe on the text:**
   ```bash
   # FORM A — PREFERRED. Anchor on what was AT that line before the batch; line numbers move, text
   # does not. `-S` fires when the batch adds, deletes or edits that text.
   anchor=$(git show <first>~1:<file> | sed -n '<line>p')
   git log -S"$anchor" --oneline <first>~1..<last> -- <file>    # expected: at least one commit
   # FORM B — FALLBACK, only when the pre-batch line is blank or its text is not unique in the
   # file. It resolves against the range TIP, so pass a TIP line number, never the ledger's.
   git log -L <line>,<line>:<file> --oneline <first>~1..<last>  # expected: at least one commit
   git show --name-only --format="" <hash> | grep -q '<file>'   # expected: exit 0
   ```
   **ALWAYS SAY WHICH FORM EACH ID USED** — an `applied-proof` line that does not name its form is
   unreproducible, and this gate's own first discharge was run at the FILE level by a command that
   returns filenames and can produce no per-ID number at all (`/audit` 2026-09-10 U-2).
   **Expected: every ID written `applied` returns a commit. An ID returning nothing is RED and its
   status is `open`, whatever the session intended.** This is the gate whose absence let **ten of
   forty-five** findings be written back `applied` with no edit at all — six of them under a commit
   message asserting a fix that does not exist — while every other control in this checklist passed
   (`/audit` 2026-09-09 T-10). It is the cheapest control here: one command per ID, and the failure
   it catches is 100% mechanically detectable.
   **ALWAYS REPORT — `applied-proof: N of M IDs resolve to a commit touching their line (form A:
   N1, form B: N2), K forced to open`. NEVER emit nothing.**
   **THE UNIT IS ONE FINDING ID, and the `$` line MUST be a per-ID command** — a file-union command returning paths tests no ID and no
   line, and was pasted under a `49 of 49` claim (`/audit` 2026-09-10 U-2).

   **Gate 3 — ROW COUNT EQUALS DISPOSED COUNT.**
   ```bash
   grep -cE 'applied `?sHASH' <the report file>   # plus any accepted-risk / rejected rows
   # CONSOLIDATED FORM: one alternation over every hash in the batch —
   # `grep -cE 'applied `?s(AAA|BBB|CCC)'` — compared against the single table's row count.
   # THE BACKTICK IS OPTIONAL AND MUST BE WRITTEN SO. Both `applied s312ad60` and
   # ``applied `s312ad60` `` are live on disk; the earlier form used a bare `.`, which REQUIRES a
   # character before the `s` and therefore returned 0 on every plain-form ledger — a gate reading
   # zero on a healthy file (found while running this gate, 2026-09-09).
   ```
   **Expected: equal to the receipt table's row count.** Report BOTH numbers.
   **SCOPE BOTH COUNTS — the findings ledger and the per-fix receipt share the `| ID |` row shape,
   so a whole-file count conflates them.** Count dispositions in the FINDINGS ledger and rows
   inside THIS run's receipts section, never with one grep over the file. (Learned by running this
   gate: a naive whole-file count read 50 rows where the ledger has 48 and the receipt has 2 — the
   same "scope is load-bearing" failure that shipped as M-31.) A table with fewer
   rows than dispositions hides the fixes whose sweep was skipped — 8 rows for 14 findings shipped
   while asserting "8 = 8, the self-check passes" (`/audit` 2026-09-03 N-5).

   **Gate 4 — EVERY NEW `ALWAYS REPORT` MANDATE HAS A SLOT.**
   ```bash
   # every report key this session ADDED, in the files it touched
   git diff --cached -U0 | grep '^+' | grep -oE 'ALWAYS REPORT[^`]*`[A-Za-z][A-Za-z0-9 ._-]*:'
   # The class must admit UPPERCASE (`PRD pointer:`, `MCP:`) AND `_ . -` (`done_tasks.md:`,
   # `back-sweep:`). Both were learned the hard way: the lowercase-only form missed a key this
   # gate had just created, and the `[A-Za-z ]` form that replaced it could not see
   # `done_tasks.md:` — the key of the very finding the gate was built for — while the commit
   # message asserted it had been verified against exactly that key (`/audit` 2026-09-04 Q-39).
   # The key-list cross-check higher in this file uses the SAME class; change both or neither.
   # then, for each key, grep the SAME file's REPORT TEMPLATE RANGE — never the whole file.
   # The mandate itself contains the key, so a whole-file grep always finds it and the gate
   # passes on the very state it exists to catch. Scope to the report section and confirm the
   # key appears there SEPARATELY from the line that mandates it.
   # STRIP THE TRAILING COLON when searching the report range: slot headings follow the
   # convention `### <key> (Step N) — ALWAYS report, never omit:`, with no colon after the key
   # itself. Searching for `<key>:` inside the report range returns 0 on a correctly slotted
   # mandate — which is this gate firing on the healthy state, the inversion that shipped twice
   # before (K-8, L-7). Verified against the existing `PRD pointer` and `done_tasks.md` slots.
   ```
   **Expected: every added key has a slot in the report format of the file that mandates it,
   and every slot's enumeration is COPIED FROM the mandating step rather than re-derived.**
   Both directions are RED: a mandate with no slot is owed by nobody, and a slot offering a
   verdict its step cannot emit is the same defect mirrored.
   This gate exists because the class outlived three consecutive batches and is the dominant
   ungated defect: one commit fixed SIX instances of it correctly (`N-1`, `N-22`, `N-23`,
   `N-27`, `N-29`, `N-32`) and committed FOUR new ones in the same diff (`/audit` 2026-09-03
   P-11, P-16, P-17, P-6, P-21). Gates 1-3 cover artifacts, diffs and counts; nothing covered
   **the descending direction of a new mandate** until this line.

   **ALWAYS REPORT — `gates: twin parity [PASS/RED] | receipt-rows-vs-diff [N/N] | row-count
   [N vs N] | slots [N/N]`. NEVER emit nothing, and NEVER commit on a RED.**

   > Evidence this is not hypothetical: applying the 2026-09-02 batch, the session reported
   > `4 directions, 15 extra instances` in good faith while running DESCENDING on one file
   > (`framework-audit`, which gained the new report field) and skipping it on that file's
   > mother-side sibling (`/audit`'s own report template) — shipping K-6. A per-fix row for that
   > finding would have carried `DESCENDING ✗` with nothing to write in the reason column.

5. **Back-sweep of every PROCESS rule promoted THIS session.** A newly promoted process rule
   condemns OLDER artifacts — applying it only where it was written leaves the repo failing its
   own new rule (the exact class an audit later reports as "rules the repo did not apply to
   itself"). ALWAYS, for each rule added or strengthened this session: name the artifacts it
   RETROACTIVELY governs, grep for them, and fix them in the SAME session — including THIS repo's
   own `.claude/` commands and rules, not only `docs/modules/` templates. Mechanical assist
   (expected result stated): for a rule about where an instruction must LIVE, grep every sibling
   invoker of the same shape; a rule applied to one of N twins is a back-sweep MISS, not a fix.
   `evolution-policy.md` already mandates back-sweep for PROJECTS — this item is the mother repo
   applying that discipline to itself.
   **MECHANICAL FORM — ALWAYS produce this table, one row per rule promoted.** Prose is what let
   this item pass while a rule it named was applied to 1 of 6 artifacts (`/audit` 2026-09-02 M-39).
   A back-sweep without a DENOMINATOR is not a control:

   | Rule promoted | Shape it governs | Grep that ENUMERATES the shape | N found | N fixed | Re-run |
   |---|---|---|---|---|---|
   | [one line] | [what kind of artifact it retroactively condemns] | [the actual command] | [count] | [count] | [0 remaining] |

   **THE GREP MUST COUNT VIOLATIONS, NEVER PRESENCE.** This is the single property that separates
   a row that works from a row that cannot: a RESIDUE grep returns 0 when the state is correct, so
   `0 remaining` is reachable; a PRESENCE grep returns N when the state is correct, so `0` is
   unproducible and the row reports a number its own command never returns. On this form's first
   execution, 1 of 3 rows used a residue grep and did real work; the other 2 used presence greps
   and both claimed a `0 remaining` their commands could not produce
   (`/audit` 2026-09-03 N-40). **Before writing a row, RUN its grep against the UNFIXED state and
   confirm it returns non-zero** — a grep that is already 0 before the fix is measuring nothing.

   **ALWAYS STATE the denominator, and ALWAYS make `N fixed` equal `N found`** or name the
   exception on that row.
   **THE CLOSING TOTAL MUST EQUAL THE SUM OF THE ROWS' `N fixed` CELLS — ADD THEM UP, NEVER ASSERT
   THEM.** Mechanical, expected result stated: sum the `N fixed` column and compare with the total
   you are about to write — **expected: equal.** A back-sweep closed at `19 of 19` over rows summing
   to **39**, one run after the identical failure closed at `26 of 26` over rows summing to 22
   (`/audit` 2026-09-09 T-20). **`N found` comes from RUNNING the grep, never from reading.** On the run
   that catalogued this item, reading said 4 of 6 agent blocks failed a newly promoted rule, the
   grep agreed — and after fixing those 4 it found **two more the reading had passed**.
   **ALWAYS RE-RUN the grep after fixing and report the second result — expected: 0 remaining.**
   **THE RED STATE MUST BE MEASURED IN THIS SESSION, NEVER QUOTED.** A figure copied from a prior
   finding, from a comment in the file being fixed, or from an earlier report is not a negation
   proof — it is a citation. One shipped: `3 of 10 pre-fix` was lifted from a comment inside the
   pre-fix file quoting an older finding's historical figure for a DIFFERENT command, and when the
   pre-fix form was actually executed it returned the same result as the post-fix one
   (`/audit` 2026-09-04 R-44).
   **ALWAYS check out the pre-fix state (`git stash`, or run against
   `<commit>~1`) and paste the red output with its `$` line.** If the pre-fix state cannot be
   reconstructed, say `negation proof: NOT RUN — [why]` and let it be visible.

   ### CONTROL BACK-SWEEP — when this batch installs or amends a CHECK, GATE or REPORT KEY

   The rule above sweeps a newly promoted RULE against the artifacts it retroactively governs.
   **Nothing swept a newly promoted CONTROL against the shapes this same batch invented — and that
   is where the defects have been.** The verification runs found no correlation with batch size
   (see `/audit` → “The defect series” for the figures — no trend; this sentence carried a fourth copy that was already wrong when written, `/audit` 2026-09-04 R-8, and its run count was a fifth, `/audit` 2026-09-09 T-41) and a
   consistent one with SIMULTANEITY: a control and the shape it must read, authored together and
   never run against each other (`/audit` 2026-09-04, meta-observation).

   **THE ENUMERATION IS A COMMAND, NOT A RECOLLECTION.** The first form of this sweep was prose
   with no command and no expected result; it could not go red, it reported `0 defects` on four
   commits that carried ten later findings, and only one of its four claimed catches survived
   independent verification (`/audit` 2026-09-04 R-43). Two of the other three were the negation
   proof of a different finding, counted a second time under a different key.
   ```bash
   # 1. THE CONTROLS THIS FILE DEFINES - the denominator. Never typed. COUNT BOTH SHAPES, PER FILE.
   # Controls live in TWO places and a one-shape count is arbitrary (`/audit` 2026-09-09 T-17).
   # `for ` MUST REQUIRE A LOOP VARIABLE AND `in`. A bare `for ` matches ENGLISH PROSE - "for one
   # full batch, which is why..." was counted as a control, which is T-17's own defect returning
   # through a new door: T-17 removed the `grep`-prose shape and reintroduced it via `for `
   # (`/audit` 2026-09-10 U-45).
   for f in .claude/commands/maintenance.md .claude/commands/audit.md; do
     inf=$(awk '/^```/{g=!g;next} g' "$f" \
       | grep -cE '^\s*(\$ )?(grep|awk |python -c|diff -r|git |node|sed -n|for [A-Za-z_][A-Za-z0-9_]* in )')
     inl=$(grep -ohE '`(grep|git|diff|awk|sed|node|python|ls) [^`]{4,}`' "$f" | wc -l)
     echo "$f: $inf fenced + $inl inline = $((inf+inl))"
   done
   # RED CONDITION, so step 1 CAN fail: if a file's total is LOWER than the previous batch
   # reported, a control was deleted - name which. An enumerator with no threshold cannot go red.
   # THE THRESHOLD IS THE FIGURE THIS COMMAND RETURNS **TODAY**, NEVER A REMEMBERED ONE, AND NEVER
   # A FIGURE MEASURED BEFORE THE BATCH. The `52` that certified one batch was measured at
   # `<first>~1`; re-run at the tip the same command returns 55, so up to THREE controls could be
   # deleted and still read GREEN (`/audit` 2026-09-10 U-6). Baseline measured 2026-09-11, AFTER
   # the U-45 tightening, at the TIP of the batch that installed it (NOT at `<first>~1` — that is
   # exactly how the stale `52` was produced): maintenance.md 3 fenced + 22 inline = 25;
   # audit.md 7 + 28 = 35; TOTAL 60.
   # 2. THE CONTROLS THIS BATCH TOUCHED — the numerator.
   git diff --cached -U0 .claude/commands/ | grep '^+' \
     | grep -cE '(grep|python -c|diff -r|git (diff|show|status)|node|sed -n)'
   # 3. RUN EVERY CONTROL IN (1), not only those in (2), and paste each one's stdout.
   ```
   **Expected: (1) is the denominator you report, (2) is at least 1 or this section is `N/A`, and
   every control in (1) has a `$` line with its literal output in the receipts.** A control you did
   not run is not a control you may report GREEN.
   3. **RUN EVERY OTHER CONTROL IN THIS CHECKLIST against those shapes**, not only the new one.
      A control written for the old shape and never re-run against the new one is the defect:
      a row-count gate whose command reaches one commit of six; a key list that predates the key
      the same batch mandated; a sum rule broken by the first line written under it; a heading rule
      contradicting the receipts form authorised beside it. All four shipped in one batch.
   4. **PROVE EACH AMENDED CONTROL BY NEGATION, WITH A COMMAND** — `component-design` §9 rule 4.
      Run it against a state that MUST make it red. **A check that has never gone red is not
      evidence of health; it is an unproven claim.** Three checks shipped in one batch could not
      fail at all: a guard asserting a symptom the command does not produce, a harvest regex whose
      character class could not cross an em-dash, and a second one blind to the key class of the
      finding that created it.

   **ALWAYS REPORT — `control back-sweep: K of N controls re-run, J defects found` with the
   command and stdout from step 1 beneath it, or `control back-sweep: N/A — no control touched`.
   NEVER emit nothing, NEVER report it without naming the shapes, and NEVER count a control's own
   calibration or another key's negation proof as a defect this sweep found** — both were counted
   that way, and the double-count is how `4 defects` was reported for 1 (`/audit` 2026-09-04 R-43).

   **ALWAYS REPORT — `back-sweep: N rules, M artifacts fixed of M found, re-run clean` or
   `back-sweep: N/A — no process rule promoted`. NEVER emit the total without the table.** Per
   component-design §6 a self-check must be executed AND REPORTED; a silent back-sweep is
   indistinguishable from a skipped one, and an UNMEASURED one is indistinguishable from a
   partial one.

6. **Component liveness — re-check the frontmatter of every component edited this session.**
   ALWAYS run the guard over this repo's OWN `.claude/skills/` and `.claude/agents/` after touching
   any component frontmatter (component-design §8: invalid YAML does not error — it makes the
   component VANISH from the registry):
   ```bash
   sed -n '/^````js$/,/^````$/p' docs/modules/templates/check_agent_frontmatter.md | sed '1d;$d' > /tmp/guard.mjs && node /tmp/guard.mjs
   ```
   **ALWAYS ALSO validate EVERY RAW template bootstrap copies VERBATIM with `cp`** — the ones
   the command above never sees because they live outside `.claude/`. **GLOB them; NEVER list
   them.** A hard-coded list named 4 agent files and silently excluded all 15 `docs/modules/skills/*/SKILL.md`
   templates, which `bootstrap.md:350` copies with `cp -r` and whose frontmatter must therefore be
   valid AT REST in this repo — the largest verbatim-copied surface in the framework, machine-
   validated by nothing (`/audit` 2026-09-03 N-51). A list also goes stale the moment a component
   is added, which is the same defect as an enumerated set anywhere else.
   ```bash
   python -c "import io,yaml,glob,os,sys
   bad=0; n=0; sk=0
   for p in sorted(glob.glob('docs/modules/skills/*/SKILL.md'))+sorted(glob.glob('docs/modules/agents/*.md')):
       s=io.open(p,encoding='utf-8').read().replace(chr(13)+chr(10),chr(10))
       if not s.startswith('---'): sk+=1; continue
       n+=1
       try:
           d=yaml.safe_load(s[4:s.index(chr(10)+'---',4)+1])
           exp=os.path.basename(os.path.dirname(p)) if p.endswith('SKILL.md') else os.path.basename(p)[:-3].replace('_','-')
           if d.get('name')!=exp: bad+=1; print('FAIL',p,'name=',d.get('name'),'expected',exp)
       except Exception as e: bad+=1; print('FAIL',p,type(e).__name__)
   print('raw templates: %d validated of %d globbed, %d skipped (fenced),' % (n, n+sk, sk), 'OK' if not bad else str(bad)+' BROKEN'); sys.exit(1 if bad else 0)"
   ```
   Expected result: **`raw templates: N validated of M globbed, S skipped (fenced), OK`** —
   **ALWAYS REPORT ALL THREE NUMBERS.** The globs match 25 files and the parser validates 19: the
   6 skipped are the FENCED agent templates, whose frontmatter lives inside a ```` fence and so does
   not start with `---`. That is correct behaviour — their frontmatter is validated in the project
   after extraction — but a bare `19 validated` is a numerator with no denominator, and the six it
   silently drops include **all three declaring components** (`/audit` 2026-09-03 P-34). A silent
   drop in the denominator is how a whole directory left the check's scope unnoticed; naming M and
   S is what makes the next drop visible.
   It also asserts `name:` matches the file/dir, which the previous form never did outside
   `.claude/`. **`os.path` — never `p.split('/')`**: on Windows the glob returns backslash
   separators and a `/`-split makes every file report a bogus name mismatch.
   A FAIL here ships a component that is PRESENT
   in every bootstrapped project and ABSENT from its registry. (Fenced templates — the ones
   extracted with `sed` — are correctly skipped: their source does not start with `---`.)
   Evidence this is not hypothetical: run on 2026-09-01, this check found `criteria_enforcer.md`
   broken since before v2.7.0 — the agent that `validation-orchestrator` and `autonomous-loop`
   both declare ALWAYS SPAWN.

   Expected result: **exit 0**, every component listed OK. ALWAYS REPORT the outcome —
   `liveness: N components OK [full parse | structural-only]` or `liveness: skipped — [reason]`.
   A silence is indistinguishable from a forgetting (component-design §9 rule 3). If the session
   edited no frontmatter at all, say `liveness: skipped — no frontmatter touched`, never nothing.
   **ALWAYS state which MODE ran.** The guard prints `modo estrutural — js-yaml ausente` when the
   full YAML parse is unavailable; that path still catches the colon-space class but is NOT the
   complete check. Reporting a bare "exit 0" from a degraded run is the "passed ≠ ran completely"
   class this framework's own session-rules → "Execution proof" exists to forbid.

   **ALWAYS PROVE any self-check you WRITE this session by NEGATION before trusting it**
   (component-design §9 rule 4, whose invoker is this line): run it against a state where it MUST
   go red, and report `negation proof: [check] → red as expected` or
   `negation proof: N/A — no new self-check written`. A check that has never failed is decoration,
   not a control — and the session that catalogued that class shipped a self-check grepping the
   wrong token.

7. **Version bump — decide it, APPLY it, and REPORT it.** The full policy is the
   "Version bumps" section below; this item is what makes the checklist REACH it. The bump lived
   as an H2 outside these numbered items, so the governing line above ("Run EVERY numbered item
   below") never covered it — and it carried no report line at a time when items 4-6 already did
   (items 1-3 gained theirs in the same pass that added this one).
   **ALWAYS REPORT — `version: vX.Y.Z applied to N/N canonical surfaces` or
   `version: none — [reason]`. NEVER emit nothing.** The count is the load-bearing half:
   *declaring* a bump and *applying* it are different acts, and only one of them is verifiable.
   Mechanical self-check (expected result stated): `grep -rn "vX\.Y\.Z" README.md
   docs/modules/templates/claude_md.md .claude/commands/existing_project_adaptation.md` →
   every canonical surface returns a hit; any surface still on the OLD version is RED.

   > Evidence this is not hypothetical: `cc6e31d` exists solely because "the previous commit
   > declared a bump it never applied". A silent bump is indistinguishable from a forgotten one.

8. **Classify every change with the component-design §5 verbs — and honour RELOCATE's rule.**
   `component-design.md` §5 defines ADD / SUBSTITUTE / DELETE / RELOCATE and requires each change
   to be classified and justified, but until now NOTHING in this file invoked §5: its only invoker
   was `skill-gate`, a project-side skill this repo exempts itself from (see "New component
   creation" below). This item is §5's mother-side invoker.
   **ALWAYS CLASSIFY each change this session as ADD / SUBSTITUTE / DELETE / RELOCATE**, and for
   every SUBSTITUTE, DELETE or RELOCATE state the justification §5 requires.
   **For every RELOCATE, ALWAYS RUN §5's four obligations** — the source POINTS at the moved
   content and never restates it; name what stays SHARED; sweep every INVOKER that cited the moved
   section by name; run item 1's inventory sweep for the new component.
   Mechanical self-check (expected result stated): for each RELOCATE, grep the moved section's
   heading text across the repo and **count only the definitions OUTSIDE a declared twin pair**.
   **Expected: exactly ONE definition per twin-set, plus N pointers.** Two definitions across a
   `docs/modules/` ↔ `.claude/` twin pair is the NORMAL case CLAUDE.md's dual-placement rule
   REQUIRES — it is GREEN, and the obligation there is that the two stay byte-identical in the
   moved section. **RED is:** two definitions inside the SAME file, two in files that are not a
   twin pair, or a twin pair whose copies of the moved section DIFFER. A pointer that restates the
   content instead of citing it is also RED.
   (This check was written in `a28f661` with "two definitions is RED" flat, which fires on every
   twinned component and would have been disabled by its first user — `/audit` 2026-09-02 K-8.)
   **ALWAYS REPORT — `classification: A add, S substitute, D delete, R relocate` (plus the
   per-RELOCATE grep result) or `classification: N/A — no component content changed`. NEVER emit
   nothing.**

9. **New-component gate — run the "New component creation" section when this session created one.**
   That section (below) carries five ALWAYS obligations and its own `new component: …` report
   line, and until now no step invoked it: the Workflow line never named it and no checklist item
   referenced it, leaving its report owed by nobody — the exact §9 class this checklist enforces
   elsewhere. This item is its invoker.
   **ALWAYS RUN the "New component creation" section in full whenever this session created a
   skill, agent template, rule, command, or script**, and **ALWAYS EMIT its report line here** —
   the format is defined ONCE, in that section's obligation 5; this item does not restate it
   (component-design §9: one home per mandate).
   Mechanical self-check (expected result stated): over **THIS run's receipts section only**, run
   `grep -cE "^\*\*new component:"` → **expected: exactly 1**. Zero means the line was never
   emitted. **ANCHOR ON THE LINE START and SCOPE TO THE SECTION** — an unanchored
   `grep -c "new component:"` counts every quotation of the key inside the per-fix table and
   returns 3, which is how this check went RED on a healthy discharge on its first run
   (`/audit` 2026-09-02 M-27).

## Version bumps — the framework version is a CLAIM, and it decays silently

The version label is CONSUMED by `existing_project_adaptation.md`, which keys migration decisions
to it. A stale label tells an upgraded project it is current while it receives content several
batches ahead — the same "instrument that lies" class the audits keep surfacing.

**ALWAYS decide the bump when a session changes `docs/modules/` (the templates projects receive)
or the command pipeline, and ALWAYS state the decision in the commit** — `bump: vX.Y.Z` or
`bump: none — [reason]`. Never leave it unsaid.

**ALWAYS PROPOSE `/audit` BEFORE a MINOR or MAJOR bump** — this is trigger (b) in CLAUDE.md, and
this section is its invoker. A bump publishes the current state as a contract; the net runs first.
Report `audit: proposed / ran / skipped — [owner deferred]`, never nothing. (PATCH bumps do not
require it.)

- **MINOR** (`v2.14.2` → `v2.15.0`): a new rule/section/template, an upstream absorption, or a
  schema change to a document projects receive.
- **PATCH** (`v2.15.0` → `v2.15.1`): corrections that add no new contract — broken references,
  counts, typos, instruction-style rewrites.
- **MAJOR:** a change that invalidates an existing project's structure without migration.

**The canonical set is DERIVED, never typed.** A typed three-name set (`README.md`,
`docs/modules/templates/claude_md.md`, `.claude/commands/existing_project_adaptation.md`) omitted
`.claude/commands/audit.md`'s "As of vX.Y.Z" claim, and the `version:` receipt then reported
`3 of 3` over four surfaces — the inventory-completeness failure `inventory sweep:` exists to catch
(`/audit` 2026-09-10 U-42). Those three remain the ones that always carry a stamp; **ENUMERATE the
rest, every bump:**
```bash
OLD=2.20.0   # the version being replaced
grep -rn "v$OLD" README.md docs/ .claude/ CLAUDE.md 2>/dev/null | grep -v 'created: framework-v'
```
**Expected BEFORE the bump: every surface that must move. Expected AFTER: ZERO hits.** A residue
grep returns 0 when the state is correct, so `0 remaining` is reachable — a PRESENCE grep is not a
control (item 5). `created: framework-vX.Y.Z` fields are excluded because they are LINEAGE.
`created: framework-vX.Y.Z` fields inside components are **LINEAGE, never the current version** —
they record when a component was born and MUST NOT be rewritten by a bump.

## New component creation — the mother repo's own gate

This repo SHIPS `skill-gate` to every internal-tool+ project as the mandatory creation gate for
new skills and rules, and has authored 4+ components of its own (`commit`, `codebase-audit`,
`framework-audit`, `skill-gate` itself, `autonomous-loop`) without ever running it here. That was
never a decision — it was a silence. This section is the decision.

**The framework repo does NOT run `skill-gate` on its own components.** The gate's mechanism is a
blind review by a `skill-reviewer` subagent against a rubric, and it presumes the project
ceremony that surrounds it (`.claude/drafts/`, the PostToolUse hook, the tier profile) — none of
which this repo installs, because this repo has no code to review and no risk profile. The gate
this repo uses instead is `/audit` (17 dimensions, 6 agents, event-triggered per CLAUDE.md) plus
the post-change checklist above. **Stating the exemption is the point: an unstated exemption is
indistinguishable from a forgetting.**

**When this session CREATES a new framework component (skill, agent template, rule, command),
ALWAYS:**
1. **PLACE it per CLAUDE.md's dual-placement rule** — `docs/modules/` always; this repo's own
   `.claude/` ONLY if the framework itself needs it at runtime.
2. **WRITE its frontmatter to survive the registry** — `name:` matching the file/folder, every
   free-text scalar quoted (component-design §8), then run checklist item 6.
3. **NAME its INVOKER** — the component that executes the moment this one must run, and put the
   instruction THERE (component-design §9). A component whose only activation notice lives in its
   own frontmatter is read by nobody.
4. **RUN checklist item 1** — a new component is an added artifact; its counts and index rows are
   the surfaces that go stale first.
5. **REPORT — `new component: [name] — placed [where], invoker [who], liveness [result]`, or
   `new component: none this session`. NEVER emit nothing.**

## Audit intake — applying a persisted audit report

`/audit` produces a dated report at `assets/docs/audit-YYYY-MM-DD.md` and ends by pointing here.
That report is the correction plan; this section is where applying it lives. (Symmetric to
Upstream intake below — applying audit findings is the more frequent of the two flows and had no
written home until `/audit` D17 found the gap.)

When the prompt says to apply an audit, or names a report file, ALWAYS:
1. **READ the most recent `assets/docs/audit-*.md`** and work from its stable IDs (`F-3`, `G-7`).
   Cite IDs in the commit message so a later session can trace what was applied.
2. **RE-VERIFY each finding against the CURRENT disk before applying it.** A report is evidence,
   not truth: it may be stale, or its characterization may be wrong. When a finding says
   "rename X to Y", read the structure first — two headings that look like paraphrases may carry
   different contracts.
3. **Apply, then run item 4's CLASS SWEEP for every fix** — a report names one line; the line is
   almost never the only instance.
4. **A WRITE-BACK COMMIT CARRIES STATUS AND RECEIPTS ONLY.** If it also changes a command, a
   template or a rule, it is a FIX commit: it states a real `bump:` and carries its own gates.
   Seven commits declaring `bump: none — write-back only` shipped normative content, one of
   them a new mandate and slot AFTER the version bump (`/audit` 2026-09-04 R-45).
   **A WRITE-BACK ADDS; IT NEVER REMOVES. A PERSISTED REPORT IS APPEND-ONLY.**
   **COUNT STRUCTURE, NEVER RAW LINES.** A status write-back rewrites every ledger row in place
   (`| open |` → ``| applied `sHASH` |``), so a raw `--numstat` deleted-count is large on a
   perfectly healthy commit — measured, 52 on a write-back that removed nothing. A gate that fires
   on the normal case is the inversion this file has had to repair three times (K-8, L-7, and this
   line on the day it was written).
   ```bash
   # QUOTE THE PATHSPEC. An unquoted glob is expanded by the SHELL against the WORKING TREE, where
   # a DELETED report no longer exists — so its filename was never passed to git and the deletion
   # of an ENTIRE persisted report read GREEN. Proved in a clone (`/audit` 2026-09-10 U-3).
   for f in $(git diff --cached --name-only -- 'assets/docs/audit-*.md'); do
     # FIVE PATTERNS, NOT THREE. `^#{1,2} ` cannot see an `###` heading, and the receipts — every
     # `$` line, every `**key:**`, the Meta-observation and both closing status lines — are the
     # surface D17.5's only external verifier reads. The three-pattern form saw 105 of 531 report
     # lines, 20% (`/audit` 2026-09-10 U-8).
     for pat in '^#{1,3} ' '^\| [A-Z]-[0-9]+ \|' '^> \*\*Errata ' '^ *\$ ' '^\*\*[a-z][a-z ._-]*:'; do
       b=$(git show HEAD:"$f" 2>/dev/null | grep -cE "$pat")
       # A MISSING FILE COUNTS 0, NEVER ''. `grep -c` on a deleted path prints NOTHING, and
       # `[ "" -lt "13" ]` is a shell ERROR, not a RED — U-3's second, independent layer.
       if [ -f "$f" ]; then a=$(grep -cE "$pat" "$f"); else a=0; fi
       [ "${a:-0}" -lt "${b:-0}" ] && echo "RED $f: $pat  ${b:-0} -> ${a:-0}"
     done
   done
   ```
   **NEGATION-PROVED 2026-09-11, four ways in a throwaway clone:** a commit deleting the whole
   report → RED on 3 patterns (old gate: SILENT); a healthy status write-back that only adds →
   no output; a commit deleting just the receipts section → RED on `^#{1,3} `, `^ *\$ ` and
   `^\*\*[a-z]…:` (old gate: SILENT); the old gate on that same state → nothing at all.
   **Expected: NO OUTPUT.** Headings, ledger rows and errata blocks may only increase. Any decrease
   is RED and BLOCKS the commit unless an errata block in the SAME commit names what was removed
   and why. The two
   forms in `/audit` → "Errata and superseded status" are the ONLY permitted modifications, and
   both ADD text beside what they correct — neither removes it. There is no condensation policy,
   no rotation policy and no size policy in this repository, and a report that grows is the
   intended shape.
   **Evidence:** the rule above governed only addition, and the very next write-back deleted **554
   of 574 lines** of a persisted report — two full audit reports, both findings ledgers, and the
   errata block written 100 seconds earlier — while satisfying every word of it, because it touched
   no command, template or rule (`/audit` 2026-09-09 T-1). It also wrote back **zero** statuses
   under a subject reading "45 of 45 applied".
   **ALWAYS REPORT — `report deletions: N structural decreases across M report files, all
   accounted for` or `report deletions: none`. NEVER emit nothing.**
   **THE UNIT IS A STRUCTURAL DECREASE — one `RED` line from the gate above — NEVER a raw line
   count.** `a6349da` changed the
   gate's unit from raw lines to structure and did not sweep the report key it feeds, leaving the
   slot asking for a number the gate no longer produces (`/audit` 2026-09-10 U-43). A raw
   `--numstat` deleted-count is large on a perfectly healthy write-back, which is why the gate
   stopped counting lines in the first place.
   **RESTORING A REPORT A PRIOR COMMIT DESTROYED — the APPLYING session owns this.** The gate above
   BLOCKS a new deletion; nothing told the session what to do about one already in history. T-45's
   fix tells the AUDIT to reconstruct a destroyed report for READING; that is a different act, and
   it leaves the file on disk still broken. This was done correctly and unprompted once, which is
   why it is written down (`/audit` 2026-09-10 U-44).
   **ALWAYS DO ALL FOUR, in this order:**
   1. **RESTORE the last intact revision** — `git show <hash>:<file> > <file>`, byte-faithful.
   2. **KEEP every intervening receipt and status written after the destruction.** Restoring is
      not reverting: re-apply those on top, never drop them.
   3. **RECORD it as an ERRATUM in the restored file** (`/audit` → "Errata and superseded
      status"), naming the destroying commit, the restoring commit and what was lost and regained.
   4. **NEVER `--amend` or rewrite the destroying commit** — Audit intake item 8.
   **ALWAYS REPORT — `report restore: <file> restored from sHASH, N lines, erratum written` or
   `report restore: none`. NEVER emit nothing.**

   **ALWAYS WRITE THE STATUS BACK into the report file in this same session** — `applied sHASH`
   or `rejected — [reason]` per ID. The applying session owns this, not the next audit: a status
   that waits for the next run is a status nobody wrote.
   **ALWAYS WRITE THE POST-CHANGE CHECKLIST RECEIPTS into that same file**, under
   `## Post-change checklist receipts (sHASH)` — all of them, verbatim, including the per-fix
   receipt table. This step is the RECEIVER of the checklist's persistence mandate (see the
   checklist header); without it those receipts exist only in a transcript and the verification
   audit cannot check any of them.
5. **State explicitly which findings were NOT applied and why.** Deferring is legitimate;
   silently dropping is not — they must still read `open` for the next carry-forward.
   **When the owner decides NOT to fix an ESCALATED finding, ALWAYS WRITE AN ACCEPTED-RISK RECORD
   into the report file.** `/audit` Phase 3 CONSUMES such records (`accepted-risk — see [record]`)
   and nothing said who authors them (`/audit` 2026-09-02 M-37). The record ALWAYS carries five
   fields; one missing field means it is not a closure:
   - **Decision** — one line, in the owner's terms.
   - **Working tree** — what changed, plus the MEASURED residual count (expected 0).
   - **Residue** — what remains, where, and why it is accepted.
   - **Standing instruction to future `/audit` runs** — report it as an OBSERVATION citing this
     record; NEVER as `open`, NEVER as grounds to propose a history rewrite.
   - **What WOULD re-open it** — stated explicitly, or the record closes more than it should.
   **ALWAYS set that finding's status to `accepted-risk — see [record]`**, never to `applied`.
   Mechanical self-check (expected result stated): for every block whose heading MATCHES
   `^#{2,3} Accepted-risk record ` — **that exact prefix, never a bare `Accepted-risk`** — a
   report may also carry an `Accepted-risk OBSERVATIONS` section, which is not a record and goes
   RED at 0 fields under a loose anchor (`/audit` 2026-09-03 N-54),
   `grep -cE "^- \*\*(Decision|Working tree|Residue|Standing instruction|What WOULD re-open it)"`
   within that record → **expected: exactly 5**. Fewer means it is not a closure. The rule shipped
   without this check and was never applied backward to the one record that pre-dated it, which
   carried four fields under different labels while two later surfaces asserted it carried five
   (`/audit` 2026-09-03 N-43).
6. **A batch MAY be split across several commits — and every commit in it carries the full
   contract.** Splitting is legitimate (process-file repairs alone, then the content fixes), but
   each commit ALWAYS states its own `bump:` decision, and the batch ALWAYS ends with receipts that
   leave NO commit unaccounted for. **Two forms satisfy this, and only these two:** one receipts
   section per commit, OR **ONE consolidated section for the batch whose per-fix table carries a
   `Commit` column naming every hash, with each commit's own gates reported in its message.**
   The consolidated form is preferred for a batch of more than three commits — six sections for
   one batch is noise, and the obligation is that nothing goes unreceipted and everything stays
   re-readable, not that the sections be numerous. **A commit that appears in NO receipts table
   is the violation** (`/audit` 2026-09-03 P-4, which found item 6 broken four times inside the
   batch that installed it). **NEVER let a closing commit carry neither.**
   **THE SUBJECT'S COUNT IS THE COUNT OF DISTINCT FINDING IDs THE COMMIT DISPOSES OF** — not the
   number of edits, not the number of sites, and **not every ID the body MENTIONS**.
   **ALWAYS OPEN THE BODY WITH ONE `Applies <IDs> from <report>` LINE, and count THAT** — a body
   legitimately CITES other IDs (a finding whose rule was fixed in a sibling commit, a class this
   one recurs from), and a whole-body grep counts those too, so the mechanical rule contradicted
   itself on first use (`/audit` 2026-09-10 U-14's commit; found by running the check below).
   ```bash
   # awk, NOT a sed range: `sed -n '/^Applies /,/from /p'` runs PAST a one-line Applies block,
   # because sed tests the end pattern from the line AFTER the start. Measured, it scored 3 of 4
   # healthy commits RED (2026-09-11).
   git log -1 --format=%B <hash> | awk '/^Applies /{f=1} f&&/^$/{exit} f'      | grep -oE '[A-Z]-[0-9]+' | sort -u | wc -l      # MUST equal the number in the subject
   ```
   **Expected: equal.** **ALWAYS RUN IT BEFORE WRITING THE SUBJECT, NEVER AFTER** — once the commit
   exists the only remedy is item 8's follow-up, which cannot change what the subject says. Two group commits in one batch overstated it ("6 findings"
   carrying 5 IDs, "9 findings" carrying 7) while both reported `row-count N vs N`, and the
   identical class already has an erratum from an earlier run (`/audit` 2026-09-04 Q-45).
   **Name the groups the same way every run** — `group A`, `group B`, … — rather than inventing a
   scheme per batch; three runs used three schemes.
   When dispositions span hashes, the `Application status` line names them all —
   `PARTIAL — N of M applied (X in sAAA, Y in sBBB)` — because the enumeration at `/audit` Phase 3
   admits no two-hash form otherwise (`/audit` 2026-09-03 N-44).
7. **A RECEIPT MUST NAME A HASH THAT DOES NOT EXIST YET — resolve it with a PLACEHOLDER and a
   substitution commit.** Receipts and ledger rows cite the commit they describe, so write a
   literal placeholder token (`sBATCH`, `sGROUP4`) everywhere the hash belongs, make the fix
   commit, then make ONE follow-up commit that substitutes the real short hash and states how many
   places it replaced. **A pure-VERSION-BUMP commit (`chore: bump to vX.Y.Z`) is likewise EXEMPT,
   and ALWAYS SAYS SO** — it changes a label, not content. Three such commits were made with no
   written home at all (`/audit` 2026-09-09 T-30). **PREFER applying the bump inside the batch's
   closing commit;** the standalone form is for a bump the batch forgot.
   **A pure-substitution commit is EXEMPT from the receipts requirement in item
   6** — it changes identifiers, not content — and **ALWAYS SAY SO in its message** so the exemption
   is visible rather than assumed. This convention was executed at least four times before it had a
   written home; `grep -rn "placeholder" .claude/commands/*.md` returned 0
   (`/audit` 2026-09-03 P-31, P-4).
   **ALWAYS REPORT — `placeholder: N occurrences substituted in sHASH` or `placeholder: none`.**
   **THE CHECK MUST NOT SELF-MATCH, AND MUST COVER EVERY TOKEN THE BATCH ACTUALLY USED.** The
   first discharge grepped `sBATCH|sGROUP[0-9]`, was reported `0`, and returns **1** — the receipt
   line quoting the pattern is itself the match — while being blind to `sPENDING`, the token that
   batch really used (`/audit` 2026-09-10 U-38; R-16's literal defect). Exclude the lines that can
   only ever be quotations. **ANCHOR ON THE POSITION WHERE A HASH BELONGS, NEVER ON THE BARE
   TOKEN** — `sHASH` appears legitimately in PROSE describing the marker form, and a bare-token
   grep therefore fires on the healthy state, which is the K-8/L-7 inversion (measured while
   calibrating this very check, 2026-09-11):
   ```bash
   grep -nE 'applied `?s(BATCH|GROUP[0-9]+|PENDING)`?|\| *`?s(BATCH|GROUP[0-9]+|PENDING)`? *\|'      <the report file>
   ```
   **Expected: NO OUTPUT.** A hit is a placeholder still sitting where a real hash belongs — a
   ledger status cell or a `Commit` column cell. NEGATION-PROVED both ways: planting `sBATCH` in a
   status cell and `sGROUP1` in a `Commit` cell each returns exactly one line; the healthy file
   returns none.
   **ALWAYS LIST the tokens the batch used, and ALWAYS ADD any new one to the alternation in the
   same edit.**
8. **A FALSE CLAIM IN AN ALREADY-MADE COMMIT MESSAGE IS CORRECTED BY A FOLLOW-UP COMMIT, NEVER BY
   `--amend`.** A later commit may already depend on the hash, and the record of what was claimed
   and when is itself evidence — the correction belongs beside the error, not in place of it. The
   follow-up states what the original claimed, what is true, and how the gap was found.
   **ALWAYS REPORT — `commit correction: sHASH corrected by sHASH — [what]` or `commit correction: none`.**
   This was executed once with no written home; the only `amend` string in the repo forbade it for
   audit sessions only (`/audit` 2026-09-04 Q-44).
9. **ALWAYS PROPOSE a `verification`-mode `/audit` after the batch lands** — this is trigger (d)
   in CLAUDE.md and `/audit` Phase 0, and this step is its invoker. Applying a batch is the one
   moment where the fixes themselves are the least-verified thing in the repo: every documented
   execution of this pass has found defects in already-applied findings, at a rate the ONE table
   records (`/audit` → “The defect series”; the figures are never copied here — `/audit`
   2026-09-04 R-7), and step 2's re-verification runs BEFORE applying, never after. Report
   `verification audit: proposed / ran / skipped — [owner deferred]`; NEVER nothing.

## Upstream intake — absorbing framework evolutions from projects

Projects record framework-level lessons in their own
`projects/<name>/.claude/docs/framework-evolution-*.md` (per the evolution-policy template's
"Framework-evolution docs — the upstream lifecycle" section). `projects/` is gitignored but
readable — those docs are legitimate INPUTS to a maintenance session (READING them never
violates the no-touch rule).

When the maintenance prompt asks for an upstream (or names such docs as sources), or when Step 0's
sweep surfaced pending docs and the owner authorized absorbing them, ALWAYS:
1. **READ each evolution doc fully**; anchor on its PORTABLE formulation section when present.
2. **Decide PER EVOLUTION:** graduate to `docs/modules/` / adapt (genericize) / reject — with
   a one-line reason each. "Evaluated and kept project-local" is a valid disposition.
3. **GENERICIZE on the way in** (project-information isolation is TOTAL): role descriptors
   only ("projeto-fonte", "a production project"), no project/client names, no source-project
   session numbers, no single-project vocabulary — templates get DOUBLE scrutiny (they
   broadcast to every future project). Proven artifacts (guard scripts, mutation-tested code)
   keep their code byte-identical; only provenance headers/comments are genericized.
4. **Record the batch in a lineage doc under `assets/docs/`, named
   `framework-evolution-upstream-<date>[-slug].md`.** The `framework-evolution-upstream-` prefix
   is MANDATORY, not a convention: Step 0's cross-check globs exactly that pattern, and a record
   filed under any other name makes the check silently return no hit — so the next session reads
   a false `pending absorption` and re-absorbs a batch already disposed of. (Existing records use
   `YYYY-MM`; `YYYY-MM-DD` is equally valid.)
   Record what graduated, where each piece landed, what was adapted, and what was deliberately NOT
   absorbed (with why). That commit is the AUTHORITATIVE disposition for every doc in the batch.
   **ALWAYS cite each absorbed doc by its FULL FILENAME** (e.g.
   `framework-evolution-2026-08-21-cadence-and-execution-proof.md`), not by date alone. The
   filename is what Step 0's cross-check greps for; a lineage doc that records only a date leaves
   the slug branch of that check returning nothing, and the next session reads a false
   "pending absorption" and re-absorbs a batch already disposed of. Dates also collide — two
   source docs can share one.
5. **NEVER edit the project's own evolution docs** (no-touch rule) — marking them
   `upstreamed` is the project's own next session's job, guided by this repo's lineage record.
6. Run the post-change verification (cross-references, template fence extraction, D16
   isolation grep over every touched file) before committing.
7. **ALWAYS PROPOSE `/audit` after the absorption lands** — this is trigger (a) in CLAUDE.md,
   and this step is its invoker. An absorption changes templates every future project receives,
   so the net runs behind it. Report `audit: proposed / ran / skipped — [owner deferred]`; never
   nothing.
8. **ALWAYS HAND THE DISPOSITION BACK to the owner in the session's closing report** — one line
   per absorbed doc: its path, the verdict (graduated / adapted / rejected), the lineage file and
   commit that record it, and the explicit sentence that the doc is now **dischargeable**, i.e.
   the project's own next session marks its header `upstreamed`. The no-touch rule stops this repo
   from marking it; it does NOT excuse this repo from SAYING so. Without THIS step the last link of
   the chain rests on owner memory — the exact failure class Step 0 exists to eliminate.