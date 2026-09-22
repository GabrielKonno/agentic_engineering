# Template: check-rules-paths.mjs — rules load-scope guard

> Create at `scripts/check-rules-paths.mjs` during bootstrap (Step 5.7 — ALL tiers).
> Dependency-free Node script; needs `git` on PATH. Runs via `node scripts/check-rules-paths.mjs`;
> if the project has a `package.json`, also register `"check:rules-paths": "node scripts/check-rules-paths.mjs"`.
> Invoked by `rules-agents-updater` whenever it creates or rescopes a rule (every tier), and — at
> `internal-tool`+ — by the CI `guards` stage (bootstrap Step 14.2).
>
> **Why this exists (upstreamed from a production project, 2026-09):** Claude Code loads every
> `.claude/rules/*.md` that has NO `paths:` frontmatter key at the start of EVERY session and EVERY
> subagent. A rule WITH `paths:` (a YAML list of globs) enters the context only when the agent READS
> (Read tool) a file that matches. The framework's rule templates declared their scope in
> `applies_to:`, a key the harness IGNORES — so the scope existed as intent and never as mechanism.
> Measured in the source project: 19 rules files took **~52% of a 1M context window** before any
> work, and a 200k-window subagent died with "Prompt is too long" on its starting context alone.
> After the move to `paths:` the always-loaded share was ~5% and a subagent started at ~63k tokens.
> Same class as component-design §8: the component looks configured and the harness does not see it.
>
> **The ALWAYS_LOADED list is decided at bootstrap** and every entry carries its reason. The
> framework ships two: `session-rules.md` and `evolution-policy.md`, which govern the session
> protocol and every evolution, whatever file is touched. **A new entry is an erosion signal** —
> it pays its size in every session and every subagent.
>
> **Dead globs are REPORTED, never failed.** A glob that matches no tracked file is either a typo or
> a module the PRD declares and nobody has built yet — the guard cannot tell them apart, and failing
> the second turns a normal build order into a red CI. Read the `DEAD` lines when the output shows them.
>
> The source project's guard used `picomatch`; this template matches with git's own `:(glob)`
> pathspec instead, so it has no dependency. Its informational "files a rule cites but its globs do
> not cover" report was stack-specific (it matched source-file extensions) and was not upstreamed.

````js
#!/usr/bin/env node
/**
 * check-rules-paths — guards the LOAD SCOPE of `.claude/rules/**.md`.
 *
 * WHY: Claude Code loads a rules file WITHOUT a `paths:` key in EVERY session and EVERY subagent.
 * A rule WITH `paths:` (YAML list of globs) loads only when a matching file is READ (Read tool — a
 * shell `cat` does not trigger it). `applies_to:` looks like scope and is ignored by the harness.
 *
 * ASSERTS (exit 1 on any violation):
 *   1. every rules file has `paths:` OR is listed in ALWAYS_LOADED, with its reason;
 *   2. no rules file carries `applies_to:` (the dead key);
 *   3. no rules file is BOTH scoped and listed in ALWAYS_LOADED (contradictory declaration).
 * REPORTS (never fails): the always-loaded share of rule characters (the number that erodes), and
 *   every DEAD glob — one matching no tracked file: a typo, or a module not built yet.
 * FAILS CLOSED (exit 2): not inside a git work tree, or no `.claude/rules/` directory.
 *
 * Glob matching uses git's `:(glob)` pathspec (`**` crosses directories, `*` does not); `{a,b}`
 * brace alternation is expanded here first, because git pathspecs have no braces.
 * Invoked by: rules-agents-updater (rule created/rescoped, every tier); CI `guards` stage (internal-tool+).
 */
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";

// Decided at bootstrap. Every entry needs a reason; every new entry is paid in every session.
export const ALWAYS_LOADED = {
  "session-rules.md": "governs the session protocol the orchestrator runs, whatever file is touched",
  "evolution-policy.md": "governs every component/rule evolution, in any session",
};

const RULES_DIR = ".claude/rules";

function git(args) {
  return execFileSync("git", args, { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
}

function fail2(msg) {
  console.error(`✖ check-rules-paths: ${msg}`);
  process.exit(2);
}

// Pathspecs resolve against the cwd, so anchor at the work-tree root before reading anything.
try { process.chdir(git(["rev-parse", "--show-toplevel"]).trim()); } catch { fail2("not inside a git work tree — nothing below would be evidence"); }
if (!existsSync(RULES_DIR) || !statSync(RULES_DIR).isDirectory()) fail2(`no ${RULES_DIR}/ directory`);

function listRules(dir) {
  const out = [];
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, e.name);
    if (e.isDirectory()) out.push(...listRules(p));
    else if (e.name.endsWith(".md")) out.push(p);
  }
  return out.sort();
}

