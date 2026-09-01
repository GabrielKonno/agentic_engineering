# Framework Maintenance Session

This is a framework maintenance session, not a project bootstrap.

**Authorized operations:**
- Edit files in `docs/` (framework documentation)
- Edit files in `examples/` (reference templates)
- Edit `CLAUDE.md` (framework contract)
- Edit `README.md`
- Edit this repo's OWN runtime under `.claude/` — `commands/`, `rules/`, `skills/`. The framework
  evolves its own session modes here, and three items below MANDATE it (item 4's class sweep,
  item 5's back-sweep of this repo's `.claude/`, item 6's liveness guard over `.claude/skills/`).
- Write lineage and audit records under `assets/docs/` — Upstream intake step 4 MANDATES the
  lineage doc, and `/audit` Phase 3 writes the dated report a later session applies.

> These last two were executed by nearly every maintenance session long before they were listed.
> The list is the authorization of record: an operation this file mandates elsewhere MUST appear
> here, or the command contradicts itself (found by `/audit` D17, 2026-08-31).

**Rules still in effect:**
- Never modify files inside `projects/` (those belong to project repos)
- All changes must be committed with descriptive messages
- Verify cross-references after modifying any document

**Workflow:** Run Step 0 (upstream discovery sweep) below, read the maintenance prompt/correction plan provided by the user, apply all changes in order, run the post-change checklist, commit.

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

2. **Instruction-style check on NEW normative text.** Every new or edited BEHAVIORAL
   instruction (a step the AI must execute every time — in commands, skills, agents, rules)
   MUST satisfy component-design §6 before commit: imperative verb in CAPS
   (ALWAYS/MUST/NEVER), its own dedicated line/bullet (never buried mid-paragraph), explicit
   output/format where applicable. Mechanical assist: re-read every bullet you WROTE this
   session and flag any whose verb is descriptive present tense ("keeps", "verifies",
   "declares") — that is the exact form the audit's dimension C fails.

3. **Reference & isolation verification** (as already required by Upstream intake step 6,
   but for EVERY maintenance change, not only upstreams): cross-references resolve (grep
   each named section/file you cited), template fence extraction still works
   (`sed -n '/^````markdown$/,/^````$/p'` — and the `js` variant — over every edited
   template), and the D16 isolation grep runs over every touched file (no project names,
   no source-project session numbers, no single-project vocabulary).

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
   **ALWAYS REPORT the result — `class sweep: N directions checked, M extra instances found and
   fixed` or `class sweep: N/A — no point fixes this session`. NEVER emit nothing.**

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
   **ALWAYS REPORT the result — `back-sweep: [rule] applied to N artifacts` or
   `back-sweep: N/A — no process rule promoted`. NEVER emit nothing.** Per component-design §6, a
   self-check must be executed AND REPORTED; a silent back-sweep is indistinguishable from a
   skipped one.

6. **Component liveness — re-check the frontmatter of every component edited this session.**
   ALWAYS run the guard over this repo's OWN `.claude/skills/` and `.claude/agents/` after touching
   any component frontmatter (component-design §8: invalid YAML does not error — it makes the
   component VANISH from the registry):
   ```bash
   sed -n '/^````js$/,/^````$/p' docs/modules/templates/check_agent_frontmatter.md | sed '1d;$d' > /tmp/guard.mjs && node /tmp/guard.mjs
   ```
   **ALWAYS ALSO validate the RAW agent templates** — the ones bootstrap copies VERBATIM with
   `cp` (no fence extraction), which the command above never sees because they live outside
   `.claude/`:
   ```bash
   python -c "import io,yaml,glob,sys
   bad=0
   for p in ['docs/modules/agents/criteria_enforcer.md','docs/modules/agents/prd_sync_checker.md','docs/modules/agents/diff_pattern_extractor.md','docs/modules/agents/skill_reviewer.md']:
       s=io.open(p,encoding='utf-8').read().replace(chr(13)+chr(10),chr(10))
       if not s.startswith('---'): continue
       try: yaml.safe_load(s[4:s.index(chr(10)+'---',4)+1])
       except Exception as e: bad+=1; print('FAIL',p,type(e).__name__)
   print('raw agent templates:', 'OK' if not bad else str(bad)+' BROKEN'); sys.exit(1 if bad else 0)"
   ```
   Expected result: **`raw agent templates: OK`**. A FAIL here ships a component that is PRESENT
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

- **MINOR** (`v2.5.0` → `v2.6.0`): a new rule/section/template, an upstream absorption, or a schema
  change to a document projects receive.
- **PATCH** (`v2.6.0` → `v2.6.1`): corrections that add no new contract — broken references,
  counts, typos, instruction-style rewrites.
- **MAJOR:** a change that invalidates an existing project's structure without migration.

**The canonical set (GREP it, never recall it):** `README.md` (title line + structure diagram),
`docs/modules/templates/claude_md.md` (the "slim orchestrator" line), and
`.claude/commands/existing_project_adaptation.md` (its template-generation references).
`created: framework-vX.Y.Z` fields inside components are **LINEAGE, never the current version** —
they record when a component was born and MUST NOT be rewritten by a bump.

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
4. **ALWAYS WRITE THE STATUS BACK into the report file in this same session** — `applied sHASH`
   or `rejected — [reason]` per ID. The applying session owns this, not the next audit: a status
   that waits for the next run is a status nobody wrote.
5. **State explicitly which findings were NOT applied and why.** Deferring is legitimate;
   silently dropping is not — they must still read `open` for the next carry-forward.

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
4. **Record the batch in a lineage doc under `assets/docs/`** — what graduated, where each
   piece landed, what was adapted, and what was deliberately NOT absorbed (with why). That
   commit is the AUTHORITATIVE disposition for every doc in the batch.
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
   from marking it; it does NOT excuse this repo from SAYING so. Without step 7 the last link of
   the chain rests on owner memory — the exact failure class Step 0 exists to eliminate.