# Framework Upstream — absorção do lote "cadência e prova de execução" (2026-08-31)

**Origem — doc absorvido (nome completo, conforme intake step 4; é o que o cross-check do Step 0
grepa):**
- `framework-evolution-2026-08-21-cadence-and-execution-proof.md`

1 nota de evolução escrita por um projeto-fonte de perfil production-financial em
2026-08-21, na 3ª `/framework-audit` formal dele. Três evoluções de nível FRAMEWORK, todas
graduadas. Este doc registra O QUE subiu, ONDE cada peça caiu, o que foi ADAPTADO e o que
deliberadamente NÃO subiu. (Isolamento de informação de projeto: o projeto é referido só por
papel; identificadores de sessão dele foram genericizados — durações relativas "~16 sessões",
"24 sessões" são medidas portáveis e permanecem.)

**Lotes anteriores desta linhagem:** `framework-base-upgrade.md` (2026-06-23 — risk tiering, eixo
MACRO, framework-audit) e `framework-evolution-upstream-2026-07.md` (2026-07-16 — guard de YAML,
propriocepção de contexto, lacunas de orquestração do loop, pontos cegos de autoria).

**A classe que une as três (e duas do lote anterior):** *o defeito estava no INSTRUMENTO DE
MEDIÇÃO, não no produto.* Um instrumento errado é pior que nenhum — produz uma conclusão errada
COM NÚMEROS, mais difícil de contestar que um palpite e capaz de sobreviver a várias auditorias
que olham direto para ela.

---

## 1. Cadência ancora em CONCLUSÃO, nunca em DATA — ABSORVIDA INTEGRAL

**A classe:** todo mecanismo periódico tem DOIS artefatos — o que REGISTRA o que foi feito e o
que SATISFAZ o relógio. Quando são a mesma entrada e a rodada foi PARCIAL, meio trabalho zera o
relógio inteiro. O modo de falha é assimétrico: a metade CARA (julgamento amplo, fan-out) morre
primeiro; a metade BARATA (contadores, greps) sobrevive e escreve a linha tranquilizadora.

| Peça | Destino no framework | Adaptação |
|---|---|---|
| A regra geral (writer declara `status:`; reader ancora no último `COMPLETE`; corolário anti-thrash) | `docs/modules/rules/session_rules.md` → nova seção "Cadence integrity" | Generalizada para QUALQUER mecanismo periódico (audit, review, retro, health-check), não só o audit MACRO |
| Coluna `Status` na série de métricas | `docs/modules/templates/metrics_md.md` (cabeçalho + linha 0) | Schema da tabela; nota explicando que a coluna É a âncora de cadência |
| Escrita do status (writer) | `codebase-audit/SKILL.md` Step 5 + linha `### Completion status:` no relatório | Imperativo "preencher POR ÚLTIMO, a partir do que rodou"; INCOMPLETE enfileira REOPEN em pendencias |
| Mesma disciplina na série META | `framework-audit/SKILL.md` (meta-metrics rollup + relatório) | `Status` derivado de quais das 6 perguntas rodaram |
| Leitura da cadência (reader) | `sprint-proposer/SKILL.md` Step 0 | ALWAYS ancorar no último `COMPLETE`, pulando parciais; se o mais recente for INCOMPLETE, dizer isso na proposta |

## 2. "Passou" ≠ "EXECUTOU" — ABSORVIDA (regra graduada; script NÃO)

**A classe:** toda verificação automatizada responde "passou?"; quase nenhuma responde "rodou?".
E é a segunda que falha em silêncio — a ausência de execução produz exatamente o mesmo verde que
a execução bem-sucedida. Nas duas ocorrências medidas a pista foi o TEMPO, jamais o status.

