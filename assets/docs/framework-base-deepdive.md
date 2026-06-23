# Framework-Base Deep-Dive — Specs implementáveis: harness de eval, framework-audit agendado, meta-métricas

**Companheiro de** `framework-base-upgrade.md`. Enquanto aquele ABSTRAI (os eixos, os 6 loops, as 2 dimensões), este DESENHA as duas peças que o §11 do upgrade marcou como faltando/aspiracionais, em nível de implementação: o **harness de eval real** (§A1), a skill **`framework-audit` agendada** (§A2) e as **meta-métricas** que dão sensores ao loop (§B). Foco do dono (2026-06-23): fechar as 2 lacunas + medir o framework.

> **Nota honesta sobre cross-projeto (descartado pelo dono, com razão):** o aprendizado cross-projeto automático (lições do projeto A semearem o gerador → projeto B) **não é viável** porque os repos dos projetos não se comunicam com o repo do framework-base. A versão REALISTA é um **ritual manual de colheita** (`graduation harvest`): periodicamente — ou ao concluir um projeto — um humano (com Claude) revê os rules/KBP/logs do projeto, identifica o que é GENERALIZÁVEL (não-de-domínio), e copia manualmente para o gerador. **Esta própria sessão (S146/S147) é o template literal desse ritual** — foi exatamente "colher lições do projeto-fonte para o framework-base". Não automatizável sem um canal entre repos; mas o ritual é barato e repetível. Registrado, não desenhado em profundidade (decisão do dono).

---

## Parte A — Fechar as 2 lacunas

### A1. O HARNESS DE EVAL real (não o campo `last_eval` vazio)

**O problema honesto (do upgrade §11.1):** todo agente carrega `last_eval:`/`fixes:`, mas leem `none`/`[]` em todo o repo. O "eval" é uma instrução manual de "2 cenários", deferrable. Há o SUBSTRATO de linhagem, mas nenhum EXECUTOR. Um campo sem runner é dívida de documentação.

**O que "eval" significa para um agente LLM (não é unit test):** dado um INPUT conhecido (uma *fixture*), o agente produz o JULGAMENTO esperado? Exemplos:
- `code-reviewer` recebe um diff com um bug PLANTADO conhecido → DEVE sinalizar.
- `criteria-enforcer` recebe um critério fraco conhecido → DEVE fortalecê-lo (3 partes + sinal de falha).
- `diff-pattern-extractor` recebe um diff com um padrão conhecido → DEVE capturá-lo.
- `red-team` recebe uma RPC com um furo plantado (ex.: guard pela entidade errada) → DEVE achá-lo.

**Os dois tipos de eval:**
1. **Creation eval** — quando um agente/skill NOVO é autorado: N cenários-golden que ele DEVE passar antes de shipar. Popula `last_eval: sN (K/N passed)`.
2. **Regression eval** — contínuo: uma biblioteca de fixtures (diffs com bug plantado, specs ruins) re-rodada periodicamente OU quando o arquivo do agente muda. É o que pega "uma edição no `code-reviewer.md` o enfraqueceu".

**O problema da NÃO-DETERMINISTICIDADE (e como contornar):** a saída de um LLM varia, então eval NÃO pode ser match exato de string. Três técnicas combináveis:
- **Contains-judgment:** a saída CONTÉM o veredito exigido? (o bug foi sinalizado / o critério ganhou as 3 partes). Robusto a fraseado.
- **Best-of-N / maioria:** rodar a fixture N vezes (ex.: 3), exigir ≥K passes (ex.: 2). Absorve a variância. Caro — reservar para fixtures críticas.
- **LLM-as-judge:** um agente avaliador (Claude julgando Claude) grada se a saída cumpre uma RUBRICA escrita na fixture. É o mais flexível; a rubrica é a fonte da verdade, não a string.

**A biblioteca de fixtures — a sacada que torna isto BARATO:** a melhor fonte de fixtures já existe e é de graça — **cada escape que o Post-Mortem table (`framework-base-upgrade.md` §9.3) registrou é um caso real "isto deveria ter sido pego".** Logo: toda vez que o dono acha um bug que um review perdeu, o Post-Mortem (a) roteia a melhoria sistêmica E (b) **gera uma fixture de regressão** para o agente responsável (o diff/spec que escapou + a rubrica "o agente X deve sinalizar Y"). **O harness de eval e o Post-Mortem table são o MESMO loop** — as fixtures do eval são geradas pelos próprios escapes que o framework já registra. Isso elimina o trabalho de "inventar casos de teste para o agente".

