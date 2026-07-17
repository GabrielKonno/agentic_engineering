# Framework Upstream — absorção das evoluções do projeto-fonte (2026-07-16)

**Origem:** 4 notas de evolução escritas pelo projeto-fonte (perfil production-financial) entre
2026-07-12 e 2026-07-16, documentando lições do primeiro uso real do Autonomous Loop Mode
(Level 5) e um incidente de perda silenciosa de componente. Este doc registra O QUE graduou
para os templates compartilhados (`docs/modules/`), COMO foi adaptado, e o que deliberadamente
NÃO subiu. (Isolamento de informação de projeto: o projeto é referido apenas por papel; números
de sessão e vocabulário interno dele foram genericizados em todos os artefatos de template.)

**Lote anterior desta linhagem:** `framework-base-upgrade.md` (absorção de 2026-06-23 — risk
tiering, eixo MACRO, framework-audit). Este lote é o segundo ciclo do mesmo mecanismo: o
framework-audit/retrospectivas do projeto-fonte geraram as melhorias; a `/maintenance` as sobe.

---

## 1. Watchdog + perda silenciosa de componente (nota de 2026-07-16) — ABSORVIDA INTEGRAL

**A classe (FRAMEWORK-AGENT-YAML-01):** frontmatter YAML inválido (escalar não-citado com
colon-space, carimbado por uma melhoria automatizada de metadata) não ERRA — faz o componente
SUMIR do registry em silêncio. No projeto-fonte, desabilitou de uma vez os 3 revisores que
aplicam o rigor; só um gate rígido (red-team obrigatório falhando alto) expôs o problema.
Atinge qualquer projeto com agentes/skills em frontmatter YAML = todos os bootstrapados.

| Peça | Destino no framework | Adaptação |
|---|---|---|
| Guard mecânico `check-agent-frontmatter.mjs` | `docs/modules/templates/check_agent_frontmatter.md` (fence 4-backticks `js`), extraído p/ `scripts/` no bootstrap Step 5.7 — **todos os tiers** | Código byte-idêntico ao original mutation-provado; só o cabeçalho foi genericizado (sem números de sessão) |
| Wiring de CI | bootstrap Step 14.2 ganhou o estágio `guards` (`node scripts/check-agent-frontmatter.mjs`, dependency-free) | CI pega antes do merge; a regra de sessão pega antes do PR |
| Regra "Watchdog do loop" (liveness vs julgamento + recibo) | `docs/modules/rules/session_rules.md` → seção "Autonomous loop watchdog" | Liveness = dever do orquestrador (guard no início do loop + "Agent type not found" = HARD STOP, nunca fallback silencioso); julgamento = subagente independente de contexto fresco; recibo = veredito só conta com artefato verificável (agent id + relatório) — "APPROVE da memória" não é evidência |
| Lição de design | `component_design.md` §8 (template E cópia ativa `.claude/rules/`) | Instância genericizada; regras de citação de escalares + guard + hard-stop |
| Salvaguarda no vetor do incidente | `rules-agents-updater` Step 4 — NB "Frontmatter stamping safety" | O carimbo de `last_eval:` do próprio framework era o vetor: valores ricos DEVEM ser citados + rodar o guard após todo stamp |

## 2. Propriocepção de contexto (nota de 2026-07-14, com 2 refinamentos do dono) — ABSORVIDA (SUBSTITUIÇÃO)

**A lição:** o gate de parada "~80% da janela" do Autonomous Loop Mode era INEXECUTÁVEL — o
modelo não observa o próprio uso de contexto; instruído a "estimar", confabula números com
aparência de medição (>20 pontos de erro na primeira sessão real). O template v2.5.0 do
framework ainda carregava o gate → todo projeto novo herdaria a regra inexecutável.

**SUBSTITUTE justificado (Preservar+Adicionar §5):** a seção "Context budget" do
`sprint-proposer/SKILL.md` foi substituída por "Per-task persistence — there is NO numeric
context gate" (com nota de supersessão explícita); nada de informação útil se perdeu — o
conteúdo antigo era a regra provada falsa. Mudanças:

- `sprint-proposer/SKILL.md`: disciplina de persistência por task (máx 1 em voo; fechar em
  disco como CONDIÇÃO; re-ancorar do disco pós-autocompact; relatório de subagente não é
  estado a proteger — re-rodar revisor, nunca commitar sobre veredito borrado); proibição de
  % auto-estimada; fim só em fronteira de task; ritmo per-phase e bloco LOOP CONTINUATION
  atualizados (stop reason sem "context budget").
- `session_rules.md`: exceção do task-limit reescrita + nota "sinais de degradação = parada
  de EMERGÊNCIA em loop mode, não pacing".
- `docs/agentic_engineering_framework.md` (Level 5) e `docs/modules/skills/README.md`
  atualizados em lockstep (a doc conceitual não podia seguir descrevendo o gate morto).

**Lição transversal registrada** (na nota de supersessão): instrução "estime X" sem
instrumento acessível ao executor = confabulação; ou forneça o instrumento, ou troque X por
proxy observável.

## 3. Lacunas de orquestração do loop (nota de 2026-07-14) — ABSORVIDA INTEGRAL

Todas em `sprint-proposer/SKILL.md` (Autonomous Loop Mode):

