# Template: check-agent-frontmatter.mjs — component-registry liveness guard

> Create at `scripts/check-agent-frontmatter.mjs` during bootstrap (Step 5.7 — ALL tiers).
> Dependency-free Node script. Runs via `node scripts/check-agent-frontmatter.mjs`; if the
> project has a `package.json`, also register `"check:agents": "node scripts/check-agent-frontmatter.mjs"`.
> Wire it as a CI stage (Step 14.2) AND run it at session start / loop start / before any
> money-path or security task (see session-rules → "Autonomous loop watchdog").
>
> **Why this exists (FRAMEWORK-AGENT-YAML-01, 2026-07-16):** in a production project, a process
> improvement stamped a `last_eval:` value as an UNQUOTED YAML scalar containing `: `
> (colon-space) in three agents' frontmatter. YAML reads `foo: bar: baz` as a nested map → the
> frontmatter fails to parse → the harness cannot read `name:` → the component silently
> DISAPPEARS from the registry (the Agent tool answers "Agent type not found", with no boot-time
> error). The three disabled agents were exactly the reviewers that enforce rigor. "The file
> exists" ≠ "the component is in the registry" — this guard converts that soft signal into a
> hard failure (exit 1). The affected class hits ANY project with agents/skills in YAML
> frontmatter, which is every bootstrapped project.
>
> The script code is kept byte-identical to the mutation-proven original (re-introducing the
> bug trips it via two independent paths; the structural floor catches it even without js-yaml).
> Comments are in Portuguese (source fidelity).

````js
#!/usr/bin/env node
/**
 * FRAMEWORK-AGENT-YAML-01 — o guard mecânico de LIVENESS dos componentes.
 *
 * POR QUE ISTO EXISTE: num projeto de produção (2026-07), uma melhoria de processo carimbou um
 * `last_eval:` em YAML sem aspas contendo `: ` (colon-space) no frontmatter de 3 agentes. O YAML
 * lê o valor como um MAPPING aninhado → o frontmatter não parseia → o agente SOME DO REGISTRY EM
 * SILÊNCIO (o Agent tool responde "Agent type not found", sem erro no boot). Ficou assim até uma
 * sessão fresca tentar spawnar um revisor OBRIGATÓRIO e falhar. Um frontmatter inválido não ERRA —
 * ele faz o componente DESAPARECER. "O arquivo existe" ≠ "o componente está no registry".
 *
 * O QUE ELE FAZ: valida o frontmatter de todo agente em `.claude/agents/` e todo `SKILL.md` sob
 * `.claude/skills/`.
 * Falha ALTO (exit 1) — a antítese exata do modo de falha que ele previne. Rodar no CI e no
 * session-start / início de loop.
 *
 * DEPENDENCY-FREE por design (um guard não pode ter, ele próprio, um modo de falha frágil): a
 * checagem estrutural pega a classe do bug sem parser. Se `js-yaml` estiver disponível (transitivo),
 * um parse completo roda como reforço — mas nunca é o único controle.
 */
import { readFileSync, readdirSync, existsSync, statSync } from "node:fs";
import { join, basename, dirname } from "node:path";

const ROOT = process.cwd();
const problems = [];
let checked = 0;

// ── descoberta dos arquivos ──────────────────────────────────────────────────
function agentFiles() {
  const dir = join(ROOT, ".claude/agents");
  if (!existsSync(dir)) return [];
  return readdirSync(dir)
    .filter((f) => f.endsWith(".md"))
    .map((f) => ({ path: join(dir, f), kind: "agent", expected: basename(f, ".md") }));
}
function skillFiles() {
  const base = join(ROOT, ".claude/skills");
  if (!existsSync(base)) return [];
  const out = [];
  for (const entry of readdirSync(base)) {
    const p = join(base, entry, "SKILL.md");
    if (existsSync(p) && statSync(p).isFile()) {
      out.push({ path: p, kind: "skill", expected: entry });
    }
  }
  return out;
}

// ── frontmatter ──────────────────────────────────────────────────────────────
function extractFrontmatter(src) {
  const s = src.replace(/\r\n/g, "\n");
  if (!s.startsWith("---\n")) return null;
  const end = s.indexOf("\n---", 4);
  if (end === -1) return null;
  return s.slice(4, end + 1);
}

// Indicadores YAML que um escalar PLANO (não citado) genuinamente NÃO pode ter como 1º caractere.
// Deliberadamente EXCLUI `[` `{` (coleções de fluxo VÁLIDAS — `fixes: []`, `tags: [a,b]`) e `>` `|`
// (block scalars, tratados acima). A autoridade do long-tail é o parse js-yaml abaixo; esta lista é
// só o piso dependency-free p/ os indicadores inequívocos.
const SPECIAL_START = new Set(["#", "&", "*", "!", "@", "%", "`"]);

/**
 * Checagem ESTRUTURAL, sem parser — pega a classe FRAMEWORK-AGENT-YAML-01 e vizinhas.
 * Retorna { keys: Set<string>, errors: string[] }.
 */