**Onde vive:**
```
.claude/evals/
  fixtures/
    code-reviewer/
      F001_planted-toISOString-bug.md      # input (diff) + rubrica (must flag timezone)
      F002_escape-s116-card-day1.md         # colhido do Post-Mortem S116
    criteria-enforcer/
      F010_weak-criterion-no-failure-signal.md
    red-team/
      F020_guard-wrong-entity-joint-close.md  # colhido do PARK-CLOCK-01 S111
  framework-eval/SKILL.md                   # o runner
```
Cada fixture = `input` (o diff/task/RPC) + `rubric` (o que o agente DEVE produzir) + `provenance` (creation | escape sN).

**O runner (`framework-eval` skill):**
1. Recebe um alvo (agente X) ou "all".
2. Para cada fixture de X: spawna o agente X com o `input` da fixture (via Agent tool), captura a saída.
3. Grada: contains-judgment para fixtures simples; best-of-N + LLM-judge para as críticas (money/segurança).
4. Escreve o resultado em `last_eval: sN (K/N)` no frontmatter do agente; uma falha popula `fixes:` quando corrigida.
5. Reporta: `[agente] K/N fixtures passaram · N-K regressões`.

**O que ALIMENTA `last_eval`/`fixes` (fechando o ciclo que hoje está vazio):**
- `last_eval` ← creation eval (no autoramento) + regression eval (na cadência).
- `fixes` ← uma regressão pega → o fix do agente é registrado.

**Disciplina de custo (eval gasta tokens — spawna agentes):**
- Creation eval: roda no autoramento de um componente novo (1×).
- Regression eval: roda na cadência do `framework-audit` (§A2), NÃO toda sessão; OU quando um arquivo de agente/rules muda (gatilho por-diff barato — o code-reviewer pode sinalizar "este diff editou um agente → agende regression eval").
- Best-of-N só nas fixtures de money/segurança.

**Limite honesto (documentar, não esconder):** eval de agente LLM é genuinamente PARCIAL — é uma rede de segurança, não uma prova. Cobre as classes de escape JÁ vistas (as fixtures colhidas), não classes novas. Por isso ele COMPLEMENTA o framework-audit (que procura classes NOVAS), não o substitui. Um framework que prometa "eval prova que o agente está correto" está mentindo; um que diga "eval pega regressões das classes de escape conhecidas" é honesto.

### A2. A skill `framework-audit` AGENDADA (o meta-loop que gerou tudo isto)

**O problema honesto (do upgrade §11.2):** a `codebase-audit` tem skill + cadência. O `framework-audit` — o GERADOR das 6 melhorias da S146 — só rodou porque o dono perguntou. Não é agendado. Logo, todo projeto depende de um humano lembrar de fazer a pergunta-meta.

**Spec da skill (espelha `codebase-audit`, um nível acima):**

```
---
name: framework-audit
invocation: inline
effort: high
description: >
  Meta-auditoria PERIÓDICA do PRÓPRIO framework (não do código). Pergunta "o que o
  meu PROCESSO não está pegando?" — fan-out de agentes lê logs/protocolos/componentes/
  meta-métricas e procura dimensões sem dono, eixos faltando, classes de escape
  recorrentes e mecanismos aspiracionais. Produz um batch de melhorias de framework
  (classe BEHAVIOR) para o dono aprovar. É o gerador recursivo das outras melhorias.
created: <gerado pelo bootstrap>
derived_from: framework-base-upgrade.md §3.7 (Pattern 7) + a sessão S146 que o provou manualmente
---
```

**Cadência (mais ESPARSA que a codebase-audit — pontos cegos de processo acretam mais devagar):** o `sprint-proposer` Passo 0 ganha um SEGUNDO check: propor `framework-audit` em **fronteira de fase** OU a cada `FRAMEWORK_AUDIT_CADENCE` (default ~30–40 sessões) desde a última. O dono aceita/adia.

