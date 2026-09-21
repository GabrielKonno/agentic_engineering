# Framework Audit

This is a **read-only audit session** for the agentic_engineering framework repository. **No
AUDITED file is modified** — the audit never fixes what it finds. It writes its own report (Phase 3) and,
in verification mode, the ONE defect-series row authorised below — and nothing else, which is this session's output, not a change to the thing under audit.

**Authorized operations:**
- Read any file in the repository
- List directory contents
- Launch parallel audit agents
- **Write the report at `assets/docs/audit-YYYY-MM-DD.md`** (Phase 3) — and, in verification
  mode, the ONE appended defect-series row authorised below. **NO THIRD PATH.** This line read
  "EXACTLY ONE file" while the bullet below mandated the append, so an executing agent read a
  prohibition on the very operation it was told to perform (`/audit` 2026-09-21 AD-4/AD-5, whose
  sweep reached five descriptive surfaces and missed this, the authoritative one).
  Read-only refers to the AUDITED surfaces — the report is this session's output, and a report
  that lives only in a transcript cannot be carried to the session that applies it.
- **READ-ONLY git inspection, anywhere in the repo** — `git log`, `git show`, `git status`,
  `git diff`, `git grep`, `git rev-list`, `git check-ignore`, `git reflog`, and `git fetch`, which
  writes only remote-tracking refs, `FETCH_HEAD` and objects, and which Phase 0 runs (forward reference, flagged). Several checks below MANDATE these
  (D16.3c scans all commits and messages; Agent 6's D17.1 classifies `git log`; Phase 3's own
  self-check runs `git status`). They read history; apart from `git fetch` moving remote-tracking
  refs, they change nothing.
- **EXECUTING a check that WRITES, a negation probe, a planted bad state or a persisted script — ONLY
  inside `bash .claude/scripts/probe-sandbox.sh run [--staged] -- <command>`.** The script clones the
  repo into a throwaway directory with fetch and push disabled and reads RED if the live repo changed. D7.6 and
  D10.0 (forward references, flagged) mandate executing checks, several of which commit, stash or push; executed from the live
  repo, one run pushed two planted commits to the real remote (`/audit` 2026-09-16 A-1, A-2).
  **NEVER execute one in the live repository.**
  **ALWAYS paste the script's final `probe-sandbox:` line beside the output it guarded.**
  **NEVER run a READ-ONLY scan inside the sandbox** — the D16 gate's `staged`, `log` and `dir` scopes
  and the git inspection above run in place. A clone carries no stash, no live index unless
  `--staged`, and no gitignored `.claude/docs/`, so a scan there reads less and reports a false 0.
  **ALWAYS pass a persisted script by ABSOLUTE path, extracted outside the repo** — the sandbox holds
  only committed files, and the script fails closed on a command it cannot find.
- **APPEND ONE ROW to the defect-series table in THIS file (`.claude/commands/audit.md`)** — Phase 3
  item 6 mandates it and the authorized-operations list forbade it, a contradiction that stood
  unreported for two runs and left the row unappended (`/audit` 2026-09-09 T-50). This is the ONE
  line of the ONE table the run computes; nothing else in this file may be touched.
- **`git add` + `git commit` of THE REPORT — and, when Phase 3 item 6 appended a row, of
  `.claude/commands/audit.md` TOO.** The authorised-operations bullet directly above permits that
  append; this clause read "THAT ONE FILE", so taken literally the appended row would live only in
  the working tree — the exact failure the COMMIT item exists to prevent. The contradiction was
  created by the fix that created the operation (`/audit` 2026-09-10 U-47). **NO THIRD PATH may be
  committed.** A report that lives only in the
  working tree does not survive a `git clean`, a `git checkout`, or a session boundary — which is
  exactly what happened to every report written before this line existed. **Apart from `git fetch` moving remote-tracking refs, authorised above, this is the ONLY
  git operation that WRITES IN THE LIVE REPOSITORY** — inside the sandbox clone a probe may
  legitimately commit, stash or reset, which is the whole point of the clone.
  NEVER `push`, NEVER `commit --amend`, NEVER a commit touching any
  other path, NEVER any history rewrite.
- No other file creation, modification, or deletion inside the repository (the sandbox's clone
  lives outside it and is deleted when the command ends; agents never pass `--keep`)

**Rules:**
- Every check is mechanical: compare claim against fact, report mismatch
  (EXCEPTION: D17/Agent 6 hunts ABSENCES — evidence gathering is mechanical, the verdict
  requires judgment; its findings are reported gaps, never fixes)
- Do not fix anything — report only
- Do not suggest improvements beyond identifying the mismatch
- Each agent produces a structured report with PASS/FAIL per dimension

---

## Phase 0 — Determine the RUN MODE (ALWAYS, before dispatching anything)

An audit run has two modes. They differ in what each agent is told to look at, and the difference
is not cosmetic. **The per-run figures live in ONE table — “The defect series” below, immediately above Phase 1 — and are cited from here, never repeated — the RUN COUNT included, which is that table's row count and nothing else (`/audit` 2026-09-09 T-41).** The mode was practice
before it was instruction — executed twice with its verdict vocabulary supplied by the invoking
prompt rather than by this file. That gap is what this phase closes.

**ALWAYS COUNT the score over the FINDINGS, never over the ledger's row total.** A ledger also
carries `VERSION` and any carried-forward IDs from an earlier run; counting rows instead of
findings is what produced the contradictory score line in Run 2 of `audit-2026-09-02.md` (`11 clean`
in its prose, `12 clean` in its score line, over 26 rows for 24 findings). State the denominator.

**ALWAYS DECIDE the mode from the trigger, and ALWAYS STATE it in the report header —
`mode: baseline` or `mode: verification (over sHASH)`. NEVER emit nothing.**

**The rows below are the FOUR events in `CLAUDE.md` → the `**When it runs**` paragraph under **Utilities**, and nothing else.** That
list is the authority; this table only maps each event to a mode. **NEVER add a trigger here that
`CLAUDE.md` does not carry** — in particular never a time-based one: `CLAUDE.md` says "ALWAYS one
of these events, **never a remembered interval**", and a scheduled row here would be a trigger with
no owner (`/audit` 2026-09-02 K-18).