function structuralScan(fm) {
  const errors = [];
  const keys = new Set();
  const lines = fm.split("\n");
  let skipBlockIndent = -1; // indentação da chave que abriu um block scalar (> ou |)

  for (const raw of lines) {
    if (raw.trim() === "") continue;
    const indent = raw.length - raw.trimStart().length;

    // dentro de um block scalar (`description: >`): linhas MAIS indentadas são conteúdo → ignora.
    if (skipBlockIndent >= 0) {
      if (indent > skipBlockIndent) continue;
      skipBlockIndent = -1; // dedentou → fim do bloco
    }

    // só interessa chave de TOPO (indent 0) no formato `key: value` ou `key:`
    const m = raw.match(/^([A-Za-z_][\w-]*):(.*)$/);
    if (indent !== 0 || !m) continue;
    const key = m[1];
    keys.add(key);
    const value = m[2].replace(/^\s+/, ""); // valor após o primeiro `: `

    if (value === "") continue; // `key:` com filhos aninhados (ex.: metadata:) — fora de escopo aqui

    // block scalar: `>` `|` (+ variantes `>-`, `|+`, com comentário)
    if (/^[>|][+-]?\s*(#.*)?$/.test(value)) {
      skipBlockIndent = indent;
      continue;
    }

    // valor citado → seguro (é assim que se conserta a classe)
    if (/^".*"$/.test(value) || /^'.*'$/.test(value)) continue;

    // ⭐ A CLASSE FRAMEWORK-AGENT-YAML-01: colon-space num escalar não-citado.
    // YAML lê `foo: bar: baz` como um mapa aninhado e o frontmatter inteiro corrompe.
    if (/:\s/.test(value)) {
      errors.push(
        `chave "${key}": valor não-citado contém ": " (colon-space) → YAML lê como mapa aninhado ` +
          `e o componente SOME do registry. Cite o valor: ${key}: "…". Valor: ${JSON.stringify(value.slice(0, 80))}`,
      );
      continue;
    }
    // escalar plano começando com caractere especial YAML
    if (SPECIAL_START.has(value[0])) {
      errors.push(
        `chave "${key}": escalar não-citado começa com o caractere especial YAML "${value[0]}" → cite o valor.`,
      );
    }
  }
  return { keys, errors };
}

// parse completo (reforço, só se js-yaml resolver) — nunca o único controle.
let yaml = null;
try {
  yaml = (await import("js-yaml")).default ?? (await import("js-yaml"));
} catch {
  /* dependency-free: a checagem estrutural é a primária */
}

for (const f of [...agentFiles(), ...skillFiles()]) {
  checked++;
  const src = readFileSync(f.path, "utf8");
  const rel = f.path.slice(ROOT.length + 1).replace(/\\/g, "/");

  const fm = extractFrontmatter(src);
  if (fm === null) {
    problems.push(`${rel}: SEM bloco de frontmatter válido (--- … ---) no topo.`);
    continue;
  }

  const { keys, errors } = structuralScan(fm);
  for (const e of errors) problems.push(`${rel}: ${e}`);

  if (!keys.has("name")) {
    problems.push(`${rel}: frontmatter sem a chave obrigatória "name:".`);
  } else {
    // name deve casar o arquivo/dir — é o que o registry usa p/ resolver o componente.
    const nameLine = fm.split("\n").find((l) => /^name:/.test(l)) ?? "";
    const nameVal = nameLine.replace(/^name:\s*/, "").replace(/^["']|["']$/g, "").trim();
    // agentes podem ser plugin-scoped (`plugin:skill`) — comparar o último segmento.
    const tail = nameVal.split(":").pop();
    if (nameVal !== f.expected && tail !== f.expected) {
      problems.push(
        `${rel}: name "${nameVal}" ≠ ${f.kind === "agent" ? "nome do arquivo" : "nome do diretório"} "${f.expected}" ` +
          `(o registry resolve pelo nome — divergência = componente inalcançável pelo caminho esperado).`,
      );
    }
  }

  // reforço js-yaml: se o parse falhar, é a prova definitiva de que o registry não carrega.
  if (yaml) {
    try {
      const doc = yaml.load(fm);
      if (doc == null || typeof doc !== "object") {
        problems.push(`${rel}: js-yaml não produziu um objeto de frontmatter (parse degenerado).`);
      }
    } catch (e) {
      problems.push(`${rel}: js-yaml FALHOU ao parsear o frontmatter → ${String(e.message).split("\n")[0]}`);
    }
  }
}

// ── veredito ─────────────────────────────────────────────────────────────────
if (problems.length > 0) {
  console.error(`\n✖ check-agent-frontmatter: ${problems.length} problema(s) em ${checked} componente(s):\n`);
  for (const p of problems) console.error("  - " + p);
  console.error(
    "\nUm frontmatter inválido NÃO erra — faz o componente DESAPARECER do registry em silêncio " +
      "(FRAMEWORK-AGENT-YAML-01). Conserte antes de shipar.\n",
  );
  process.exit(1);
}
console.log(
  `✓ check-agent-frontmatter: ${checked} componente(s) OK (frontmatter parseável, name casa o arquivo)` +
    `${yaml ? " [+ parse js-yaml]" : " [modo estrutural — js-yaml ausente]"}.`,
);
````