**As perguntas que ele faz (este É o template literal da S146 — formalizado):**
1. **Cobertura de DIMENSÃO:** toda dimensão tem dono? (review/aprendizado, continuidade/memória, ops, segurança, eval). Qual está órfã? *(S146 achou: ops órfã.)*
2. **Cobertura de EIXO:** o eixo macro existe? a ponte temporal (back-sweep)? *(S146 achou: ambos faltando.)*
3. **Scan de emergência-tardia:** lê as entradas recentes do **Post-Mortem table** + o ledger de promoção de KBP — há uma CLASSE de escape recorrendo que nenhum mecanismo pega? *(o sinal de falha-recorrente.)*
4. **Auditoria aspiracional-vs-real:** há campos/mecanismos alegados mas não rodando? *(estilo-S146: `last_eval: none`; o framework-audit antes da implementação deste doc teria se auto-flagado.)*
5. **Revisão de meta-métricas (consome a Parte B):** a taxa de escape está subindo? algum reviewer com falso-positivo alto? algum KBP nunca disparando (morto)?
6. **Auto-aplicação do back-sweep:** uma regra de processo promovida recentemente condena artefatos ANTIGOS do framework?

**Fan-out:** spawna `general-purpose` para ler logs/protocolos/componentes e responder cada pergunta (exatamente os 2+2 mineradores que esta sessão usou). Profundidade nos achados confirmados.

**Output:** um batch de melhorias de FRAMEWORK (classe-BEHAVIOR) → **aprovação explícita do dono** → implementa. Investigation-only; PROPÕE, não auto-modifica protocolo.

**Segurança:** é o único loop que propõe mudanças de BEHAVIOR em lote → o portão humano é obrigatório (upgrade §10.7). Read-only; dry-run-friendly.

**O payoff de bootstrapping:** esta skill, rodando desde a sessão 1, teria achado os 6 buracos da S146 por volta da **sessão 30, não da 145** — e os "MUITO TARDE" da tabela §8.3 (criteria-enforcer AUTHORING, back-sweep, codebase-audit) teriam nascido cedo. **É a peça que converte "o framework melhora quando o dono pergunta" em "o framework pergunta a si mesmo na cadência".**

---

## Parte B — MEDIR o framework (meta-métricas / observabilidade do processo)

Medimos o código (`metrics.md`). Não medimos a EFICÁCIA do framework. Sem sensores, o tiering de risco e a poda de rules são "no feeling". Esta parte dá olhos ao loop de auto-evolução.

**As métricas (e de onde cada uma é COLHIDA — quase tudo já existe nos artefatos):**

| Métrica | O que mede | Fonte (já existe) | Saudável |
|---|---|---|---|
| **Taxa de escape** | bugs que o dono achou em tasks ✅ ÷ tasks shipadas, por janela | cada entrada do **Post-Mortem table** = 1 escape | baixa e ↓ |
| **Falso-positivo por reviewer** | quão often cada reviewer alarma algo irreal | contador `false-positive:` dos KBP + flags de review | baixo (anti cry-wolf) |
| **Eficácia/liveness de KBP** | quais padrões disparam (pagam o slot) vs. nunca (peso morto) | contadores `triggered:` do ledger | sem KBP morto há 20+ sessões |
| **Utilização de mecanismo** | quão often cada route A/B/C, especialista, gate dispara | logs de validação / Progress Log | nenhum componente nunca-spawnado |
| **Incidentes de drift** | drifts de CLAUDE.md/PRD pegos pelo sync-checker | reports do `prd-sync-checker` | contagem ↓ (disciplina firme) |
| **Envelhecimento de dívida** | nº de LOW, idade do mais velho, churn | seção "Melhorias futuras" + selos de sessão | não cresce sem limite |
| **Custo de cerimônia (proxy)** | agentes spawnados por task; tokens de review/task | contagem de spawns | proporcional ao tier de risco |

**Como é capturado (sem sistema contínuo novo):** a maioria é HARVESTED de artefatos que já existem (entradas do Post-Mortem, contadores de KBP, notas "+N KBP" do Progress Log). O **`framework-audit` (§A2) faz o rollup** numa série `framework-metrics.md` (em `.claude/phases/`, ao lado do `metrics.md` de código), uma linha por meta-auditoria — exatamente como a codebase-audit faz para o código. **A medição é um PASSO do framework-audit, não um daemon novo.**