| Peça | Destino no framework | Adaptação |
|---|---|---|
| A regra (contagem com piso; guard falha FECHADO em 3 estados; skip ≠ pass; duração é evidência; veredito em módulo PURO; mutante NEUTER) | `docs/modules/rules/session_rules.md` → nova seção "Execution proof" | Posicionada como IRMÃ da disciplina de RECIBO já existente: o recibo prova que um REVISOR rodou; a contagem prova que uma FERRAMENTA rodou |
| Schema do relatório de validação | `validation-orchestrator/SKILL.md` (Phase A + formato + parágrafo do ⏭️) | Tests/Regression/Mutation passam a carregar a CONTAGEM; zero-executado ou sumário ilegível = ❌, nunca ✅ nem ⏭️ |
| Mesmo schema no agente | `docs/modules/agents/validator.md` (seções Tests/Regression/Mutation + steps 3 e 8) | Campo "Execution proof" com contagem + wall time; step 3 exige capturar ambos |
| Mutante NEUTER > DELETE | `validator.md` step 8 | DELETE quebra compilação/lança e o critério falha pelo motivo ERRADO; NEUTER mantém a condição e mata só o EFEITO — é o mutante que uma asserção fraca sobrevive |
| Checkbox de ciclo de vida | `docs/modules/rules/ops_rules.md` §3 (CI/deploy safety) | 2 itens: todo estágio verde PROVA que executou; o veredito mora em módulo puro e testável |
| Wiring no bootstrap **e no gêmeo** | `.claude/commands/bootstrap.md` Step 14.2 **e** `.claude/commands/existing_project_adaptation.md` (bloco de tiers, item 3) | Sweep do gêmeo (checklist do `/maintenance`): o que um instala, o outro instala — senão projetos ADAPTADOS ficam desprotegidos |
| Doc conceitual em lockstep | `docs/agentic_engineering_framework.md` (formato do relatório + parágrafo "Execution proof") | Superfície descritiva atualizada depois das executadas |

**NÃO absorvido — o script do guard.** O `check-agent-frontmatter.mjs` do lote anterior subiu como
código byte-idêntico porque é genérico para todo projeto bootstrapado. Um guard de "a suíte
rodou?" NÃO é: ele precisa parsear o sumário do runner específico. Graduou a REGRA (incluindo
onde o veredito deve morar para ser provável) e o wiring de CI; o script fica por projeto.

## 3. Uma regra que só o EXECUTADO conhece é folclore — ABSORVIDA INTEGRAL

**A classe:** numa arquitetura de descoberta semântica é natural — e errado — escrever a regra de
ativação DENTRO do componente ativado. A frontmatter é lida quando o harness monta o REGISTRY,
não quando alguém precisa LEMBRAR de invocar. Ninguém lê a frontmatter de um agente que não está
sendo invocado. Evidência medida: um agente declarado "obrigatório no início de toda sessão"
somou ZERO spawns em 24 sessões auditadas.

| Peça | Destino no framework | Adaptação |
|---|---|---|
| A lei de design (4 regras: instrução no INVOCADOR; auto-check mecânico; skip precisa ser DITO; provar o auto-check por NEGAÇÃO) | `component_design.md` §9 — no TEMPLATE **e** na cópia ativa `.claude/rules/component-design.md` | Declarada como mesma família de §6 (auto-check mecânico) e §8 (componente presente mas fora do registry): só um check mecânico separa "instalado" de "rodando" |
| Aplicação concreta | `sprint-proposer/SKILL.md` Step 3 + campo `### PRD sync:` no formato §4c | O step passa a se declarar o INVOCADOR e a REPORTAR sempre `ran — [outcome]` / `skipped — [reason]`; silêncio proibido |
| Caça ao mandato órfão | `framework-audit/SKILL.md` Q4 (aspirational-vs-real) | Para todo componente que se diz obrigatório, grepar o componente que OWNS aquele momento; reportar a CONTAGEM real de spawns, não a alegação. Idem para auto-checks que nunca ficaram vermelhos |
| Âncora de eficácia verificável | `docs/modules/rules/evolution_policy.md` (o que todo framework-evolution doc deve conter) | ADAPTADO da própria estrutura do doc-fonte: tabela com 1 linha por evolução, pergunta com resposta VERIFICÁVEL + o comando/artefato que responde; proibido "verificar se ajudou"; linha `Meta` obrigatória (alguma remediação introduziu achado da MESMA classe?) |
| Auto-observação do doc-fonte ("escrevi um auto-check que grepava o token errado") | `component_design.md` §9 regra 4 | Graduada como REGRA, não como anedota: provar o auto-check por negação antes de confiar nele — um check que nunca fica vermelho é decoração |