| Lacuna | Destino |
|---|---|
| 1 — Contenção (concorrência que o fluxo serial nunca teve) | Nova seção "Resource contention": subagente declara recursos exclusivos no prompt; máx 1 processo de teste live (do orquestrador); 1 escritor por doc de fase (inclusive entre passos do session-end); regra mínima = paralelizar só file-sets disjuntos sem teste live |
| 2 — Relatório de subagente frágil | Output contract ganhou a cláusula anti-morte-silenciosa ("nunca termine o turno aguardando background; reporte estado PARCIAL explícito") + bullet "Trust-but-verify": verificação de DISCO obrigatória após todo retorno de implementador, antes de commit/validação |
| 3 — Fase planejada sobre números velhos | Per-phase rhythm passo 1: RE-MEDIR toda premissa mensurável por instrumento existente na abertura da fase (números herdados são hipótese, não contrato) |
| Meta — sem coletor p/ lições de orquestração | Sprint report ganhou a seção fixa "Orchestration lessons" (distinta de discoveries de código; "none" é entrada válida), com o racional do porquê (não aparecem em diff nenhum) |

## 4. Pontos cegos de AUTORIA (nota de 2026-07-12, P1-P5) — ABSORVIDA COM ADAPTAÇÃO

| Princípio | Destino | Adaptação |
|---|---|---|
| P1 — recon/invariante cross-row como classe de critério | `criteria_enforcer.md` 4b: nova linha "cross-entity invariant net" | Genericizada (sem vocabulário de domínio do projeto-fonte); referencia o ops-rules recon set quando instalado |
| P2 — cadeia de review decidida na AUTORIA | `criteria_enforcer.md` 4c: 3º teste "Review-chain pre-classification" | "red-team obrigatório / lite / N/A citando exceção NOMEADA + condição de revogação"; exceções específicas do projeto-fonte não nomeadas |
| P3 — checklist-alignment sweep (anti-ossificação) | `rules-agents-updater` Step 2b + cross-ref na `evolution_policy` (back-sweep) | Tabela de roteamento genérica (criteria-enforcer / code-reviewer / validation-orchestrator / codebase-audit); "nenhum checklist precisa" = outcome válido registrado |
| P4 — lentes correlacionadas não compõem | NB anti-ossificação no preâmbulo do 4b (rationale, não mecanismo próprio) | Autor e enforcer compartilham o checklist → item ausente é invisível 2× |
| P5 — anti-padrão banido exige SELF-CHECK mecânico | `component_design.md` §6 (template E cópia ativa) | Formulação portável; a instância (grep do backlog do projeto-fonte) não subiu |

## 5. Ciclo de vida dos docs de evolução + protocolo de upstream (adendo 2026-07-17) — ABSORVIDA INTEGRAL

O próprio FLUXO projeto→framework-mãe não era documentado em lugar nenhum normativo — os lotes
de 2026-06-23 e 2026-07-16 funcionaram porque o dono carregou o protocolo ad-hoc. O projeto-fonte
aprovou em 2026-07-17 (na sua própria evolution-policy) a convenção de ciclo de vida dos docs
`framework-evolution-*.md`; ela graduou junto com o fechamento das três pontas:

| Ponta | Destino |
|---|---|
| Projeto (convenção + 4 estágios pending-upstream → upstreamed → efficacy-evaluated → archivable + regras invioláveis) | `docs/modules/rules/evolution_policy.md` → seção "Framework-evolution docs — the upstream lifecycle" |
| Produtor (o framework-audit produz E consome os docs; Q4 avalia eficácia dos mecanismos instalados) | `docs/modules/skills/framework-audit/SKILL.md` → "Framework-evolution docs (ALWAYS, both directions)" |
| Receptor (intake do `/maintenance`: ler dos projetos, decidir por evolução, genericizar D16, lineage em `assets/docs/`, nunca editar `projects/`) | `.claude/commands/maintenance.md` → "Upstream intake" + CLAUDE.md → "What You Do Here §4" |

Gap identificado pelo dono pós-audit de 2026-07-17 (o `/audit` mecânico não detecta AUSÊNCIA de
processo — essa é a pergunta da classe framework-audit, não de integridade claim-vs-fact).

## Deliberadamente NÃO absorvido

- **Instâncias de projeto:** os itens de reconciliação específicos, o grep self-check do
  backlog, exceções de segurança nomeadas do domínio do projeto-fonte — só as CLASSES sobem;
  instâncias entram por bootstrap/projeto.
- **Avaliação de eficácia do fix do watchdog** (o guard preveniu recorrência? a disciplina de
  recibo foi seguida?) — dever da próxima framework-audit DO projeto-fonte, não do repositório-mãe.
- **Meta-classe "remediação de achado introduz achado da mesma classe":** 1 ocorrência; fica
  em observação no projeto-fonte. Se recorrer lá (ou noutro projeto), candidata a entrar no
  framework-audit template como pergunta fixa.
- **Fiação do `check:agents` como passo explícito do session-start em projetos JÁ bootstrapados:**
  projetos existentes absorvem via `/existing_project_adaptation` ou manualmente; o framework-mãe
  só garante que projetos NOVOS nasçam com o guard + a regra.

## Verificação desta sessão

- Extração sed dos templates alterados re-testada (4-backtick fences intactas; o guard extrai
  para `.mjs` válido — `node --check` verde).
- Grep de isolamento D16 sobre todos os arquivos tocados: zero nomes de projeto/cliente, zero
  números de sessão do projeto-fonte, zero vocabulário single-project.