```
.claude/phases/framework-metrics.md   # série temporal: 1 linha por framework-audit
```

**O payoff (por que medir muda o jogo):** com taxa de escape + eficácia de reviewer + liveness de KBP, as decisões viram PRINCIPIADAS em vez de "feeling":
- Você EVICTA um KBP porque ele está mensuravelmente morto (0 triggers em 25 sessões), não porque "parece velho".
- Você FORTALECE um reviewer porque ele está mensuravelmente deixando uma classe passar (alta contribuição para a taxa de escape).
- Você AJUSTA o tier de risco porque o custo de cerimônia está mensuravelmente acima do valor (poucos escapes + muitos tokens = excesso de cerimônia).
- A taxa de escape é o **"defect escape rate" do framework** — a métrica de saúde nº1: ela diz se todo o aparato está funcionando.

**Limite honesto:** a taxa de escape só mede escapes DETECTADOS (o gatilho do Post-Mortem é "quando o humano acha um bug"). Não mede o que ninguém achou. Ainda assim é o melhor sinal disponível — e melhora à medida que o uso em prod expõe mais.

---

## Parte C — O INTERLOCK: como A1 + A2 + B formam UM sistema que se mede e se evolui

As três peças não são independentes — elas se encaixam num loop fechado:

```
   escape real (dono acha bug em task ✅)
            │
            ▼
   Post-Mortem table  ──────────────►  (B) +1 na taxa de escape
   (roteia melhoria sistêmica)                    │
            │                                      │
            ├──────────────►  (A1) vira FIXTURE de regressão do agente culpado
            │                              │
            ▼                              ▼
   melhoria no agente/rule        regression eval re-roda → popula last_eval/fixes
            │                              │
            └──────────────┬───────────────┘
                           ▼
            (A2) framework-audit (na cadência) LÊ:
              - as meta-métricas (B): taxa de escape subindo?
              - os resultados de eval (A1): qual agente regrediu?
              - o Post-Mortem: qual CLASSE recorre sem dono?
                           │
                           ▼
            batch de melhorias de FRAMEWORK → dono aprova → implementa
                           │
                           └────────► fecha buracos ANTES de virarem escapes
```

- **A1 (eval)** transforma cada escape num teste de regressão permanente — o framework nunca repete a MESMA classe de escape.
- **B (métricas)** dá ao framework a consciência de COMO ele está performando.
- **A2 (framework-audit)** consome A1 + B periodicamente e fecha buracos NOVOS antes que virem escapes — e é alimentado pelas fixtures/métricas que A1/B produzem.
- O **Post-Mortem table** é o nó que conecta os três (gera fixture + incrementa métrica + alimenta o scan de classe recorrente).

> **O resultado:** o framework deixa de ser "um conjunto de regras + uma IA que ajuda quando pedido" e vira **um sistema fechado que mede a própria eficácia, transforma cada escape num imunizante permanente, e periodicamente audita os próprios pontos cegos — usando Claude, com o humano só nos portões de comportamento.** É a forma completa da auto-evolução assistida por IA.

---

## Ordem de implementação para o gerador (estas 3 peças)

1. **A taxa de escape + o rollup de meta-métricas (B)** — barato (harvest de artefatos existentes), e é o sensor que justifica todo o resto. Sem medir, você não sabe se as outras peças valem.
2. **A skill `framework-audit` agendada (A2)** — média (espelha a codebase-audit; o template já existe nesta sessão). É a peça de maior alavancagem: o meta-loop que gera melhorias.
3. **O harness de eval (A1)** — maior esforço (runner + biblioteca de fixtures + grading não-determinístico). Comece colhendo fixtures dos escapes do Post-Mortem (de graça) e rode creation-eval primeiro; regression-eval entra na cadência do framework-audit.

> Todas as três escalam por tier de risco (`framework-base-upgrade.md` §5): um `prototype` provavelmente só quer a taxa de escape; `production-financial` quer as três + best-of-N nas fixtures de money/segurança.