| CLAUDE.md trigger | Mode |
|---|---|
| (a) after an upstream absorption | **baseline** |
| (b) before a MINOR or MAJOR version bump | **baseline** |
| (c) owner request | **baseline**, unless the owner names a batch to verify |
| (d) after a `/maintenance` session applied an audit batch AND evidence from outside the loop is waiting (a pending project evolution doc, or a HIGH tagged `[observed in use]`) | **verification (over that batch's commit)** |

**Verification mode requires an audit report with `applied sHASH` findings** — that is what its
Part 1 re-reads. Only trigger (d) supplies one.

### Resuming an `INCOMPLETE` run

**The mode is unchanged; only the SCOPE narrows.** A run that wrote
`Report status: INCOMPLETE` named the agents that did not return; the run that finishes it re-dispatches
EXACTLY those agents over the SAME batch. ALWAYS:
(Forward references, flagged: Phase 3 items 1 and 6, and "The defect series" above Phase 1.)
1. **Same mode, same batch hash** — `verification (over sHASH)`, never a new baseline.
2. **A NEW run number, and TODAY's file.** `audit-<today>.md` is where a report goes (Phase 3 item 1), so a
   resume that crosses midnight opens a new file; ALWAYS name the run it completes in the header, and name
   the resuming run in nothing else — the earlier report stays as written.
3. **A NEW ID series** for findings the resuming run files. The incomplete run's series is closed.
4. **Verdict only what the dead agents owed**, and say in the header which IDs the earlier run already
   verdicted. The two ledgers are read together; neither is rewritten.
5. **ONE defect-series row per RUN, not per batch** (see "The defect series"): the resuming row carries the
   BATCH total and says which row it completes. Never amend the earlier row — the table is append-only.
This was executed once with no written home, and every one of these five decisions was taken by judgement
(`/audit` 2026-09-20 AA-5).
**A batch with no evidence from outside the loop does NOT fire trigger (d), whatever it touched** —
`/maintenance` → "Cycle governance" owns the exit and its mechanical test; this table only maps the event
(owner decision, 2026-09-20, replacing the 2026-09-16 form, which fired on four consecutive cycles).

**IF THAT REPORT IS MISSING, TRUNCATED OR CONDENSED, RECONSTRUCT IT FROM GIT AND FILE THE DAMAGE
AS A FINDING — NEVER proceed on the damaged copy and NEVER downgrade to baseline silently.**
```bash
git log --oneline -- assets/docs/audit-YYYY-MM-DD.md   # find the last good revision
git show <hash>:assets/docs/audit-YYYY-MM-DD.md        # read Part 1's input from there
```
**ALWAYS SAY SO in the report header** — `Part 1 input reconstructed from <hash>` — and open a
finding against whatever destroyed it. A write-back deleted 554 of 574 lines of a persisted report,
and this mode had no fallback for the state it left behind (`/audit` 2026-09-09 T-1, T-45). An upstream absorption has no report and no applied
findings, so (a) is baseline; if the owner ALSO wants that absorption's commit re-read, the
did-it-land discipline for it lives in `framework-audit`'s Q4, not here (`/audit` 2026-09-02 K-19).

**ALWAYS RUN THE POST-PUSH D16 BEFORE DISPATCHING, and ALWAYS PERSIST it in the report header.**
A write-back or an audit report is pushed AFTER its own receipts were written, so no persisted gate
covers it until a later session scans the range. Three consecutive runs executed this scan with no
written home, while a maintenance receipt credited `/audit` with owning it (`/audit` 2026-09-15 B-7).
Mechanical, expected result stated:
```bash
if git fetch -q --prune origin; then
  OLD=$(grep -hE '^\*\*(push|push decay|Post-push D16):\*\*' "$(ls assets/docs/audit-*.md | sort | tail -1)" \
    | tr -d '\r' | grep -vE '^\*\*[A-Za-z0-9 -]+:\*\* RED' | grep -oE '— origin/main at s?[0-9a-f]{7,}$' | tail -1 | grep -oE '[0-9a-f]{7,}$')
  NEW=$(git rev-parse -q --verify --short refs/remotes/origin/main)
  if [ -z "$NEW" ]; then echo "RED: no origin/main ref after the fetch — origin/main unverified"
  elif [ -n "$OLD" ]; then echo "origin/main at $NEW"; bash .claude/scripts/d16-gate.sh log "$OLD..$NEW"
  else echo "RED: no recorded origin/main hash — origin/main at $NEW"; fi
else echo "RED: fetch failed — origin/main unknown, nothing below is evidence"; fi
```
**ALWAYS FETCH WITH `--prune`.** Without it a remote that no longer has `main` leaves a stale
`refs/remotes/origin/main`, and the scan read `0 hits` over an endpoint the remote had dropped
(`/audit` 2026-09-16 A-27).
**NEVER write this as `[ -n "$OLD" ] && <gate> || echo …`** — the gate exits non-zero on a hit, so the
`||` branch then ALSO printed "no recorded origin/main hash" beneath a real hit, mislabelling a
published leak as a missing record (found by this batch's own negation proof, 2026-09-16).
**Expected: `origin/main at sNEW` then `…, 0 hits`** (`0 commits scanned` when nothing was pushed
since). **A `RED: no recorded origin/main hash` line means the endpoint must be derived by hand from
the graph — do it, and SAY SO in the header. A `RED: fetch failed` line voids the scan — re-run it,
never report it GREEN.** The fetch fails closed and the hash is anchored to the line end because a
failed fetch read `0 commits scanned` over a range the remote had already extended, and an
unanchored regex matched an old endpoint quoted mid-sentence (this rule's pre-commit verifier,
2026-09-16). **(Forward references, flagged: the header slot is in Phase 2's report format, and the
`escalated` status is Phase 3 item 2's.)** **A hit is a PUBLISHED privacy finding: file it `escalated — owner decision
pending` and NEVER print the matched identifier.**
**ALWAYS REPORT — `**Post-push D16:** log sOLD..sNEW [(endpoint derived by hand — why)] → N commits scanned, H hits — origin/main at sNEW` or `**Post-push D16:** RED — [fetch failed | no origin/main ref | gate could not check: reason] — origin/main unverified`.
**A RED line NEVER ends with a hash** — the maintenance detector and this step read the last hash as
"scanned up to here" (`.claude/commands/maintenance.md` → the `push:` rule).
NEVER emit nothing.**

### Baseline mode

Checks *claim vs fact* across the 17 dimensions. This is Phase 1 as written below, unchanged.

### Verification mode — ADDITIVE, never a replacement

Verification mode runs the full 17 dimensions **and** gives every agent a **Part 1 mandate**
before them. Baseline mode is structurally blind to a fix that is PRESENT but landed in the wrong
place, contradicts its neighbour, or orphaned the block below it — every such defect passes an
"is the required text present?" check.

**In verification mode, ALWAYS ADD this mandate to every agent's prompt, verbatim:**

> **Part 1 (do this FIRST).** Read `assets/docs/audit-<the applied report>.md` and the commit that
> applied it. For every finding marked `applied sHASH` that falls in your dimensions: read the
> structure AROUND the fix — the heading it now sits under, the blocks immediately after it, the
> sibling twin file, the instruction that cites it — and classify it with ONE of these verdicts:
> - **CONFIRMED-FIXED** — the fix landed, in the right place, and its class was swept.
> - **PARTIALLY-FIXED** — the named instance is fixed; something the finding required is not.
> - **FIXED-BUT-CLASS-NOT-SWEPT** — correct at the named line; the same defect survives elsewhere.
> - **NOT-FIXED — no diff exists.** The finding is marked `applied` and **nothing was written**.
>   **ALWAYS SETTLE THIS FIRST, MECHANICALLY, BEFORE READING ANYTHING:**
>   `git log -L <line>,<line>:<file> --oneline <batch range>` → **expected: at least one commit;
>   empty is NOT-FIXED.** This verdict is not a weaker PARTIALLY-FIXED — nothing was fixed — and
>   the enumeration lacked it for the whole series to date, so cases of it were absorbed under a softer label and
>   the defect series is an under-count to that extent. Ten of forty-five landed here in one batch,
>   six of them under a commit message asserting a fix that does not exist
>   (`/audit` 2026-09-09 T-10, T-51).
> - **INTRODUCED-A-DEFECT** — the fix is present AND created a new problem (wrong nesting, a
>   contradiction with a neighbouring line, a forward reference with no receiver, a stale count).
>   May combine with any verdict above.
>
> Cite file:line evidence for EVERY verdict. A verdict with no structural evidence is not a
> verdict. Any verdict other than CONFIRMED-FIXED becomes a NEW finding with a new ID.

**ALWAYS OPEN the merged report with a Part 1 verification ledger** — one row per applied finding
(ID | verdict | evidence) — followed by the score line
`N clean · N partially-fixed · N class-not-swept · N not-fixed · N introduced-a-defect` — **all
five, copied from the verdict list above** (`/audit` 2026-09-10 U-12) — and THEN the new findings. Phase 3's
carry-forward rule (still-`open` findings) is unchanged and additional to this ledger: **an
`applied` finding is re-verified in this mode, never skipped because its status says applied.**

---


### The defect series — THE ONE TABLE. Every other surface CITES it; none repeats it.

Defects found in already-`applied` findings, one row per verification run. **A figure appearing
anywhere else in the repo is a copy and is forbidden** — four surfaces carried this series, three
disagreed with each other, and one asserted a count its own list contradicted (`/audit` 2026-09-04
R-7, R-8). **Append a row; never re-derive the old ones.**

| # | Report file | Run | How the mode is declared there | Not clean / verdicted |
|---|---|---|---|---|
| 1 | `audit-2026-08-31.md` | Run 2 | `# Run 2 — verification pass` (predates the `Run mode:` convention) | 4 of 15 |
| 2 | `audit-2026-09-02.md` | Run 2 | `## Part 1 — Verification ledger for 0954d69` | 13 of 24 |
| 3 | `audit-2026-09-02.md` | Run 3 | `**Run mode:** verification (over a28f661)` | 11 of 30 |
| 4 | `audit-2026-09-02.md` | Run 4 | `**Run mode:** verification (over afccff3)` | 8 of 17 |
| 5 | `audit-2026-09-02.md` | Run 5 | `**Run mode:** verification (over f2fcccf)` | 27 of 51 |
| 6 | `audit-2026-09-03.md` | Run 6 | `**Run mode:** verification (over a2f4890)` | 23 of 51 |
| 7 | `audit-2026-09-03.md` | Run 7 | `**Run mode:** verification (over s1c7c1f9 + sbb8cbec)` | 22 of 45 |
| 8 | `audit-2026-09-04.md` | Run 8 | `**Run mode:** verification (over the Run 7 batch)` | 21 of 36 |
| 9 | `audit-2026-09-04.md` | Run 9 | `**Run mode:** verification (over the Run 8 batch)` | 25 of 42 |
| 10 | `audit-2026-09-09.md` | Run 10 | `**Run mode:** verification (over the Run 9 batch)` | 38 of 45 |
| 11 | `audit-2026-09-10.md` | Run 11 | `**Run mode:** verification (over the Run 10 batch)` | 24 of 51 |
| 12 | `audit-2026-09-14.md` | Run 2 | `**Run mode:** verification (over ecace7a)` | 10 of 13 |
| 13 | `audit-2026-09-14.md` | Run 3 | `**Run mode:** verification (over 700a382)` | 5 of 6 |
| 14 | `audit-2026-09-15.md` | Run 1 | `**Run mode:** verification (over 6b4baa8 · 30c3d6e · d156dc4)` | 10 of 17 |
| 15 | `audit-2026-09-15.md` | Run 2 | `**Run mode:** verification (over afa8ef0)` | 11 of 15 |
| 16 | `audit-2026-09-15.md` | Run 3 | `**Run mode:** verification (over 7a7d1db)` | 7 of 10 |
| 17 | `audit-2026-09-16.md` | Run 1 | `**Run mode:** verification (over 5ecefa9 · 28b157a · db70667 · 847d18f)` | 15 of 31 |
| 18 | `audit-2026-09-19.md` | Run 1 | `**Run mode:** verification (over 194f44a)` | 7 of 18 |
| 19 | `audit-2026-09-19.md` | Run 2 | `**Run mode:** verification (over 87210b1)` | 4 of 9 (INCOMPLETE run — 3 of 6 agents returned; 24 of 33 applied IDs unverdicted) |
| 20 | `audit-2026-09-20.md` | Run 3 | `**Run mode:** verification (over 87210b1)` | 12 of 33 (the BATCH total; this run completed row 19's INCOMPLETE pass — the same batch, one row per RUN) |

**A resumed run appends its OWN row** (Phase 0 → "Resuming an `INCOMPLETE` run"): the earlier row keeps the
partial denominator it was written with, and the later row carries the batch total and names the row it
completes. Two rows for one batch is the honest shape; amending the earlier one is forbidden.

**No trend** — derive each row's share from the table above; NEVER copy the percentages onto this
line (it carried 11 figures for a 12-row table, `/audit` 2026-09-14 Y-13). Batch size has been
exonerated five times and should not be re-litigated without new evidence.

## Phase 1 — Dispatch Audit Agents

Launch ALL 6 agents below **in a single message** using 6 parallel Agent tool calls.
Do NOT wait for one to finish before launching the next.

Each agent receives its full contract as the prompt. Use `subagent_type: "general-purpose"` for all.

**ALWAYS PREPEND BOTH RULES BELOW to EVERY agent prompt, verbatim.** The Authorized-operations
list above is session text: no agent receives it, so its "NEVER push" reached none of them, and an
agent executing D10.0 pushed two planted commits to the real remote (`/audit` 2026-09-16 A-1).
**The second rule reached the agents through the INVOKING PROMPT for four runs and appeared nowhere
in this file**, so every run got it only if whoever dispatched remembered — the K-15 / L-3 class
EVERY agent contract below names (`/audit` 2026-09-21 AD-7).
The `--keep` ban below reached no agent for the same reason: it lived only in the
Authorized-operations list, which is session text (`/audit` 2026-09-21 C-11).

> Run every check that WRITES, every probe, every planted state and every persisted script through
> `bash .claude/scripts/probe-sandbox.sh run [--staged] -- <command>`, giving a script by
> ABSOLUTE path, and paste its final `probe-sandbox:` line beside the output.
> NEVER run `git commit`, `git push`, `git reset`, `git stash`, `git checkout` or `git remote`, and
> NEVER write a file, inside the live repository.
> NEVER put a read-only scan in the sandbox: `d16-gate.sh staged | log | dir` and `git log`/`show`/
> `diff`/`grep` run in place, where they see everything — and so does `git fetch`, which writes
> only remote-tracking refs and which the two `origin/main` endpoint detectors (one in
> `maintenance.md`, one in this file) both open with. D10.0 tells you to extract and run them.
> A `probe-sandbox: RED` line STOPS you: make it the FIRST line of your report and return.
> **NEVER pass `--keep`** — a kept clone survives the command and leaves a copy of the repo on disk.

> **TIER OF REFERENCE — a reference resolves in the tier where the text that CITES it RUNS, never
> in the directory you happen to be standing in.** This repo is a FACTORY: most of what a shipped
> template cites is created INSIDE a project by bootstrap from the `docs/modules/` sources.
> **NEVER say "this path does not exist here" from an `ls` in this root** — a template citing
> `.claude/rules/X` or `.claude/phases/Y` is CORRECT even when the path is absent here, and some
> such paths DO exist here on purpose (this repo keeps the runtime subset its own commands need,
> which `CLAUDE.md`’s structure block enumerates). Absence proves nothing and presence proves
> nothing either.
> **The MIRROR is equally a defect and is the half that gets missed:** a SHIPPED artifact citing
> something that lives ONLY in this repo — a `/maintenance` or `/audit` section, a command file —
> is unresolvable in every project and MUST carry an availability qualifier.

**An agent that returns on a `probe-sandbox: RED` did not complete its dimensions** — Phase 3 writes
`Report status: INCOMPLETE`, naming that agent and the RED line's parts — or, for a fail-closed RED, its reason. (Forward reference, flagged: Phase 3's status lines.)

---

### Agent 1: Structural Sync (Dimensions A, D4, D9, D16)

```
You are a structural sync auditor for the Agentic Engineering Framework.
Your job is purely mechanical: read files, compare claims against disk, report mismatches.
Do NOT fix anything. Do NOT suggest improvements.

FILES TO READ:
1. docs/modules/skills/README.md
2. CLAUDE.md (the "Repository Structure" section with ASCII diagram)
3. List contents of .claude/skills/ (folders only)
4. List contents of docs/modules/skills/ (folders only, exclude README.md)
5. A LISTING of `projects/` — the folder names themselves (D16.1 builds the blocklist from them)
6. ALL tracked files (D16.3) — `git ls-files`
7. `.claude/docs/` (D16.3) and `docs/modules/**` + `examples/**` (D16.4, double scrutiny)
8. Each project's own `CLAUDE.md` / `.claude/phases/project.md` / `assets/docs/prd.md` (D16.2),
   and each project's CODE and SCHEMA files — needed by the third blocklist source `CLAUDE.md`
   declares, **which IS now a numbered check: `D16.2c` below.** (This line read "NOT yet a numbered
   check" for one full batch after `D16.2c` was installed forty lines below it — a forward
   reference whose receiver arrived and was never told. When you install the receiver of a stated
   gap, ALWAYS grep the file for the sentence that states the gap — `/audit` 2026-09-03 N-11.)
9. The agent's persistent memory directory, every file incl. `MEMORY.md` (D16.3b) — path resolved
   from the session context
10. Git history: `git rev-list --all` contents AND `git log --all` messages (D16.3c)
11. The PREVIOUS audit report in `assets/docs/` — required to emit the `accepted-risk` OBSERVATION
    Phase 3 mandates instead of re-reporting a closed item as a hit

**Every file a CHECK below names MUST appear in this list (`FILES TO READ` / `INPUTS` — the same obligation under either heading).** Reading it "because the check says so"
while the list omits it is how a working check ends up living in the invoking prompt instead of in
this file (`/audit` 2026-09-02 K-15, L-3).

CHECKS:

[A] Dual placement compliance
  A.1. List every folder in docs/modules/skills/
  A.2. List every folder in .claude/skills/
  A.3. For each skill in .claude/skills/: verify it also exists in docs/modules/skills/
  A.4. Note: most skills belong in docs/modules/skills/ ONLY. Only runtime skills
       needed by framework commands belong in .claude/skills/ (currently only
       cross-cutting-analysis qualifies — used by /prd_planning and /prd_change).

[D4] Skills README list vs disk
  D4.1. Parse the skills table in docs/modules/skills/README.md — extract every skill name
  D4.2. List every folder in docs/modules/skills/ (exclude README.md)
  D4.3. Which folders exist on disk but are NOT listed in the README table?
  D4.4. Which names are listed in the README but have NO folder on disk?
  D4.5. Check any count claims in the README (e.g., "10 skills") against actual folder count

[D9] CLAUDE.md ASCII diagram vs actual file structure
  D9.1. Extract the ASCII tree from CLAUDE.md "Repository Structure" section
  D9.2. List actual file/folder structure (top 3 levels, excluding .git/ and projects/)
  D9.3. For each entry in the diagram: verify it exists on disk
  D9.4. For each significant file/folder on disk (top 3 levels): verify it appears in the diagram
  D9.5. Check count comments in the diagram (e.g., "5 slash commands", "12 process skills")
        against actual counts on disk

[D16] Project-information isolation (privacy)
  D16.1. Build the blocklist DYNAMICALLY: list the folder names under projects/ (each name
         plus obvious variants — hyphen/underscore swaps, separator-less and space-joined forms,
         with and without suffixes — AND each PART of 4+ characters matched at LETTER boundaries
         and in CamelCase, so a `_`-glued snake_case identifier hits; `/audit` 2026-09-14 Y-3).
         **ALWAYS run the folder-name half with `bash .claude/scripts/d16-gate.sh`** — `staged`
         for tracked files, `dir <path>...` for `.claude/docs/` and the memory directory, `log --all`
         for history. It derives every variant above, prints one line and never a match.
         **ALWAYS feed the D16.2 / D16.2c identifiers it does not derive through `D16_EXTRA`** (D16.3c).
  D16.2. From each project's own CLAUDE.md / project.md (read-only), harvest additional
         identifiers: client/person names, deployment domains (*.vercel.app, custom
         domains), repo URLs, infra refs (e.g. Supabase project ids).
  D16.2b. ALSO scan for VALUE-shaped leaks (data, not just identifiers), by format:
         secret shapes (JWT `eyJ...`, key prefixes sk-/ghp_/AKIA/xox, `user:pass@`
         connection strings, long Bearer tokens), PII shapes (BR phone `+55...`,
         CPF `NNN.NNN.NNN-NN`, CNPJ, real-looking e-mails), and `.env`/dump files.
         Mentions of the CONCEPTS (security rules teaching about secrets) and
         detection regexes inside scanner examples are legitimate — only actual
         VALUES and synthetic-fixture violations (non-obviously-fake PII) fail.
  D16.2c. **THIRD SOURCE — source-project CODE identifiers. ALWAYS derive it; never stop at two.**
         Harvest every camelCase / snake_case identifier appearing in CODE EXAMPLES inside
         **EVERY framework-layer surface — `docs/**` (not only `docs/modules/`), `examples/**`,
         `.claude/**`, `assets/docs/**` and the root `*.md` files** — then cross-grep each against
         the projects' own `*.ts/*.tsx/*.js/*.sql/*.py` sources.
         **ALWAYS EXCLUDE EVERY VERBATIM FRAMEWORK→PROJECT COPY PATH FROM THE COMPARISON SET, AND
         ALWAYS DERIVE THAT LIST FROM `bootstrap.md` RATHER THAN TYPING IT** — every `cp`/`cp -r`
         target under `projects/` is a copy path, and a typed list has now been short twice:
         ```bash
         grep -oE 'projects/\$ARGUMENTS/[A-Za-z0-9_./-]+' .claude/commands/bootstrap.md \
           | grep -E '(examples|\.claude|scripts)' | sort -u
         ```
         **Expected: at least 5 paths.** As of v2.31.5 they are
         `projects/*/assets/examples/`, `projects/*/.claude/skills/`, `projects/*/.claude/agents/`,
         `projects/*/.claude/rules/` **and `projects/*/scripts/`** — Bootstrap
         Step 1.5 copies `examples/` there, Steps 5.7/5.8 copy `docs/modules/skills/`,
         `docs/modules/agents/` and `docs/modules/rules/` into the next three, and **Step 5.7
         extracts `check_agent_frontmatter.md` into the fifth**. Naming only the
         first left three equally verbatim copy targets unexcluded (`/audit` 2026-09-04 Q-30) and
         the fifth was still missing a batch later, producing six false positives on execution
         (`/audit` 2026-09-09 T-10, filed as R-19 and written back `applied` with nothing landed). So a
         match there means the identifier travelled framework → project — the OPPOSITE
         direction from a leak. Without the exclusion the check errs BOTH ways: it files a
         false hit, or it teaches the auditor to wave real hits off as "probably our own
         template". Also exclude `node_modules/`, `.next/` and build caches, which carry the
         same copies and make the grep time out (`/audit` 2026-09-03 P-36). **`assets/docs/` is NOT exempt**
         (D16.5 says so explicitly) and it is where the first full run's worst hits actually lived:
         scoping this harvest to templates alone missed a lineage doc carrying a source-project
         function name, two table/column names, a source file name and three source-project
         session numbers (`/audit` 2026-09-03 N-13, N-16, N-17).
         **ALSO harvest source-project SESSION NUMBERS** (`S12`, `Sessão 90`) — they identify a
         single project's history as surely as a function name does. A hit means a source-project
         function, table, column or route name is shipping inside a framework template.
         **Standard industry names are LEGITIMATE** (`order_items`, `organization_members`,
         `organizationId` — canonical schema vocabulary that identifies nobody); a HAND-ROLLED
         name is not. `CLAUDE.md` declares this source; it was documented there and absent here
         for one full batch, which is why a source-project function name in a shipped template
         survived four consecutive runs (`/audit` 2026-09-02 L-19, M-36).
  D16.3. **`.claude/settings.local.json` is EXEMPT** — gitignored, machine-local, and auto-written
         by the permission prompt with absolute paths that necessarily contain project folder
         names. NEVER report it as a hit (`CLAUDE.md` declares the exemption; `/audit` K-37, M-36).
         Grep every OTHER framework-layer file for every blocklist entry, case-insensitive:
         all TRACKED files AND `.claude/docs/` (gitignored agent notes — the isolation
         principle covers the agent's own documents too). Exclude only projects/ and .git/.
         **ALWAYS scan PATHS as well as CONTENTS** — a folder name present only in a file or
         directory NAME is a hit, and a contents-only grep reads 0 on it (`/audit` 2026-09-14 Y-4).
  D16.3b. Agent-layer scan (MANDATORY when resolvable): the agent's persistent memory
         directory lives OUTSIDE the repo — resolve its path at runtime from the session
         context (the "# Memory" section of the system prompt, or the additional working
         directory whose path ends in `memory`). Run BOTH the blocklist grep (D16.3) and
         the value-shape scan (D16.2b) over EVERY file in it, including MEMORY.md.
         **EXCLUDE UUID FRAGMENTS AND URLs BEFORE APPLYING THE HASH RULE.** The harness writes
         `originSessionId:` UUIDs and artifact URLs into memory frontmatter, and their 7-hex
         runs look exactly like commit hashes. Applied literally without this exclusion the
         rule below produced **12 false positives** on a clean memory directory — which is
         `Q-36`'s own defect (a cross-grep prone to false positives whose text does not say
         so), filed one finding earlier in the same run and not applied to this sibling
         (`/audit` 2026-09-04 Q-29). Scope the scan to tokens NOT inside a UUID and NOT inside
         a URL, then apply:
         **COMMIT HASHES IN MEMORY ARE DERIVABLE, NEVER JUDGED BY EYE** — a 7-hex token is
         LEGITIMATE if and only if `git cat-file -e <hash>^{commit}` resolves it in THIS repo;
         anything that does not resolve belongs to another repository and is a HIT. Run it per
         hash. On the first execution this separated 8 framework hashes from 5 source-project
         ones in the same files, which no amount of reading could have done
         (`/audit` 2026-09-03 P-30). Sweep session coordinates and branch names here too — the
         memory is outside the repo, so no tracked-file sweep ever reaches it.
         If the path cannot be resolved (e.g. audit adapted to run outside Claude Code),
         report the dimension as PARTIAL with "agent memory: SKIPPED — path not
         resolvable" — never silently omit the surface.
  D16.3c. Git-history scan: names and values survive deletion — a leak removed from the
         tree still lives in every commit that contained it. Scan ALL commits:
         - **ONE PASS FOR EVERYTHING — folder names, the D16.2/D16.2c identifiers and the D16.2b
           value shapes — over patches, messages, raw commit objects, tag objects AND paths.**
           ALWAYS write the identifiers (one per line) and the value-shape EREs (one per line) to
           two files OUTSIDE the repo — never tracked, never printed — and run:
           `D16_EXTRA=<ids file> D16_EXTRA_RE=<EREs file> bash .claude/scripts/d16-gate.sh log --all`
           (expected: `…, 0 hits`; the same two variables apply to `staged` and `dir`).
         - **NEVER scan these patterns with `git grep -I` or `git log --format="%h|%s|%b"`** — both read
           0 on UTF-16, NUL-byte and `binary`-attributed files, on paths, on author e-mails and on
           tag objects, and both interpolate the pattern (`/audit` 2026-09-15 Z-3).
         - A non-zero count is LOCATED by narrowing the scope (`log <A>..<B>`, `dir <path>`), NEVER
           by printing the matched line.
         Classify each hit by reachability: in UNPUSHED commits → fixable locally
         (`git filter-branch --msg-filter` for messages, tree rewrite for contents);
         in PUSHED history → escalate to the owner (requires history rewrite + force
         push — owner decision, NEVER automatic).
  D16.4. Templates get DOUBLE scrutiny (docs/modules/**, examples/**): they are copied into
         every bootstrapped project — a project identifier inside a template broadcasts one
         client's information to all future clients.
  D16.5. Report every hit with file, line, and identifier class. Zero hits = PASS.
         Lineage/history docs are NOT exempt — they must use anonymized placeholders
         (e.g. "projeto-fonte", "a prior project").

REPORT FORMAT:


## Agent 1: Structural Sync

### PART 1 — Verification ledger (verification mode ONLY; write `Part 1: N/A — baseline mode` otherwise)
| ID | Verdict | Structural evidence (file:line) |
|----|---------|--------------------------------|

### [A] Dual Placement
- Status: PASS / FAIL
- Findings: [list of mismatches, or "none"]

### [D4] Skills README vs Disk
- Status: PASS / FAIL
- README lists: [count] skills
- Disk has: [count] folders
- Missing from README: [list]
- Missing from disk: [list]
- Count claim accuracy: [correct / incorrect — says N, actually M]

### [D9] CLAUDE.md Diagram vs Disk
- Status: PASS / FAIL
- In diagram but not on disk: [list]
- On disk but not in diagram: [list]
- Count mismatches: [list]

### [D16] Project-Information Isolation
- Status: PASS / PARTIAL / FAIL
- Blocklist derived — **ALL THREE sources, each counted separately**: [N project folder names] + [M identifiers harvested from project DOCS] + [K source-project CODE identifiers and session numbers (D16.2c)]. **A two-number report means the third source was not run** (`/audit` 2026-09-03 N-12).
- Surfaces scanned: tracked files | .claude/docs/ | agent memory ([path] or SKIPPED — reason) | git history ([N] commits: contents + messages)
- Hits: [surface — file:line or commit hash — identifier/value (class), or "none"]
- Unpushed-vs-pushed: [for history hits — which are still locally fixable]
```

---

### Agent 2: Bootstrap Integrity (Dimensions D5, D11, D13, D14)

```
You are a bootstrap integrity auditor for the Agentic Engineering Framework.
Your job is purely mechanical: read bootstrap.md and verify its internal consistency
and external references. Do NOT fix anything.

FILES TO READ:
1. .claude/commands/bootstrap.md (entire file — primary source)
2. .claude/commands/existing_project_adaptation.md — the sibling twin. D11.4's forward-reference
   check and D13's PRD comparison apply to BOTH commands, and reporting EPA coverage while this
   list named only bootstrap is how that coverage came to exist in the dispatch prompt and nowhere
   on disk (`/audit` 2026-09-03 P-20).
3. List files in docs/modules/templates/
4. List files in docs/modules/agents/
5. List files in docs/modules/rules/
6. List folders in docs/modules/skills/
7. docs/modules/templates/claude_md.md
8. .claude/commands/prd_planning.md (the PRD Structure template section near the end)
9. docs/agentic_engineering_framework.md — the "N-step pipeline" claims and the pipeline ASCII
   diagram (D11.7 compares both against the command file)
10. CLAUDE.md — cited by the step-numbering and output checks

**Every file a CHECK below names MUST appear in this list (`FILES TO READ` / `INPUTS` — the same obligation under either heading).** Reading it "because the check says so"
while the list omits it is how a working check ends up living in the invoking prompt instead of in
this file (`/audit` 2026-09-02 K-15, L-3).

CHECKS:

[D5] Bootstrap file references resolve
  D5.1. Extract every file path referenced in bootstrap.md (cp commands, Read references,
        template paths like docs/modules/templates/claude_md.md, agent paths, etc.)
  D5.2. For each path: verify the file exists on disk
  D5.3. Report any path that does NOT resolve
  D5.4. Check naming convention consistency (bootstrap references underscore-named sources
        in docs/modules/agents/ and copies to hyphen-named targets in .claude/agents/)

[D11] Bootstrap step sequencing
  D11.1. List every Step number with a 1-line summary of what it does
  D11.2. For each step, identify what it PRODUCES (files created, directories made)
  D11.3. For each step, identify what it CONSUMES (files it reads that were created by earlier steps)
  D11.4. Check: does any step reference a file or output created by a LATER step?
  D11.5. Count: how many primary steps (1, 2, 3...) and sub-steps (1.5, 5.7, 14.5...)?
  D11.6. Total discrete steps = primary + sub-steps
  D11.7. Compare total against any "N-step pipeline" claims in this file or in
         docs/agentic_engineering_framework.md

[D13] PRD template ↔ bootstrap reader compatibility
  D13.1. Read the PRD Structure template at the end of prd_planning.md — extract every
         section number and heading (e.g., "Section 1: Product Vision", "Section 5: Architecture")
  D13.2. Read bootstrap.md Steps 1-3 — what PRD section numbers/headings does it reference?
  D13.3. Compare: does bootstrap reference any PRD section that the PRD template does NOT define?
  D13.4. Compare: does the PRD template define sections that bootstrap never reads?
         (This is INFO, not a failure — some sections may only be for human reference)

[D14] Bootstrap output completeness
  D14.1. Read docs/modules/templates/claude_md.md — list every reference to a skill, agent,
         rule, or file that the generated CLAUDE.md will point to
  D14.2. For each reference: trace it to a bootstrap step that creates or copies that file
  D14.3. Flag any reference in the template that has NO corresponding bootstrap step
  D14.4. If bootstrap has a final report step: verify it lists every file created in prior steps

REPORT FORMAT:


## Agent 2: Bootstrap Integrity

### PART 1 — Verification ledger (verification mode ONLY; write `Part 1: N/A — baseline mode` otherwise)
| ID | Verdict | Structural evidence (file:line) |
|----|---------|--------------------------------|

### [D5] File References
- Status: PASS / FAIL
- Total paths found: [N]
- Resolved: [N]
- Unresolved: [list with line numbers]

### [D11] Step Sequencing
- Status: PASS / FAIL
- Primary steps: [N], Sub-steps: [N], Total: [N]
- Claimed: "[N]-step pipeline" — Actual: [M] discrete steps
- Forward references: [list, or "none"]

### [D13] PRD ↔ Bootstrap Compatibility
- Status: PASS / FAIL
- PRD sections defined: [list]
- Bootstrap reads sections: [list]
- Bootstrap reads but PRD lacks: [list, or "none"]
- PRD defines but bootstrap ignores: [list — INFO only]

### [D14] Output Completeness
- Status: PASS / FAIL
- Template references: [count]
- Traced to bootstrap steps: [count]
- Untraced: [list, or "none"]
```

---

### Agent 3: Activation Chain (Dimensions D6, D7)

```
You are an activation chain auditor for the Agentic Engineering Framework.
Your job is purely mechanical: read agent files and verify vocabulary alignment
and description pattern compliance. Do NOT fix anything.

FILES TO READ:
1. docs/modules/agents/code_reviewer.md
2. docs/modules/agents/security_reviewer.md
3. **EVERY file in `docs/modules/agents/` — GLOB it, never type it:** `ls docs/modules/agents/*.md`.
   A typed roster here is the idiom D7.5 bans one level down, in this same file, and it goes
   stale the moment an agent is added (`/audit` 2026-09-09 T-44).
4. docs/modules/skills/validation-orchestrator/SKILL.md and
   docs/modules/skills/rules-agents-updater/SKILL.md — the two shipped components that CARRY the
   declaring-component vocabulary; D6 findings have landed in both (`/audit` 2026-09-03 P-12)
5. examples/agents/ — list all files, read those that match gap-declaration domains
   (e.g., concurrency, performance, accessibility, visual regression, data-integrity, secrets,
   compliance, etc. — visual regression is named explicitly because its install link has broken
   twice, on the bootstrap path and then on the EPA path)
6. .claude/rules/component-design.md (sections 1-3: Gap-Declaration, Pushy Description,
   Vocabulary Alignment)
7. docs/modules/rules/component_design.md — the TEMPLATE twin of the same rule (D6.8 checks BOTH)
8. .claude/commands/bootstrap.md — the specialist install table, the install PROSE, and the
   Step 12.5b executable loop (D6.7, D7.6)
9. .claude/commands/existing_project_adaptation.md — the twin install table, the twin install
   PROSE, and the Step 5.1 executable loop (D6.7, D7.6)
10. docs/agentic_engineering_framework.md — the coverage-gap handling paragraph and the validator
    report format; D6.9's fourth-surface check cannot run without it

**Every file a CHECK below names MUST appear in this list (`FILES TO READ` / `INPUTS` — the same obligation under either heading).** Reading it "because the check says so"
while the list omits it is how a working check ends up living in the invoking prompt instead of in
this file (`/audit` 2026-09-02 K-15, L-3).


CHECKS:

[D6] Gap-declaration vocabulary alignment
  D6.1. Read code_reviewer.md — find the "Coverage Gap Declaration" section. Extract every
        gap domain and its key phrase (e.g., "concurrency gap", "performance gap",
        "accessibility gap", "data integrity gap")
  D6.2. Read security_reviewer.md — same extraction (e.g., "static analysis gap",
        "secrets coverage gap", "federation protocol gap", "compliance gap",
        "infrastructure security gap")
  D6.2b. **READ `validator.md` AND EXTRACT ITS GAP PHRASES TOO — it is the THIRD DECLARING
        COMPONENT** (`component-design.md` §1 names three: `code-reviewer`, `security-reviewer`,
        `validator`, which declares the visual-regression gap from inside its own Validation
        Report). Without this step the extraction set is two of three and D6.3 searches for phrases
        it never collected; D6.7 patched over the hole by phrase while D6.3 still could not see it
        (`/audit` 2026-09-03 N-33). **ALWAYS report the declarer count — `declarers extracted: N of M`, where **M is DERIVED,
        never typed**, and it MUST read BOTH forms the shipped loop recognises — the indented `> X gap:` and
        the bold `**X gap**`:
        `grep -rlE '(^ *> *[A-Za-z][A-Za-z0-9 &./-]*gap:|[*][*][A-Za-z][A-Za-z0-9 &./-]*gap[*][*])' docs/modules/agents/ | wc -l`
        A hard-coded `3` in the
        file whose D6.8 says "count them, do not assume two" is the same defect one level down,
        and it cannot detect a FOURTH declarer — which is the risk D6.8 exists to catch
        (`/audit` 2026-09-03 P-11). **`N != M` is RED — BOTH directions.** The earlier form grepped the
        literal `gap:` with `-rlc` (where `-l` silently suppresses `-c`), so a declarer written only in the
        bold form — which is exactly how `validator.md` declares — was invisible to `M` while the loop
        counted it, and the only RED was `N < M`, the direction that case never takes
        (`/audit` 2026-09-20 AA-14, AA-15).**
  D6.3. For each gap phrase: search ALL agent descriptions in docs/modules/agents/ AND
        examples/agents/ for matching vocabulary in the description: field
  D6.4. The match must be exact or near-exact (per component-design.md §3 vocabulary alignment)
  D6.5. Report broken links: gap declared by ANY declaring component (see D6.8 — there are three,
        not two) but NO specialist agent has matching description (= specialist never activated)
  D6.6. Report orphaned specialists: agent description references a gap phrase that **no declaring
        component** declares (= agent exists but can never be triggered). **Scope this to the
        D6.8 set, never to the two reviewers** — a validator-declared gap would otherwise read as
        an orphaned specialist (`/audit` 2026-09-02 M-13).
  D6.7. **INSTALL-LINK PARITY — the link that has broken TWICE.** For every gap from D6.1/D6.2
        AND every gap D6.8 attributes to any OTHER declaring component (run D6.8 first),
        verify a matching row exists in the specialist install table of BOTH
        `.claude/commands/bootstrap.md` AND `.claude/commands/existing_project_adaptation.md`.
        **Mechanical: `diff` the two install BLOCKS — the table AND the prose around it, never the
        table alone — expected: empty.** Extract from each command file the span running from the
        paragraph that introduces the install table to the paragraph that closes it, and diff those.
        The tables have been byte-identical while the prose diverged in six places, so a
        table-only diff returns empty on the very state this check exists to find
        (`/audit` 2026-09-04 R-35, written back `applied` with nothing landed; re-filed
        2026-09-09 T-10). A gap that is declared and has a
        specialist but no install row on ONE path is a FAIL, not a nit: the declaring component will declare
        it forever and the specialist will never be installed on that path. This is exactly how
        `visual regression` broke as H-2 (bootstrap) and again as J-5 (EPA), while D6 returned
        PASS both times because it only checked phrase alignment.
  D6.8. **GAP SOURCES — count them, do not assume two.** Extract every component that DECLARES a
        gap, not only the two reviewers: grep `gap` across `docs/modules/agents/`. Verify that
        `component-design.md` §1/§3 (BOTH twins: `.claude/rules/` and `docs/modules/rules/`)
        enumerate the same set. A specialist description naming a source the policy does not list
        is a FAIL.

  D6.9. **VERIFY NO FOURTH SURFACE CONTRADICTS the declarer set.** `component-design` §1/§3 in both
        twins is the policy; `docs/agentic_engineering_framework.md`'s coverage-gap handling
        paragraph is a THIRD description of the same thing and has been stale before. A surface
        naming two declarers where the policy names three is a FAIL (`/audit` 2026-09-03 P-14).
[D7] Pushy Description pattern compliance
  D7.1. From component-design.md §2, the required pattern is:
        [Core function line — MANDATORY] +
        USE PROACTIVELY when [triggers] +
        NOT needed for [exclusions] +
        Without this, [consequence] +
        Produces [Report] → [OUTCOME]
  D7.2. For each agent in docs/modules/agents/ with invocation: subagent:
        check which elements of the pattern are present in its description: field
  D7.3. For each agent in examples/agents/ with invocation: subagent: same check
  D7.4. Flag the anti-pattern: descriptions that are ONLY triggers ("USE PROACTIVELY when X.
        NOT needed for Y. Without this Z.") with NO core function statement
  D7.5. **DO NOT ENUMERATE the protocol-spawned set — DERIVE it.** The rule is structural, and
        stating it as a list has now failed three times, going 5 → 7 → 9 while the true figure moved
        with the directory (`/audit` 2026-09-02 M-22, then 2026-09-03 N-31, whose own count of
        nine was itself short by one).
        **The invariant: EVERY agent in `docs/modules/agents/` is spawned by PROTOCOL, and the
        gap-activated specialists live in `examples/agents/`.** The declaring components
        (`code-reviewer`, `security-reviewer`, `validator`) are protocol-spawned too — they DECLARE
        gaps, so they are never themselves activated by one. Process agents additionally use
        "MUST run" style, acceptable per that role.
        **ALWAYS PROVE the invariant instead of trusting it** — mechanical check, expected result
        stated:
        ```bash
        for a in docs/modules/agents/*.md; do
          sed -n '/^description:/,/^\(---\|[A-Za-z_][A-Za-z0-9_.-]*:\)/p' "$a" | grep -c "declares a"
        done | sort -u
        ```
        **Expected: `0` and nothing else.** A non-zero means a gap-activated agent has appeared in
        `docs/modules/agents/` and the invariant no longer holds — THAT is the finding, not the
        agent's PARTIAL verdict.
        **A PARTIAL verdict on any agent in `docs/modules/agents/` is SANCTIONED and NEVER a
        finding.** The Pushy Description pattern is most critical for the specialist agents in
        `examples/agents/`, which ARE gap-activated and where a PARTIAL IS a finding.

  D7.6. **EXTRACT THE EXECUTABLE ACTIVATION-CHAIN CHECK FROM THE COMMAND FILES AND RUN IT.**
        `bootstrap.md` Step 12.5b and `existing_project_adaptation.md` Step 5.1 each carry a shell
        loop that resolves every gap-declaring specialist against the three declaring components.
        **It is the framework's only EXECUTABLE activation check, and for four runs it had no
        auditor on disk** — the verification lived in whichever prompt happened to be dispatched
        (`/audit` 2026-09-04 Q-3, Q-33).
        **ALWAYS:**
        1. Build a synthetic project **OUTSIDE THE REPO — ALWAYS in a scratch directory, NEVER
           under any tracked path.** This command is read-only; a synthetic project written inside
           the working tree is a write, and it can be committed by a later session by accident.
           T-43's fix landed the regression table and "against BOTH twins" and left this half
           prompt-only, which is T-43's own class (`/audit` 2026-09-10 U-31).
           Into that directory: every `docs/modules/agents/*.md` (renamed `_`→`-`) plus every
           `examples/agents/*.md` into `.claude/agents/`, and every `examples/agents/*.md` into
           `assets/examples/agents/`.
           **ALWAYS build and run it inside `bash .claude/scripts/probe-sandbox.sh run -- …`.**
           **ALWAYS REPORT the path used and the final `probe-sandbox:` line.** The proof used to be
           `git status --porcelain` unchanged, which cannot see a commit that was made, pushed and
           reset away (`/audit` 2026-09-16 A-1).
        2. Extract the loop VERBATIM from the file and run it against that project.
        3. **ALWAYS REPORT — `activation chains: N verified, K broken, I info`.**
           **Expected: every gap-declaring specialist resolves and K = 0.** A resolved count below
           the number of gap phrases D6.1/D6.2/D6.2b extracted is RED.
           **THE KEY AND THE COUNTS ARE THE LOOP'S OWN, COPIED — NEVER PARAPHRASED.** This slot
           mandated a two-count `activation chain check:` the loop can never emit, contradicting
           D7.7 and the report slot added in the same commit (`/audit` 2026-09-10 U-29).
        4. **TRY TO BREAK IT — AND ALWAYS RE-RUN THE FULL REGRESSION SET BELOW, which is every
           phrasing a previous run found broken. A regression here is a finding, not a nit.**
           | # | Input | Expected |
           |---|-------|----------|
           | 1 | `declares a coverage gap for X` | BREAK — not a substring false-PASS (R-27) |
           | 2 | hyphenated `visual-regression gap` | VERIFY (R-28) |
           | 3 | slashed `data/integrity gap` | VERIFY |
           | 4 | TAB-indented fold, phrase straddling it | VERIFY (R-29) |
           | 5 | no-article `declares performance gap` | VERIFY (R-30) |
           | 6 | a SECOND, bogus gap on the same agent | BREAK on the second (R-31) |
           | 7 | sentence-initial `Declares` | VERIFY |
           | 8 | space-fold line break inside the phrase | VERIFY |
           | 9 | the gap phrase in BODY prose only, description clean | **no BREAK** (T-9) |
           | 10 | a NEGATED body sentence (`NEVER declares an X gap`) | **no BREAK** (T-9) |
           | 11 | digit in domain (`OAuth2 federation gap`) | seen — VERIFY or BREAK, never silent (T-15) |
           | 12 | dot in domain (`Node.js runtime gap`) | seen — never silent (T-15) |
           | 13 | the ONLY declarer of a gap is the validator (bold form) | VERIFY (T-8) |
           | 14 | every declaring component removed | `none installed`, **exit 0** (T-14) |
           **The four regression tests for the four bugs one batch had just fixed were never written
           to disk, so the next run could not detect a regression in any of them
           (`/audit` 2026-09-09 T-43).** Run them against the loop AS EXTRACTED FROM THE COMMAND
           FILE, never as drafted, and against BOTH twins.

  D7.7. **REPORT THE THREE COUNTS SEPARATELY AND SAY WHETHER THE TWINS AGREE** —
        `activation chains: N verified, K broken, I info` FOR EACH twin, plus
        `twins agree: yes/NO`. A single figure hid a divergence where both loops resolved the
        same count while their INFO strings differed (`/audit` 2026-09-04 R-20).
  D7.8. **VERIFY THE DERIVED SPECIALIST SET DOES NOT SKIP SILENTLY.** Plant a specialist that is
        NOT a shipped example and whose gap no declarer declares; **expected: a line naming it.**
        Zero output is RED — a derivation that skips the population most likely to be broken is
        worse than the typed list it replaced (`/audit` 2026-09-04 R-10).
REPORT FORMAT:


## Agent 3: Activation Chain

### PART 1 — Verification ledger (verification mode ONLY; write `Part 1: N/A — baseline mode` otherwise)
| ID | Verdict | Structural evidence (file:line) |
|----|---------|--------------------------------|

### [D6] Vocabulary Alignment
- Status: PASS / FAIL
- Gap declarations found — **one sub-bullet per DECLARING COMPONENT the D6.8 grep returned, not a
  fixed pair** (`/audit` 2026-09-02 M-13):
  - [component]: [list of gap names]
- Specialist matches:
  | Gap | Declared by | Specialist file | Phrase match | bootstrap install row | EPA install row |
  |-----|-------------|-----------------|--------------|-----------------------|-----------------|
  [one row per gap — the last two columns are D6.7 and are MANDATORY, never blank]
- Install-block diff (D6.7): [`diff` of the two install blocks — **table AND surrounding prose** —
  expected empty; paste any difference]
- **Fourth-surface check (D6.9) — MANDATORY, never blank:** `docs/agentic_engineering_framework.md`'s
  coverage-gap paragraph names [N] declarers; policy §1/§3 names [M]; match: [yes / NO — which is stale]
- `declarers extracted: N of M` — **MANDATORY, never blank** (D6.2b; M derived, never typed)
- Gap SOURCES found (D6.8): [every component that declares a gap] — policy §1/§3 lists: [set];
  match: [yes / NO — which twin is stale]
- Broken links (gap → no specialist): [list, or "none"]
- Orphaned specialists (specialist → no gap): [list, or "none"]

### [D7] Pushy Description Compliance
- Status: PASS / FAIL
- Agents checked: [count]
  | Agent | Core function | Triggers | Exclusions | Consequence | Output | Status |
  |-------|--------------|----------|------------|-------------|--------|--------|
  [one row per agent — COMPLIANT / PARTIAL / NON-COMPLIANT]
- **`activation chains: N verified, K broken, I info` — ONE LINE PER TWIN (D7.6, D7.7),
  MANDATORY, never blank** — the loop emits THREE counts, so a two-count slot cannot receive it:
  - bootstrap twin: [literal output]
  - EPA twin: [literal output]
  - `twins agree: yes / NO` — **counts AND info strings**, not counts alone (D7.7).
  Plus one row per rephrasing tested, with its literal output, and which the check silently misses.
  - probe (D7.6): [synthetic-project path] | [the final `probe-sandbox:` line]
- **Planted-specialist probe (D7.8) — MANDATORY, never blank:** [literal output]. **Zero output is RED.**
- **Invariant proof output (D7.5) — MANDATORY, never blank.**
  **ALWAYS REPORT THE FILE COUNT BESIDE IT:** `files: N | output: [literal]`. **`output: 0` alone proves NOTHING** — measured, the
  command emits exactly `0` both when it reads 10 clean agents and when it reads none, so the
  output cannot distinguish a healthy repo from a wrong working directory. **`files: 0` is RED
  regardless of the output; `files: N` matching `ls docs/modules/agents/*.md | wc -l` plus
  `output: 0` is GREEN.** An earlier form of this guard asserted the wrong-directory symptom was
  EMPTY output; it is not, so the guard fired on a state that cannot occur and was blind to the
  one it existed to catch (`/audit` 2026-09-04 Q-2).
- Anti-pattern instances: [list, or "none"]
```

---

### Agent 4: Orchestration & Commands (Dimensions D8, D10)

```
You are an orchestration auditor for the Agentic Engineering Framework.
Your job is purely mechanical: trace skill and agent name references from
orchestrating files and verify they resolve to existing folders/files on disk.
Do NOT fix anything.

FILES TO READ:
1. docs/modules/skills/session-end/SKILL.md
2. docs/modules/skills/validation-orchestrator/SKILL.md
3. docs/modules/skills/sprint-proposer/SKILL.md
4. docs/modules/skills/autonomous-loop/SKILL.md
5. docs/modules/skills/skill-gate/SKILL.md
6. docs/modules/skills/codebase-audit/SKILL.md and framework-audit/SKILL.md
7. docs/modules/skills/cross-cutting-analysis/SKILL.md
8. .claude/commands/prd_planning.md and .claude/commands/prd_change.md
9. .claude/commands/maintenance.md and .claude/commands/audit.md
10. List folders in docs/modules/skills/, and READ `.claude/skills/cross-cutting-analysis/SKILL.md`
    — the second half of D10.4's byte-identity comparison
11. List files in docs/modules/agents/, and READ docs/modules/agents/code_reviewer.md (D8.8)
12. .claude/rules/component-design.md AND docs/modules/rules/component_design.md (D10.5 §5/§6/§8/§9)
13. docs/modules/rules/session_rules.md (D10.5 → "Execution proof")
13b. docs/modules/skills/project-md-updater/SKILL.md — target of a §heading citation D8.7's own
    sanctioned example names; the check cannot run without it
14. CLAUDE.md (D10.5 trigger letters (a)-(d); D10.6 parity)
15. README.md — the THIRD trigger-list surface D10.6 compares; the check cannot run without it, and
    it is the surface that carried an abolished trigger for four commits (`/audit` 2026-09-20 AC-1)

**Every file a CHECK below names MUST appear in this list (`FILES TO READ` / `INPUTS` — the same obligation under either heading).** Reading it "because the check says so"
while the list omits it is how a working check ends up living in the invoking prompt instead of in
this file (`/audit` 2026-09-02 K-15, L-3).

CHECKS:

[D8] Skill/agent names in orchestrators resolve
  D8.1. Read session-end/SKILL.md — extract every reference to another skill by name or path
        (e.g., "project-md-updater", "pendencias-updater", "config-file-updater",
        "rules-agents-updater", "session-log-creator", "diff-pattern-extractor")
  D8.2. Read validation-orchestrator/SKILL.md — extract every skill or agent name referenced
  D8.3. Read sprint-proposer/SKILL.md AND autonomous-loop/SKILL.md — extract every skill or
        agent name referenced (the sprint→loop handoff is a cross-skill reference: a broken
        link there strands an approved segment mid-backlog)
  D8.4. For each referenced skill name: verify a folder with that name exists in
        docs/modules/skills/
        (Note: orchestrators use project paths like ".claude/skills/X" but the framework
         source is "docs/modules/skills/X" — map the name, not the full path)
  D8.5. For each referenced agent name: verify a file exists in docs/modules/agents/
        (Note: agent file names use underscores — map hyphenated references like
        "diff-pattern-extractor" to "diff_pattern_extractor.md")
  D8.6. Report any reference that does NOT resolve
  D8.7. **CROSS-SECTION CITATIONS — the class that fails most often.** For every citation of a
        §heading INSIDE another component (`X → "Some Heading"`, `§"Some Heading"`), verify the
        cited text resolves to a REAL markdown heading (`#`/`##`/`###`) in the target file.
        **The FINDING is a citation whose target is not a heading at all** — a bold paragraph
        lead-in is NOT a heading, and that is the recurring defect (H-19a, J-4, J-17, K-14).
        **SANCTIONED and NOT a finding:** citing the PREFIX of a `## Name — subtitle` heading;
        dropping a trailing parenthetical; or dropping a LEADING ORDINAL
        (`§"MODEL SWITCH entries"` → `### 4. MODEL SWITCH entries`). The three forms must stay
        co-extensive with the RED list below — they were not, which left the ordinal case saved
        only by omission (`/audit` 2026-09-02 M-30). `## Name — subtitle` is this repo's dominant heading
        shape and ~15 citation sites legitimately cite the name half; flagging them would fire the
        check on the healthy state, which is how the RELOCATE check had to be repaired (K-8).
        **RED is:** the target is not a heading; the prefix is ambiguous (matches two headings in
        the same file); or the cited text appears nowhere in the target.
        Report: | Citer | Cited heading | Target file | Real heading? | Exact / sanctioned-prefix / RED |
  D8.8. Read `skill-gate` and `codebase-audit`: `codebase-audit` cites a §heading inside
        `code_reviewer.md` by text — apply D8.7 to it.

[D10.0] **EXTRACT EVERY MECHANICAL SELF-CHECK FROM `maintenance.md` AND `audit.md` AND RUN IT.**
  These two files are EXECUTED every session and every check in them states an expected result.
  **A check whose stated expectation does not match its actual output is a FINDING in either
  direction** — one that cannot go red is decoration; one that fires on the healthy state is worse.
  Three checks shipped in a single batch that could not fail at all, while this mandate lived only
  in the invoking prompt (`/audit` 2026-09-04 Q-3, Q-2, Q-10, Q-39).
  **ALWAYS RUN EACH ONE THAT WRITES INSIDE `bash .claude/scripts/probe-sandbox.sh run --staged -- …`,
  NEVER in the live repo.** Several of them `git commit`, `git stash` or `git push`, and a run of this
  mandate from the live repo pushed two planted commits to the real remote (`/audit` 2026-09-16 A-1).
  **ALWAYS run the D16 gate's `staged`, `log` and `dir` checks IN PLACE** — in the sandbox they read
  a false 0 (the **Authorized operations:** bold lead-in above, not a heading).

[D10] Command → skill invocation paths
  D10.1. Read prd_planning.md — extract every reference to a skill
         (e.g., "cross-cutting-analysis", ".claude/skills/cross-cutting-analysis/SKILL.md")
  D10.2. Read prd_change.md — extract every reference to a skill
  D10.3. For each referenced skill: verify the folder exists in docs/modules/skills/
  D10.4. For skills that the framework uses at runtime (cross-cutting-analysis):
         verify it ALSO exists in .claude/skills/ **AND that the two copies are BYTE-IDENTICAL**
         (`diff -r` / `cmp` — expected: no output). "It exists in both places" is a weaker claim
         than the one past reports have asserted; run the comparison rather than inferring it.
  D10.5. **THE COMMAND FILES' OWN CITATIONS.** Read `.claude/commands/maintenance.md` and
         `.claude/commands/audit.md` and verify every section they cite in another file resolves
         to a real heading — component-design §5/§6/§8/§9, "New component creation",
         "Version bumps", "Audit intake", "Upstream intake", `/audit` Phase 0 AND Phase 3, CLAUDE.md's
         trigger letters (a)-(d), and `session_rules.md` → "Execution proof". Apply D8.7's
         exact-match rule. These two files are EXECUTED every maintenance and audit session; a
         dangling citation here misroutes the session itself.
  D10.6. **TRIGGER-LIST PARITY — THREE surfaces, never two.** `audit.md` Phase 0's trigger table,
         the `**When it runs**` paragraph under **Utilities** in `CLAUDE.md`, **and the `/audit`
         row of `README.md`'s "What each command does" table** MUST name the same set of
         events. (That CLAUDE.md paragraph is a bold lead-in, not a heading — cite it as such;
         `/audit` 2026-09-02 M-25.) A trigger present in one and absent from the
         other is a FINDING in whichever direction — an unowned trigger (`/audit` K-18) or an
         undocumented one.
         **THE README ROW IS NOT OPTIONAL and it is the one that was missed.** `b62ef33` rewrote
         trigger (d) across the two command surfaces and README kept the abolished condition for
         four commits, because this check named only two surfaces — an unmeasured copy of a list
         the other two are gated on (`/audit` 2026-09-20 AC-1). Mechanical, expected result stated:
         ```bash
         grep -ci 'outside the loop' README.md CLAUDE.md
         sed -n '/^| CLAUDE.md trigger | Mode |/,/^$/p' .claude/commands/audit.md | grep -ci 'outside the loop'
         ```
         **Expected: at least 1 on EACH of the three.** A `0` names the surface that did not move
         with trigger (d) — that is the whole finding, and it is the direction that actually broke.
         **ASSERT THE CURRENT CONDITION'S PRESENCE, NEVER A RETIRED PHRASE'S ABSENCE, AND NEVER
         GREP THIS FILE WHOLE.** Two forms of this check self-matched before this one: the first
         grepped the abolished tail with `audit.md` among its targets, and the second asserted
         presence with `audit.md` still among them — in BOTH the command line was itself a match, so
         the `audit.md` half could not go RED. The second shipped under prose CLAIMING the first was
         fixed, and only an independent verifier stripping every genuine mention exposed it
         (this batch's pre-commit verifier, 2026-09-20). **Scoping to the Phase 0 TABLE is what
         removes the self-match** — the command lives outside it.
         **ALWAYS RE-DERIVE the asserted phrase from `/maintenance` → "Cycle governance" rule 1 when
         that rule changes** — a parity check is only a control while it names the live condition.
  D10.7. Report any reference that does NOT resolve

REPORT FORMAT:


## Agent 4: Orchestration & Commands

### PART 1 — Verification ledger (verification mode ONLY; write `Part 1: N/A — baseline mode` otherwise)
| ID | Verdict | Structural evidence (file:line) |
|----|---------|--------------------------------|

### [D8] Orchestrator References
- Status: PASS / FAIL
- References found:
  | Source file | Referenced name | Expected path | Exists? |
  |-------------|----------------|---------------|---------|
  [one row per reference]
- Cross-section citations (D8.7/D8.8) — MANDATORY, never blank:
  | Citer | Cited heading | Target file | Real heading? | Exact / sanctioned-prefix / RED |
  |-------|---------------|-------------|---------------|--------------------------------|
  [one row per §heading citation — "a bold lead-in" in the "Real heading?" column is a FINDING]
- Unresolved: [list, or "none"]

### [D10] Command → Skill Paths
- Status: PASS / FAIL
- References found:
  | Command file | Referenced skill/section | Expected location | Exists? |
  |-------------|--------------------------|-------------------|---------|
  [one row per reference, INCLUDING the D10.5 citations inside maintenance.md and audit.md]
- **Self-checks executed verbatim (D10.0), each one that WRITES inside `probe-sandbox.sh run`, the read-only ones in place — MANDATORY, never blank;
  paste the final `probe-sandbox:` line of every run under the table:**
  | Check | file:line | Stated expectation | Actual output | Match? | Can go RED? | Can go GREEN? |
- Runtime dual copy (D10.4): `cross-cutting-analysis` present in both | byte-identical: [yes/NO]
- Trigger-list parity (D10.6) — **THREE surfaces, one cell each, never blank:**
  CLAUDE.md events [list] | audit.md Phase 0 rows [list] | README.md `/audit` row [list] —
  match: [yes / NO — NAME the surface that did not move, which is the direction that broke]
- Unresolved: [list, or "none"]
```

---

### Agent 5: Document Accuracy (Dimensions C, E, D12, D15)

```
You are a document accuracy auditor for the Agentic Engineering Framework.
Your job is purely mechanical: read documents, check claims against facts,
check instruction style, and verify examples follow conventions. Do NOT fix anything.

FILES TO READ:
1. README.md
2. docs/agentic_engineering_framework.md (large file — focus on: line 47 area for component
   counts, the Repository Components table, the Bootstrap Pipeline section, the Project Structure
   section, and any numeric claims)
3. docs/modules/README.md
4. docs/modules/skills/README.md
5. CLAUDE.md (for count claims)
6. .claude/rules/component-design.md (section 6 — imperative vs descriptive instruction rules)
7. examples/README.md (conventions for agents/skills/rules)
8. docs/modules/skills/commit/SKILL.md (version string)
9. 3 skill files: docs/modules/skills/session-end/SKILL.md,
   docs/modules/skills/sprint-proposer/SKILL.md,
   docs/modules/skills/validation-orchestrator/SKILL.md
10. 2 agent files: docs/modules/agents/code_reviewer.md,
    docs/modules/agents/validator.md
11. From `examples/`: **LIST ALL** files in `agents/`, `skills/`, `rules/` and COUNT them (D15.7),
    then READ a representative sample of 3 agents, 2 skills and 2 rules for the convention checks
    (D12.2). D12.6's truth-tests measure across the FULL set, never the sample.
12. **LISTINGS of `docs/modules/skills/` and `docs/modules/agents/`** — D15.5 and D15.6 compare the
    README's claims against the disk and cannot run without them

**Every file a CHECK below names MUST appear in this list (`FILES TO READ` / `INPUTS` — the same obligation under either heading).** Reading it "because the check says so"
while the list omits it is how a working check ends up living in the invoking prompt instead of in
this file (`/audit` 2026-09-02 K-15, L-3).

CHECKS:

[C] Imperative vs descriptive instruction style (sampling)
  C.1. From component-design.md §6: the three properties of a reliable behavioral instruction:
       (1) imperative verb in CAPS, (2) dedicated section, (3) explicit output format
  C.2. Read the 3 skill files listed above. Identify behavioral instructions
       (steps the AI must execute every time)
  C.3. Check: are behavioral instructions written in imperative style with CAPS verbs?
  C.4. Check: are any behavioral requirements buried inside descriptive/rationale paragraphs?
  C.5. Read the 2 agent files. Apply the same checks to checklist items and process steps.
  C.6. Report specific instances of the anti-pattern (requirement buried in description)

[E] Version string consistency
  E.1. Extract the canonical framework version from README.md (title or first heading)
  E.2. Search for version patterns (v2.X.X, framework-vX.X.X) in: README.md, CLAUDE.md,
       docs/agentic_engineering_framework.md, docs/modules/skills/README.md,
       docs/modules/skills/commit/SKILL.md, and any other files where versions appear
  E.3. List every occurrence with file, line, and the version string
  E.4. Report any version string that does NOT match the canonical version
  E.5. NEVER report a `created: framework-vX.Y.Z` field as a version mismatch. Those fields are
       LINEAGE — they record when a component was born, and the maintenance Version-bumps policy
       explicitly forbids rewriting them on a bump. Components legitimately carry versions older
       than the canonical one. Flag such a field ONLY if a bump REWROTE it (compare against the
       previous commit), which is the actual defect.

[D12] Examples follow conventions in examples/README.md
  D12.1. Read examples/README.md — extract required frontmatter fields and structural conventions
  D12.2. Sample 3 agent examples, 2 skill examples, 2 rule examples
  D12.3. For each: verify all required frontmatter fields are present
  D12.4. For agents with invocation: subagent: verify they have description with core function
  D12.5. For skills: verify they use the folder/SKILL.md format
  D12.6. Report any convention violations

[D15] Framework concept doc + READMEs factual accuracy
  D15.1. From docs/agentic_engineering_framework.md — extract ALL numeric claims:
         - Skill counts (look for "15 pre-built", "12 lifecycle", "15 skills", "3 tier-gated")
         - ALSO grep for the BANNED sense of "inline" — "N inline process skills", "inline (always
           copied)". `invocation: inline` is a real value; "inline" meaning "always copied" is the
           renamed term and any survivor is a FINDING.
         - Agent counts (look for "10 agent", "3 process agents")
         - Step counts (look for "15-step")
         - Example counts (look for "20", "9", "11" for agents/skills/rules)
  D15.2. From README.md — extract all numeric claims about components, AND check COVERAGE — an
         OMISSION is a FINDING, because a claim-only check cannot see one (README's maturity table
         ended at Level 4 for two months after Level 5 shipped; owner review, 2026-09-16):
         - every `### Level N` heading of the concepts doc's "Maturity Model" has a row in README's
           "Maturity Levels" table;
         - every command file in `.claude/commands/` appears in BOTH README command tables
           ("Available Commands" and "What each command does").
  D15.3. From docs/modules/README.md — extract any count claims
  D15.4. For each claim: compare against actual count on disk
  D15.5. List all skills folders in docs/modules/skills/ and count them
  D15.6. List all agent files in docs/modules/agents/ and count them
  D15.7. List all example files in examples/agents/, examples/skills/, examples/rules/ and count
  D15.8. Report every factual inaccuracy: file, line (approximate), claim, actual value

REPORT FORMAT:


## Agent 5: Document Accuracy

### PART 1 — Verification ledger (verification mode ONLY; write `Part 1: N/A — baseline mode` otherwise)
| ID | Verdict | Structural evidence (file:line) |
|----|---------|--------------------------------|

### [C] Instruction Style
- Status: PASS / FAIL
- Files sampled: [list]
- Anti-pattern instances: [count]
- Details:
  | File | Line area | Issue | Current text (excerpt) |
  |------|-----------|-------|----------------------|
  [one row per finding, or "none"]

### [E] Version Consistency
- Status: PASS / FAIL
- Canonical version: [from README.md]
- All occurrences:
  | File | Line | Version string | Matches? |
  |------|------|---------------|----------|
  [one row per occurrence]
- Mismatches: [count]

### [D12] Examples Convention Compliance
- Status: PASS / FAIL
- Files sampled: [list]
- Violations:
  | File | Missing field/issue | Convention reference |
  |------|-------------------|---------------------|
  [one row per violation, or "none"]

### [D15] Factual Accuracy
- Status: PASS / FAIL
- Claims checked:
  | File | Claim | Actual | Accurate? |
  |------|-------|--------|-----------|
  [one row per claim]
- Inaccuracies: [count]
```

---

### Agent 6: Process Coverage — meta (Dimension D17)

> Unlike the other sixteen (A, C, E and D4–D16 — there is no D1, D2 or D3), this dimension hunts ABSENCES, not mismatches. A flow the repo executes in
> practice with no written instruction contradicts nothing on disk — a claim-vs-fact check
> is structurally blind to it (twice in this framework's history such gaps were caught only
> by the owner asking the meta-question). Evidence gathering here is mechanical (git history,
> greps); the verdict requires judgment. Findings are GAPS to report, never fixes to apply.

```
You are a process-coverage (meta) auditor for the Agentic Engineering Framework.
You hunt for flows this repository EXECUTES or PROMISES but does not DOCUMENT — the gap
class that claim-vs-fact checks cannot catch, because an absence breaks no reference and
mismatches no count. Do NOT fix anything. Read-only audit.

INPUTS:
1. `git log --format="%h|%ad|%s" --date=short -40` — the operations actually performed
2. .claude/commands/*.md (all commands — what IS documented)
3. CLAUDE.md ("Session Modes", "What You Do Here", "Rules")
4. README.md (workflow sections)
5. `docs/` AS A WHOLE for D17.3's aspirational-mechanism grep (`docs/agentic_engineering_framework.md`
   included), and within it the `docs/modules/` templates that reference MOTHER-REPO behaviors — grep for
   "mother framework", "framework repo", "/maintenance", "upstream", "lineage"
6. assets/docs/ — the lineage records (what past absorption sessions did) AND every
   `assets/docs/audit-*.md` report, including `assets/docs/audit-YYYY-MM-DD.md` for this run:
   D17.1 classifies the flows they record and D17.5 re-measures the persisted receipts inside them

**Every file a CHECK below names MUST appear in this list (`FILES TO READ` / `INPUTS` — the same obligation under either heading).** Reading it "because the check says so"
while the list omits it is how a working check ends up living in the invoking prompt instead of in
this file (`/audit` 2026-09-02 K-15, L-3).

CHECKS:

[D17] Process coverage — six bounded questions
  D17.1 UNDOCUMENTED EXECUTED FLOWS: classify the recent commits by operation type
        (maintenance correction, upstream absorption, audit-fix application, template
        evolution, release/versioning, ...). For each operation type observed in history:
        which command/doc section instructs it? An operation performed 2+ times with no
        written home is a finding.
  D17.2 REFERENCED-BUT-UNOWNED CONVENTIONS: for each mother-repo behavior a TEMPLATE
        promises (the grep set above — e.g. "the owner runs a /maintenance session in the
        mother framework repo", "recorded in the mother repo's lineage"), verify the
        mother-side instruction exists (a command section, a CLAUDE.md process). A template
        promising a behavior the mother repo nowhere documents is a finding.
  D17.3 ASPIRATIONAL MECHANISMS: grep CLAUDE.md/README.md/docs/ for claims that something
        happens "periodically", "on a cadence", "always", "every session" AT THE
        FRAMEWORK-REPO level — verify each has an owner (a command that runs it, a
        documented trigger). Claimed-but-ownerless = finding. (Project-level cadences are
        owned by project skills — out of scope here.)
  D17.4 SELF-CHECK PROVABILITY — BOTH directions. For every mechanical self-check the commands
        mandate (a grep with a stated expected result), assess whether it CAN go red AND whether
        it CAN go green. A check whose token no longer exists in the repo, or that is trivially
        satisfied, is decoration. A check that fires on the NORMAL, healthy state is equally
        broken — that inversion shipped twice (K-8's RELOCATE check, L-7's D8.7). Report both
        directions per check, and verify no NEW unprovable check was introduced by the batch
        under verification.
        **DIVISION OF LABOUR WITH AGENT 4 — ALWAYS STATE IT, NEVER RE-RUN D10.** D10 (Agent 4)
        asks whether a self-check's stated expectation MATCHES what its command returns today;
        D17.4 asks whether the check has a reachable RED and a reachable GREEN **at all**. A check
        can pass D10 and fail D17.4 (correct expectation, unreachable red) and vice versa.
        **ALWAYS CITE D10's verdict per check rather than recomputing it**, and report only the
        provability axis. T-46's first half was never written and the two dimensions have
        overlapped silently since (`/audit` 2026-09-10 U-36).
  D17.5 SELF-REPORTED CONTROLS — who verifies them? For every control the post-change checklist
        mandates, state WHO checks it and WHERE its output is persisted. A control whose verifier
        is its own author, or whose output exists only in a transcript, is not a gate. Name each
        one; do not soften.
  D17.6 CONVERGENCE — the honest question. Given the defect rate of the last runs, assess
        MECHANICALLY whether the controls the batch under verification added address the CAUSES
        of the defects that batch was fixing, or add process without adding a gate. Cite evidence.
        **"The controls are adequate" is a valid conclusion when the evidence supports it — NEVER
        manufacture a finding to seem useful.**
        **ALWAYS ANSWER, WITH THE MEASUREMENT: is this loop consuming more effort than it returns?**
        Split every batch since the series began by where its lines LAND, and report the table:
        ```bash
        for r in <each batch range>; do
          echo -n "$r shipped: "; git diff --shortstat $r -- docs/modules examples | tr -d '\n'
          echo -n " | apparatus: "; git diff --shortstat $r -- .claude assets/docs CLAUDE.md
        done
        ```
        **Shipped surface = `docs/modules/` + `examples/` — what bootstrapped projects receive.
        Apparatus = everything else.** A defect rate is a property of how much normative text the
        PREVIOUS run added; the shipped-surface delta is the only number that measures whether the
        loop is producing anything. Measured across Runs 5-9 it fell 62 → 38 → 23 → 12 → **4** lines
        while the apparatus took 7,961, a 94/6 split (`/audit` 2026-09-09, meta-observation).
        **If shipped delta trends to zero while the rate does not fall, SAY SO and say the loop
        should be re-pointed at the shipped surface** — that is a legitimate finding, and D17.6 is
        the only dimension positioned to make it. This mandate lived only in a dispatch prompt for
        one run and produced that run's most load-bearing measurement (`/audit` 2026-09-09 T-46).

For each finding report: the flow/claim, the EVIDENCE (commit hashes / file:line), and
where the missing instruction would naturally live. "No gaps" is a valid outcome — do not
manufacture findings to seem useful.

REPORT FORMAT:


## Agent 6: Process Coverage (meta)

### PART 1 — Verification ledger (verification mode ONLY; write `Part 1: N/A — baseline mode` otherwise)
| ID | Verdict | Structural evidence (file:line) |
|----|---------|--------------------------------|

### [D17] Process Coverage
- Status: PASS / FINDINGS
- Commits classified: [N commits → operation types with counts]
- Undocumented executed flows: [flow — evidence — suggested home, or "none"]
- Referenced-but-unowned conventions: [template promise — file:line — missing mother-side home, or "none"]
- Aspirational mechanisms: [claim — file:line — missing owner, or "none"]
- Unprovable self-checks (D17.4): | Check | Can go RED? | Can go GREEN? | Verdict |
- Self-reported controls (D17.5): | Control | Verified by whom | Output persisted where | Gate? |
- Convergence assessment (D17.6): [mechanical judgement with evidence]
```

---

## Phase 2 — Merge Reports

After ALL 6 agents return, consolidate their reports into a single audit report.

### Consolidated Report Format

```markdown
# Framework Audit Report

**Date:** [today's date]
**Framework version:** [from README.md]
**Run mode:** `baseline` | `verification (over sHASH)` — ALWAYS state it (Phase 0)
**Post-push D16:** log sOLD..sNEW [(endpoint derived by hand — why)] → N commits scanned, H hits — origin/main at sNEW | RED — [fetch failed | no origin/main ref | gate could not check: reason] — origin/main unverified   ← Phase 0, ALWAYS
**Dimensions checked:** 17 [+ a Part 1 fix-verification pass, in verification mode]
**Agents dispatched:** 6

**carried: [N] open + [M] escalated from [previous report file] — [the IDs]** | `carried: none — first audit`
— ALWAYS present. **Plus one OBSERVATION line per `accepted-risk` item**, citing its record and
never re-opening it (Phase 3's carry-forward report item; `/audit` 2026-09-02 M-26).

## Part 1 — Verification ledger for [sHASH]   ← verification mode ONLY; omit the whole section in baseline

| ID | Verdict | Evidence (file:line — STRUCTURAL, not "the text is present") |
|----|---------|------|
| [ID] | CONFIRMED-FIXED / PARTIALLY-FIXED / FIXED-BUT-CLASS-NOT-SWEPT / NOT-FIXED / INTRODUCED-A-DEFECT | [what the structure AROUND the fix shows] |

**Score, counted over the FINDINGS (state the denominator — never the ledger's row total):
[N] of [M] clean, [K] not clean.** Of the not-clean: [N] partially-fixed, [N] class-not-swept,
[N] not-fixed, [N] introduced-a-defect. **ALL FOUR not-clean categories, ALWAYS — the
enumeration is COPIED FROM the verdict list above, never re-derived.** The fifth verdict
(`NOT-FIXED`) was added to the agent mandate and swept to neither the Part 1 row nor either
score line, so a verdict with no field would simply not be reported — Gate 4's DESCENDING
direction (`/audit` 2026-09-10 U-12).

## Summary

| # | Dimension | Category | Agent | Status | Finding |
|---|-----------|----------|-------|--------|---------|
| A | Dual placement | Structural | 1 | PASS/FAIL | [1-line summary] |
| C | Instruction style | Quality | 5 | PASS/FAIL | [1-line summary] |
| E | Version consistency | Currency | 5 | PASS/FAIL | [1-line summary] |
| D4 | Skills README vs disk | Currency | 1 | PASS/FAIL | [1-line summary] |
| D5 | Bootstrap file refs | References | 2 | PASS/FAIL | [1-line summary] |
| D6 | Gap vocabulary | References | 3 | PASS/FAIL | [1-line summary] |
| D7 | Pushy Description | Quality | 3 | PASS/FAIL | [1-line summary] |
| D8 | Orchestrator refs | Process | 4 | PASS/FAIL | [1-line summary] |
| D9 | CLAUDE.md diagram | Currency | 1 | PASS/FAIL | [1-line summary] |
| D10 | Command → skill paths | References | 4 | PASS/FAIL | [1-line summary] |
| D11 | Bootstrap sequencing | Process | 2 | PASS/FAIL | [1-line summary] |
| D12 | Examples conventions | Currency | 5 | PASS/FAIL | [1-line summary] |
| D13 | PRD ↔ bootstrap compat | Process | 2 | PASS/FAIL | [1-line summary] |
| D14 | Bootstrap output | Process | 2 | PASS/FAIL | [1-line summary] |
| D15 | Doc factual accuracy | Currency | 5 | PASS/FAIL | [1-line summary] |
| D16 | Project-info isolation | Privacy | 1 | PASS/FAIL | [1-line summary] |
| D17 | Process coverage (meta) | Meta | 6 | PASS/FINDINGS | [1-line summary] |
```

### Findings ledger — ALWAYS present, one row per finding (Phase 3 items 2-4)

| ID | Severity | Location | Finding | Status |
|----|----------|----------|---------|--------|
| [stable ID] | HIGH/MEDIUM/LOW | file:line | [one sentence] | one of the five values in Phase 3 item 2 |

**Carried forward from [previous report]:** one row per still-`open` and `escalated` finding,
keeping its ORIGINAL ID, re-verified against the current disk (Phase 3 item 3).

### Detailed Findings

Paste each agent's full report in order (Agent 1 through Agent 6).

### Recommended Fixes

Group FAIL items by priority:
0. **LOW BACKLOG — never a session on its own.** List LOW findings here by file, and ALWAYS say
   they are applied only when a later session already edits that file (`/maintenance` → "Cycle
   governance"). A report whose findings are ALL LOW on apparatus surfaces recommends no session.
1. **Quick fixes** — version mismatches, count corrections (single-line edits)
2. **Structural fixes** — missing references, broken activation chains
3. **Quality improvements** — instruction style, description compliance
4. **ESCALATED — owner decision required** — ALWAYS its own group, never folded into the three
   above. A pushed privacy hit, a history rewrite, or any fix this repo cannot make alone belongs
   here with the decision stated plainly. Omitting the lane is how an escalated item ends up
   looking like a deferred quick fix (`/audit` 2026-09-02 M-26).
5. **ACCEPTED-RISK — no action** — one line per item, citing its record. Present so a reader can
   see the item was decided, not forgotten.

### Errata and superseded status — how a persisted report is CORRECTED

A report is a record, so it is amended, never silently rewritten. **ALWAYS use these two forms and
no others** (`/audit` 2026-09-03 N-45, N-47):
- **`> **Errata N (added by the [which] application, finding [ID]).**`** — a blockquote inserted
  directly ABOVE the text it corrects, numbered in the order the errata were added, naming the RUN
  that authored it and the finding that required it. **NEVER label an erratum with the run that
  has not happened yet** — two were mislabelled that way in one batch.
  **ALWAYS GREP FOR THE NUMBER BEFORE WRITING IT** — `grep -c '^> [*][*]Errata N '`,
  **expected 0** — and take the next free integer ABOVE THE HIGHEST PRESENT, never the one
  after whichever erratum you happen to be
  reading. The series is numbered per FILE and the blocks do NOT appear in numeric order inside
  it, so reading gives the wrong answer. This rule shipped without the check and the very next
  batch to use it wrote a second `Errata 2` AND a second `Errata 3` (`/audit` 2026-09-03 N-52).
  Same class as the collision check in "ID allocation" below, which this section should have
  inherited on the day both were written.
- **`*(superseded)* [the old text]`** — for a status line replaced by a later disposition. The old
  line stays, marked, so a reader can see the sequence.

### ID allocation — ALWAYS check for a collision before writing a finding

**Each run allocates ONE letter series** (`F`, `G`, `H`, `J`, `K`, `L`, `M`, `N` …), skipping
letters that read as digits, and `S`, which collides with this repo's `s<hash>` notation.
**WHEN EVERY OTHER LETTER IS USED, ALWAYS TAKE `C` AND THEN `D`, IN THAT ORDER** — a finding ID
carries a hyphen (`C-1`) and a dimension name never does (`C`, `D16`), so they stay distinct.
**The single letters are EXHAUSTED as of 2026-09-20 (`D` was the last).** The owner's decision that
day: **two-letter series — `AA`, then `AB`, `AC` … — and every ledger grep in both commands matches
`[A-Z]{1,2}-[0-9]+`.** Never widen one grep alone: a one-letter class reads a two-letter ID as
nothing, and the finding disappears from the carry-forward instead of failing loudly (`/audit`
2026-09-20 AA-5's class; the exhaustion itself is `/audit` 2026-09-16 A-38).
**TWO DISTINCT CHECKS, both mandatory — they differ in pattern, corpus and expected result:**
- **VISIBILITY**, over THIS report, after writing the ledger: `grep -c '^| <SERIES>-[0-9]' <this report>`
  → **equal to the number of rows you wrote.** A lower number means a grep somewhere still reads the
  one-letter class and your findings are invisible to it.
- **COLLISION**, over EVERY report, before writing: the check in "ID allocation" below.

**EXTENDING A CLOSED SERIES — who may, and how.** A finding surfaced OUTSIDE the run that owns a
letter (a follow-up verification, or a maintenance session reconciling `origin/main`) is filed by
**appending to that run's ledger with the next free number in its series**, never by inventing a
suffix and never by re-using an ID. This was executed twice with no written home at all
(`/audit` 2026-09-09 T-31); a `N-28b` is off-scheme, and a reused ID costs a re-file and an
erratum, both of which happened (`/audit` 2026-09-03 N-46, and the `M-16` collision it names).
**ALWAYS RUN THE COLLISION CHECK FIRST** — `grep -h "^| <ID> |" assets/docs/audit-*.md | wc -l` →
**expected 0**, over EVERY report, never one file: a two-letter series is free only when no report carries
it. **`grep -hc` over a glob prints one count PER FILE and cannot be compared to 0** (this batch's
pre-commit verifier, 2026-09-20).
**ALWAYS NUMBER SEQUENTIALLY, WITH NO SUFFIXES.**
**ALWAYS MARK THE ROW `[filed by <what> on <date>]`** so a later reader can tell it from the run's
own findings.

### Meta-observation — ALWAYS present (`## Meta-observation`)

One or two paragraphs naming the RECURRING CLASS this run saw — not a summary of the findings.
Executed in every run since 2026-09-01 and owned by nobody until now; it is the section that
produced the per-fix receipt. **ALWAYS state the class, its evidence, and — where the evidence
supports it — where the NEXT batch's defects will come from, so the prediction is checkable next
run.** NEVER manufacture a class to fill the section: "no new class this run" is a valid finding.

**ALWAYS EVALUATE THE PRIOR RUN'S PREDICTION FIRST, CLAUSE BY CLAUSE, BEFORE STATING A NEW ONE.**
This section MANDATES a prediction "so it is checkable next run" and NOTHING instructed the next
run to check it: `grep -n "prediction"` returned exactly ONE hit, the line creating the obligation.
It was evaluated three times anyway, from dispatch prompts rather than from disk — component-design
§9, the invoker-owns-the-mandate class, inside the section that creates the mandate
(`/audit` 2026-09-10 U-16). Mechanical, expected result stated:
```bash
# SCOPE TO THE PREVIOUS RUN, NEVER THE WHOLE FILE: keep only the text after the LAST `# Run N`
# heading that sits outside a code fence (the whole file when it has none).
awk '/^```/{f=!f} !f&&/^# Run [0-9]+/{b=""} {b=b $0 "\n"} END{printf "%s", b}' <the PREVIOUS report> \
  | sed -n '/^## Meta-observation/,/^## /p' | grep -c 'Prediction'
```
**Expected: at least one hit, and one `held / failed / void` verdict per clause of it in THIS
report.** A prior run with no prediction is a legitimate `n/a` — say so.
**NEVER grep the whole file.** A report carrying several runs holds several predictions, so the
whole-file form still read 1 after the previous run's own prediction was deleted — a check with no
RED state (`/audit` 2026-09-15 B-16).
**ALWAYS REPORT — `prediction: N clauses evaluated — [held/failed/void each]` or
`prediction: n/a — the previous run stated none`. NEVER emit nothing.**

**Meta-observation required elements (the SLOT — ALWAYS all three, in this order):**
- `prediction: N clauses evaluated — [held | failed | void] each` · `prediction: n/a — the
  previous run stated none` (BOTH verdicts the evaluation can produce, and ONLY those two —
  COPIED FROM the mandate above, never re-derived.)
- the RECURRING CLASS this run saw, with its evidence.
- the NEW prediction, stated so it can fail.

End with: **Suggestion:** Run `/maintenance` to apply fixes, using this report as the correction plan.

### Closing status lines — ALWAYS ALL THREE, verbatim keys, enumerated values

**Count them in this list, never from this sentence.** The heading read "ALWAYS both" over three
bullets for two runs, because `defect series:` was added and the heading never swept — item 4's
ADJACENT direction, in the file that defines it (`/audit` 2026-09-09 T-40).

- **`Report status:`** — `COMPLETE` (all agents returned, all dimensions evaluated) or
  `INCOMPLETE — [which agents or dimensions did not return]` (an agent that stopped on a
  `probe-sandbox: RED` did not return — name it and the parts that line names, or its reason when it failed closed).
- **`defect series:`** — `row N appended` (verification mode) or `N/A — baseline mode`.
  **ONE surface, never three.** The series lives in exactly one table — "The defect series" above
  Phase 1 — and item 6 says APPEND ONE ROW AND TOUCH NOTHING ELSE. An earlier form of this line
  mandated `updated in N of 3 surfaces` and named `CLAUDE.md` and Phase 0 as surfaces to keep
  current, contradicting item 6 eleven hundred lines below it and re-creating the copies R-7/R-8
  deleted (`/audit` 2026-09-09 T-42).
- **`Application status:`** — exactly one of `PENDING` / `PARTIAL — N of M applied in sHASH` /
  `APPLIED — M of M in sHASH` / `SUPERSEDED by [later run]`.
  **A batch split across commits uses the SAME value with EVERY hash named** —
  `APPLIED — M of M (X in sAAA, Y in sBBB, Z in sCCC)` — and **the parenthesised counts MUST sum
  to M**. This is not a new value; it is the multi-hash form of the same two. It was mandated in
  `maintenance.md` while this enumeration still forbade it, and the first status line written under
  the new rule named 4 of 7 hashes and 20 of 54 dispositions without failing anything
  (`/audit` 2026-09-03 P-2, P-33).
  **NEVER invent a value outside this set** — three runs produced three different vocabularies
  before this enumeration existed (`/audit` 2026-09-02 L-13).

---

## Phase 3 — Persist the report (ALWAYS, before ending the session)

Findings that are not applied in the same session survive only in a transcript, and deferral is
routine, not exceptional. The application half of that flow is documented (`/maintenance`); this
step is the carry-over half.

1. **ALWAYS WRITE the consolidated report to `assets/docs/audit-YYYY-MM-DD.md`** — the full
   summary matrix plus every finding with its evidence and file:line. This is the only file the
   audit writes.
   **If a report for today already exists, APPEND a `# Run N` section to it — NEVER overwrite it
   and never invent a suffixed filename.** Two runs in one day is the normal shape of
   audit → maintenance → re-audit, and the earlier run's ledger is what the later one carries
   forward.
2. **ALWAYS give every finding a STABLE ID (`F-1`, `F-2`, …) and a status column** — exactly one
   of: `open` / `applied sHASH` / `rejected — [reason]` / **`escalated — owner decision pending`** /
   **`accepted-risk — see [record]`**. The last two exist because a pushed privacy hit (D16.3c)
   cannot be fixed by this repo alone: without them an escalated item is neither `open` nor
   closed, and item 3 below cannot see it (`/audit` 2026-09-02 L-8). The ID is what a later maintenance session
   cites; a finding without one cannot be tracked across sessions.
3. **ALWAYS carry FORWARD every finding that is NOT closed — `open` AND `escalated`** — from the previous audit report (the most
   recent `assets/docs/audit-*.md`) into the new one, re-verifying each against the current disk:
   still true → carry with its original ID; fixed since → mark `applied`. An audit that silently
   drops the last one's open items is how "deferred" becomes "forgotten".
   **ALWAYS CARRY IT AS A LEDGER ROW (`| ID | Severity | Location | Finding | Status |`), NEVER AS A
   NAME IN PROSE.** A prose list is invisible to every grep that decides survival, so a finding
   named only there is dropped by the NEXT run without anyone omitting anything. Measured: one run
   declared `carried: 81 open` in prose and wrote no row for any of them; the next run read the rows
   and declared `carried: 8`, and **41 findings still open in the two preceding reports got no
   `^\| ID \|` row in the report that was supposed to carry them forward** (`/audit` 2026-09-21
   AD-1). They still have rows in the reports that FILED them — the break is in the chain, not in
   the originals, and saying "no rows anywhere" overstates it.
   **AND ALWAYS READ THE PREVIOUS REPORT'S ROWS, NEVER ITS `carried:` SENTENCE** — the sentence is a
   claim about the rows, and when the two disagree the rows are what the next run will inherit. If
   they disagree, the chain is already broken: walk back through `assets/docs/audit-*.md` until
   every still-open ID has a row, RECOVER the missing ones into this run's ledger, and FILE the
   break as a finding of this run.
   **A LOW finding whose file the audited batch did not touch is re-verified MECHANICALLY, never by
   re-reading:** `git diff --name-only <batch range> -- <its file>` empty → still true by construction.
   Say which LOW findings were carried this way (owner decision, 2026-09-16 — `/maintenance` → "Cycle
   governance").
4. **ALWAYS report in one line how many findings were carried forward** — `carried: N open + M
   escalated from [previous file] — [the IDs]`, or `carried: none — first audit`. Never nothing.
   **ALWAYS NAME THE CARRIED IDs IN THAT LINE, NEVER ONLY A COUNT.** A count cannot be checked
   against anything; a list can be checked against the rows, one ID at a time. This is what makes
   item 3's row requirement verifiable by the NEXT run rather than by trust.
   **NO MECHANICAL CHECK IS WRITTEN HERE, AND THAT IS A STATED GAP, NOT AN OVERSIGHT.** A
   row-count reconciliation was drafted for this item and REMOVED before it shipped, for two
   independent reasons: the apparatus moratorium (`/maintenance` → "Cycle governance" rule 3)
   forbids adding a new prose-embedded control to this file, and item 4 carried no command before;
   and the draft counted rows over the WHOLE FILE, which on AD-1's own data reads 128 against a
   `carried: 81` and would have passed GREEN on the very incident it was written for — the
   whole-file blindness this file already documents ABOVE, at the prediction grep
   (`/audit` 2026-09-15 B-16). **A scoped form would have to reuse the fence-aware `sec()`
   extractor `/maintenance` defines; until a session is rewriting this item for another reason,
   the rule above stands as prose and AD-1's mechanism is HALF-FIXED — rows are required, and
   nothing counts them** (this batch's pre-commit verifier, 2026-09-21).
   **An `accepted-risk` item is NOT carried forward as a finding.** Report it once per run as an
   OBSERVATION citing its record, and NEVER re-open it — the record states what WOULD re-open it
   (a new working-tree occurrence, or an identifier of a different class). A finding with a
   written owner decision is closed; a finding without one is immortal.
5. **In `verification` mode, ALWAYS persist the Part 1 ledger too** — one row per re-verified
   `applied` finding with its verdict and structural evidence, plus the score line. A finding
   whose verdict is anything other than CONFIRMED-FIXED gets a NEW ID and status `open`; the
   original keeps its `applied sHASH` status and gains a pointer to the new ID. **NEVER silently
   reopen an applied finding under its old ID** — the ledger is how a later session tells "this
   was never fixed" from "this was fixed and the fix was wrong".
6. **In `verification` mode, APPEND ONE ROW to the defect-series table above Phase 1 — and
   TOUCH NOTHING ELSE.** Every other surface CITES that table; **if one repeats a figure, DELETE
   the copy rather than updating it.** Four surfaces carried copies, three disagreed with each
   other, and one asserted a count its own list contradicted (`/audit` 2026-09-04 R-7, R-8).
   **RECOMPUTE this run's `N of M` FROM THE LEDGER, never from a prior summary**, then append. **A run
   RESUMING an INCOMPLETE one recomputes over BOTH ledgers and appends the BATCH total, saying which row it
   completes** (Phase 0 → "Resuming an `INCOMPLETE` run"): its own ledger alone is a fraction of the batch,
   and the earlier row is never amended.
   **NEVER claim a single grep derives the whole series** — the reports predate their own
   conventions and the historical set matches no one pattern: measured, a `grep -l` returns 4
   (it counts FILES), an occurrence grep returns 12 (three runs carry both a heading and a
   `Run mode:` line), and a `## Part 1` anchor returns 10 and misses the earliest run entirely.
   The previous form of this item claimed a command that returned 4 beside a figure of 8
   (`/audit` 2026-09-04 R-16). **From Run 9 onward every report carries exactly one
   `**Run mode:** \`verification (over …)\`` line**, so the forward-going count IS derivable:
   ```bash
   grep -c '^\*\*Run mode:\*\* `verification' assets/docs/audit-*.md   # Run 9 onward, per file
   ```
   **Expected: the number of declared verification runs ON DISK, PLUS the rows the table's own
   "How the mode is declared there" column marks as pre-convention, EQUALS the table's row count
   AFTER your append.** A command with no stated expected result can be evaluated neither red nor
   green — T-40's second half never landed (`/audit` 2026-09-10 U-35). **COUNT LINES, NEVER FILES:**
   three report FILES carry several runs each, so a `grep -l` form reads 5 against 11 rows — a
   check firing on the healthy state, the K-8/L-7 inversion. Calibrated and negation-proved
   2026-09-11:
   ```bash
   T=$(sed -n '/^### The defect series/,/^\*\*No trend/p' .claude/commands/audit.md)
   V=$(grep -h '^\*\*Run mode:\*\* `verification' assets/docs/audit-*.md | wc -l)
   ROWS=$(printf '%s
' "$T" | grep -c '^| [0-9]* | `audit-')
   PRE=$(printf '%s
' "$T" | grep '^| [0-9]* | `audit-' | grep -vc 'Run mode:\*\* verification')
   [ "$((V+PRE))" = "$ROWS" ] && echo "GREEN $V+$PRE=$ROWS" || echo "RED $V+$PRE vs $ROWS"
   ```
   **The command computes BOTH sides, so it cannot go stale — but NEVER quote a figure beside it.**
An earlier form read `GREEN 9+2=11 today`; run at the tip it returns `GREEN 18+2=20`, and a reader
checking the quoted figure instead of the command would have called a healthy table broken
(`/audit` 2026-09-20 AC-15). **Deleting any row returns RED.**
   **ALWAYS REPORT `defect series:` with the row you appended, and its `$` line.**

7. **ALWAYS COMMIT the report in THIS session — LAST, after every content item above** — writing it to disk is not persisting it.
   ```bash
   git add assets/docs/audit-YYYY-MM-DD.md && git commit -m "docs(audit): persist [run] — [N] findings open"
   ```
   Mechanical self-check (expected result stated), over **THIS run's report path, not the whole
   directory**:
   ```bash
   p=assets/docs/audit-YYYY-MM-DD.md; h=$(git log -1 --format=%h -- "$p")
   if [ -n "$h" ] && [ "$h" = "$(git log -1 --format=%h)" ] && git log -1 --format=%s | grep -q '^docs(audit): persist' && [ -z "$(git status --porcelain -- "$p")" ]; then echo "report committed: s$h"; else echo "NOT committed — last report commit ${h:-none}, HEAD $(git log -1 --format=%h)"; fi
   ```
   **Expected: `report committed: sHASH`.** The report commit is the LAST one, so its hash MUST be
   HEAD and its subject the `persist` form above. The earlier form, `git status --porcelain` alone,
   read EMPTY both for a committed report and for one never written (`/audit` 2026-09-16 A-31); without
   the subject test, a same-day re-run whose last commit was a WRITE-BACK to this file read GREEN
   before its own report existed (this batch's pre-commit verifier, 2026-09-19). (Scoping matters: `assets/docs/` also holds
   lineage docs an unrelated session may have left dirty, which would turn this red for the wrong
   reason.)
   **ALWAYS REPORT — `report committed: sHASH` or `NOT committed — [reason]`. NEVER emit nothing.**
   This is the ONE git operation this session performs, and it does not violate the read-only
   rule: the report is this session's OUTPUT, never an audited surface. Evidence it is needed —
   all three reports before this instruction existed entered git via a LATER session's commit, and
   one of them crossed a session boundary as an untracked file (`/audit` 2026-09-02 K-20).
