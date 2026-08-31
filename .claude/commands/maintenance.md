# Framework Maintenance Session

This is a framework maintenance session, not a project bootstrap.

**Authorized operations:**
- Edit files in `docs/` (framework documentation)
- Edit files in `examples/` (reference templates)
- Edit `CLAUDE.md` (framework contract)
- Edit `README.md`

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
grep -rl "<the doc's date or slug>" assets/docs/framework-evolution-upstream-*.md
```

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

Run ALL three checks before committing. Each encodes a real miss that survived a first
pass and was only caught by a later lens (owner question / audit):

1. **Inventory propagation sweep.** When a change ADDS, REMOVES, or RENAMES any framework
   artifact (template, skill, agent, rule, script, command), ALWAYS sweep the FIXED set of
   inventory surfaces in the same session — grep the artifact's name AND the affected counts:
   - CLAUDE.md (Repository Structure tree + any counts)
   - README.md (structure diagram, flow-diagram counts, "What Bootstrap Creates" table)
   - docs/modules/README.md (directory enumerations)
   - docs/agentic_engineering_framework.md (components table + numeric claims)
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

4. **Back-sweep of every PROCESS rule promoted THIS session.** A newly promoted process rule
   condemns OLDER artifacts — applying it only where it was written leaves the repo failing its
   own new rule (the exact class an audit later reports as "rules the repo did not apply to
   itself"). ALWAYS, for each rule added or strengthened this session: name the artifacts it
   RETROACTIVELY governs, grep for them, and fix them in the SAME session — including THIS repo's
   own `.claude/` commands and rules, not only `docs/modules/` templates. Mechanical assist
   (expected result stated): for a rule about where an instruction must LIVE, grep every sibling
   invoker of the same shape; a rule applied to one of N twins is a back-sweep MISS, not a fix.
   `evolution-policy.md` already mandates back-sweep for PROJECTS — this item is the mother repo
   applying that discipline to itself.

5. **Component liveness — re-check the frontmatter of every component edited this session.**
   ALWAYS run the guard over this repo's OWN `.claude/skills/` and `.claude/agents/` after touching
   any component frontmatter (component-design §8: invalid YAML does not error — it makes the
   component VANISH from the registry):
   ```bash
   sed -n '/^````js$/,/^````$/p' docs/modules/templates/check_agent_frontmatter.md | sed '1d;$d' > /tmp/guard.mjs && node /tmp/guard.mjs
   ```
   Expected result: **exit 0**, every component listed OK. ALWAYS REPORT the outcome —
   `liveness: N components OK` or `liveness: skipped — [reason]`. A silence is indistinguishable
   from a forgetting (component-design §9 rule 3). If the session edited no frontmatter at all,
   say `liveness: skipped — no frontmatter touched`, never nothing.

## Version bumps — the framework version is a CLAIM, and it decays silently

The version label is CONSUMED by `existing_project_adaptation.md`, which keys migration decisions
to it. A stale label tells an upgraded project it is current while it receives content several
batches ahead — the same "instrument that lies" class the audits keep surfacing.

**ALWAYS decide the bump when a session changes `docs/modules/` (the templates projects receive)
or the command pipeline, and ALWAYS state the decision in the commit** — `bump: vX.Y.Z` or
`bump: none — [reason]`. Never leave it unsaid.

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
5. **NEVER edit the project's own evolution docs** (no-touch rule) — marking them
   `upstreamed` is the project's own next session's job, guided by this repo's lineage record.
6. Run the post-change verification (cross-references, template fence extraction, D16
   isolation grep over every touched file) before committing.
7. **ALWAYS HAND THE DISPOSITION BACK to the owner in the session's closing report** — one line
   per absorbed doc: its path, the verdict (graduated / adapted / rejected), the lineage file and
   commit that record it, and the explicit sentence that the doc is now **dischargeable**, i.e.
   the project's own next session marks its header `upstreamed`. The no-touch rule stops this repo
   from marking it; it does NOT excuse this repo from SAYING so. Without step 7 the last link of
   the chain rests on owner memory — the exact failure class Step 0 exists to eliminate.