---

## Deliberadamente NÃO absorvido

- **O script de guard de execução de suíte** (ver §2) — dependente do runner; a regra sobe, o
  código não.
- **Os identificadores absolutos de sessão do projeto-fonte** — substituídos por durações
  relativas ("~16 sessões", "24 sessões auditadas"), que são a informação portável.
- **A seção "Precedentes na mesma família" do doc-fonte** (instrumento de tamanho de função que
  contava comentário; métrica de share que punia quem acrescenta teste vivo a um audit existente)
  — são instâncias já cobertas pela regra geral do instrumento; subir cada uma inflaria os
  templates sem adicionar controle novo.

## Âncoras de eficácia — o que a próxima auditoria deve MEDIR

O `evolution_policy.md` exige esta tabela de todo doc de evolução de PROJETO. O repo-mãe passa a
aplicá-la a si mesmo (o mesmo back-sweep que o checklist item 5 agora exige). Nenhuma pergunta se
responde relendo este doc.

| # | Pergunta | Como responder |
|---|---|---|
| 1 | Alguma entrada de cadência nova omitiu o `status:`? Alguma audit interrompida voltou a zerar o relógio? | grep `status:` nas linhas de `metrics.md`/`framework-metrics.md` de projetos bootstrapados após este commit |
| 2 | Algum relatório de validação citou suíte sem a contagem executada? | grep `Tests:` nos relatórios; toda ocorrência sem `(N executed)` é uma falha da regra |
| 3 | Os invocadores passaram a REPORTAR `ran`/`skipped`? Em quantas sessões desde a absorção? | grep as linhas `criteria-enforcer:`, `diff-pattern-extractor:`, `PRD sync:` nos logs |
| — | **Meta:** alguma destas remediações introduziu achado da MESMA classe? | a `/audit` de 2026-08-31 já respondeu SIM — 6 achados novos, todos de varredura incompleta. Ver `audit-2026-08-31.md` Run 2 |

## Verificação desta sessão

- **Sweep de inventário:** nenhum artefato ADICIONADO/REMOVIDO/RENOMEADO (nenhuma contagem em
  `CLAUDE.md` / `README.md` / `docs/modules/README.md` / `docs/agentic_engineering_framework.md`
  mudou). O schema da tabela de `metrics.md` só existe no template — grep confirmou que nenhuma
  outra superfície o replica. Gêmeo bootstrap ↔ existing_project_adaptation: ambos receberam a
  prova de execução no CI floor.
- **Estilo de instrução (§6):** todos os bullets novos revisados; 3 corrigidos de presente
  descritivo para imperativo ("DURATION is a signal" → "ALWAYS TREAT DURATION as evidence";
  "the verdict lives in" → "ALWAYS PUT the verdict in"; corolário anti-thrash ganhou o verbo).
- **Referências:** todas as citações novas resolvem — `session-rules → "Cadence integrity"`,
  `session-rules → "Execution proof"`, `component-design §9` (heading presente nas DUAS cópias).
- **Extração de fence:** validada nos 5 templates markdown editados (frontmatter íntegro, última
  linha real); a variante `js` conferida como controle.
- **Guard de liveness (§8):** `check-agent-frontmatter.mjs` rodado neste repo → verde; e provado
  por NEGAÇÃO contra um frontmatter com colon-space não-citado → exit 1. É a §9 regra 4 aplicada
  à própria sessão que a escreveu.
- **Isolamento D16:** grep sobre as linhas ADICIONADAS — sem nome de projeto/cliente, sem
  identificador de sessão do projeto-fonte, sem vocabulário de domínio, sem vazamento de
  português nas superfícies em inglês.