function frontmatter(src) {
  const m = src.replace(new RegExp("^" + String.fromCharCode(0xfeff)), "").match(/^---\r?\n([\s\S]*?)\r?\n---/);
  return m ? m[1] : null;
}

/** Drop a YAML `# comment` that sits OUTSIDE quotes (a `#` inside a quoted glob is kept). */
function stripComment(s) {
  let q = null;
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (q) { if (c === q) q = null; continue; }
    if (c === '"' || c === "'") q = c;
    else if (c === "#" && (i === 0 || /\s/.test(s[i - 1]))) return s.slice(0, i);
  }
  return s;
}

const unquote = (s) => s.trim().replace(/^["']|["']$/g, "");

/** Split an inline `[a, b]` list on commas that are outside quotes AND outside `{…}` braces. */
function splitInline(s) {
  const out = []; let cur = ""; let q = null; let depth = 0;
  for (const c of s) {
    if (q) { cur += c; if (c === q) q = null; continue; }
    if (c === '"' || c === "'") q = c;
    else if (c === "{") depth++;
    else if (c === "}") depth = Math.max(0, depth - 1);
    else if (c === "," && depth === 0) { out.push(cur); cur = ""; continue; }
    cur += c;
  }
  out.push(cur);
  return out.map(unquote).filter(Boolean);
}

/** `paths:` as a YAML block list (indented or not), an inline `[a, b]` list, or a scalar. null = no key. */
export function parsePaths(fm) {
  if (!fm) return null;
  const lines = fm.split(/\r?\n/);
  const i = lines.findIndex((l) => /^paths\s*:/.test(l));
  if (i < 0) return null;
  const rest = stripComment(lines[i].replace(/^paths\s*:/, "")).trim();
  if (rest.startsWith("[")) return splitInline(rest.replace(/^\[/, "").replace(/\]$/, ""));
  if (rest) return [unquote(rest)];
  const globs = [];
  for (const raw of lines.slice(i + 1)) {
    const l = stripComment(raw);
    if (!l.trim()) continue;                       // blank or comment-only line inside the list
    const m = l.match(/^\s*-\s+(.+?)\s*$/);
    if (!m) break;                                 // the next key ends the list
    globs.push(unquote(m[1]));
  }
  return globs;
}

/** `{a,b}` groups, applied repeatedly: `src/{a,b}/*.{ts,tsx}` → 4 globs. */
export function expandBraces(glob) {
  const m = glob.match(/\{([^{}]*,[^{}]*)\}/);
  if (!m) return [glob];
  return m[1].split(",").flatMap((alt) => expandBraces(glob.replace(m[0], alt)));
}

function matchesAny(glob) {
  return expandBraces(glob).some((g) => git(["ls-files", "-z", "--", `:(glob)${g}`]).length > 0);
}

const failures = [];
const dead = [];
let total = 0;
let always = 0;

for (const file of listRules(RULES_DIR)) {
  const name = relative(RULES_DIR, file).replace(/\\/g, "/");
  const src = readFileSync(file, "utf8");
  const fm = frontmatter(src);
  const globs = parsePaths(fm);
  total += src.length;

  if (fm && /^applies_to\s*:/m.test(fm)) failures.push(`${name}: carries \`applies_to:\` — the harness ignores it; use \`paths:\``);

  if (!globs || globs.length === 0) {
    if (ALWAYS_LOADED[name]) {
      always += src.length;
      console.log(`ALWAYS  ${String(src.length).padStart(7)}  ${name} — ${ALWAYS_LOADED[name]}`);
    } else {
      failures.push(`${name}: no \`paths:\` and not in ALWAYS_LOADED — it would load in EVERY session and subagent`);
    }
    continue;
  }
  if (ALWAYS_LOADED[name]) failures.push(`${name}: has \`paths:\` AND is in ALWAYS_LOADED — contradictory declaration`);

  let d = 0;
  for (const g of globs) if (!matchesAny(g)) { d++; dead.push(`${name}: "${g}"`); }
  console.log(`PATHS   ${String(src.length).padStart(7)}  ${name} — ${globs.length} globs, ${d} dead`);
}

const pct = total ? ((always / total) * 100).toFixed(1) : "0.0";
console.log(`\nalways loaded: ${always} of ${total} chars (${pct}%)`);
if (dead.length) {
  console.log(`DEAD globs (${dead.length}) — match no tracked file: a typo, or a module not built yet:`);
  for (const x of dead) console.log(`  - ${x}`);
}
if (failures.length) {
  console.error(`\n✖ check-rules-paths: ${failures.length} violation(s):`);
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}
console.log(`✓ check-rules-paths: every rules file declares its scope${dead.length ? ` (${dead.length} dead glob(s) reported above)` : ""}.`);
````
