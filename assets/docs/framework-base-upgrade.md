# Framework-Base Upgrade Spec — abstrações para o gerador de bootstrap

**Origem:** Sessão S146 (2026-06-22) — uma auditoria de qualidade do projeto projeto-fonte revelou 6 pontos cegos do FRAMEWORK (não bugs de código), todos implementados nesta instância. Este documento **abstrai** essas melhorias (e a lição de COMO o framework evoluiu ao longo de 146 sessões — ver §8) para o **gerador de bootstrap**, de modo que TODO projeto novo já nasça mais robusto.

**Escopo:** este doc é para o repositório do GERADOR, não para o projeto-fonte. Aqui não há nada específico de Supabase/Vercel no CORE — o que é de stack vira módulo plugável (§6).

---

## 1. A abstração-mãe: de eixo único (MICRO) para eixo duplo (MICRO + MACRO)

O framework-base historicamente otimiza o **MICRO**: a qualidade *local, intra-sessão, pré-deploy* de cada MUDANÇA (code-reviewer, validation-orchestrator, red-team por-diff). Isso é excelente e raro. O ponto cego — descoberto só na sessão 146 — é o eixo ortogonal **MACRO**: a saúde *global, cross-sessão, pós-deploy* do SISTEMA.

> **Todo achado da auditoria foi uma instância dessa cegueira de eixo.** A correção não é "mais regras"; é adicionar o segundo eixo e as PONTES entre os dois. O gerador deve emitir projetos com os DOIS eixos por padrão (escalado por perfil de risco — §5).

| Eixo | Pergunta | Mecanismo (já existia? ) |
|------|----------|--------------------------|
| MICRO | "Esta MUDANÇA está boa?" | code-reviewer, validation-orchestrator, red-team — **já existia** |
| MACRO | "O SISTEMA, como um todo, está saudável?" | `codebase-audit` periódico — **faltava** |
| Ponte TEMPORAL | "As regras valem para o código ANTERIOR a elas?" | back-sweep — **faltava** |
| Ponte de LIFECYCLE | "E depois do deploy (ops/runtime)?" | dimensão Operate / ops-rules — **faltava** |

---

## 2. Os princípios a assar no CORE do bootstrap

Universais e stack-agnósticos. O gerador emite cada um como esqueleto.

1. **Revisão de eixo duplo.** Além do review per-diff, ship a skill `codebase-audit` (auditoria periódica holística: separação/manutenibilidade, segurança, desempenho, tipos/testes + ops + reconciliação de dados + métricas + triagem de dívida) + um gatilho de cadência no `sprint-proposer` (`AUDIT_CADENCE`, default ~12 sessões ou fronteira de fase). Reusa os agentes especialistas existentes (profundidade) e `general-purpose` (largura).

2. **Ponte temporal — back-sweep.** Cláusula na `evolution-policy`: *toda regra/check promovido é aplicado PARA TRÁS* (grep do codebase inteiro por violações pré-existentes → vira task). Executor: um passo no agente de extração de padrões (que já roda no fim da sessão). Fecha "regras só valem para frente".

3. **Ponte de lifecycle — dimensão Operate.** Um `ops-rules` esqueleto: backups/recuperação, observabilidade/alertas, CI, rotação de segredo, segurança de deploy, gestão de conexão, reconciliação de dados. Categorias UNIVERSAIS; conteúdo preenchido por módulo de stack. Consumido pela `codebase-audit`, não pelo review per-diff (ops não é uma preocupação de diff).

4. **Responsabilidade agregada — métricas + orçamentos.** `metrics.md` (série temporal, append-only) + `quality-budgets.md` (caps: tamanho de arquivo, escapes de tipo como `as any`, share de testes "frágeis", etc. — defaults ajustáveis) + um **delta gate** no code-reviewer (sinaliza, não bloqueia, quando um diff PIORA um orçamento). Captura o crescimento por mil-diffs-justificados (o "sapo fervido").

5. **Dívida com prazo de validade.** Cláusula de *debt-aging* na session-rules: itens de backlog "Melhorias futuras" carregam selo de sessão; a auditoria periódica triagem (KEEP/CLOSE/PROMOTE) os mais velhos que `DEBT_AGE`. Impede que "documentado" vire "resolvido para sempre" — a sombra da auto-documentação honesta.

6. **Piso automático em t=0.** O gerador **cria o scaffold de CI no init** — build/lint/test como gates automáticos. O `.github/workflows/` (ou equivalente do stack) nunca nasce vazio. O rigor não pode depender da disciplina da pior sessão.

---

## 3. As duas abstrações mais profundas (mudam o DESIGN, não só os arquivos)

**7. O framework deve AUDITAR A SI MESMO.** A `codebase-audit` audita o *código*. Mas a SESSÃO que gerou todas estas melhorias foi uma auditoria do *FRAMEWORK* — "o que o meu PROCESSO não está pegando?". Essa pergunta só foi feita porque o dono a fez; nada no framework a gerava. **A abstração mais valiosa de todas: o bootstrap inclui um ritual `framework-audit`** (periódico ou em fronteira de fase) que pergunta pelos pontos cegos do PRÓPRIO processo. É o *gerador* das outras seis melhorias. Sem ele, todo projeto re-descobre esses buracos tarde; com ele, cedo.

> Princípio recursivo: **um framework robusto não é o que tem mais regras — é o que tem um mecanismo para descobrir as regras que lhe FALTAM.** Os 6 buracos sobreviveram 145 sessões não por incompetência, mas porque ninguém *fazia a pergunta* periodicamente. Generalizar isso = generalizar a auto-correção.

**8. Arquétipos de sessão.** O `session-end` assume sessão de IMPLEMENTAÇÃO (extrair padrões do diff primeiro). Tivemos atrito ≥2× (S136, S146) com sessões sem código (investigação, manutenção de framework) onde passos viraram "N/A". A abstração: o bootstrap define **tipos de sessão** — `implementation` / `investigation` / `framework-maintenance` / `ops` — cada um com um `session-end` adaptado (o que extrair, o que pular). Remove o atrito recorrente do passo inaplicável.

---

## 4. O método também se generaliza: "prove manualmente, depois codifique"

A `codebase-audit` foi um ENSAIO MANUAL (a própria auditoria desta sessão) antes de virar skill — risco quase zero, porque codificamos um processo já provado. O bootstrap pode encodar isso como regra de meta-processo: **ao adicionar um novo processo/skill, rode-o manualmente uma vez (dry-run) antes de codificá-lo.** Evita codificar cerimônia especulativa.

---

## 5. O princípio anti-burocracia: TIERING por perfil de risco

Sem isto, a generalização vira tiro no pé — nem todo projeto merece cerimônia de sistema financeiro.

> O gerador pergunta o **perfil de risco** no init (`prototype` / `internal-tool` / `production` / `production-financial`) e **escala a cerimônia** ao perfil:
> - `prototype`: só o eixo MICRO (review básico). Nada de ops/budgets/audit periódico.
> - `internal-tool`: + CI + métricas leves.
> - `production`: + dual-axis completo + back-sweep + ops + debt-aging.
> - `production-financial`: + reconciliação de dados + backups testados + red-team obrigatório em money-paths + framework-audit mais frequente.

Robustez **sob demanda**, não imposta. (O projeto-fonte é `production-financial` — por isso backup/PITR e reconciliação eram críticos; num blog pessoal, seriam over-engineering.)

---

## 6. Split CORE ↔ MÓDULO de stack (o que o gerador pluga)

| CORE (stack-agnóstico, sempre emitido) | MÓDULO de stack (detectado/perguntado no init) |
|---|---|
| dual-axis (codebase-audit + per-diff review) | conteúdo de ops (ex.: gerenciado-Postgres→PITR/advisors; serverless→cron/connection-pooler) |
| back-sweep (evolution-policy + pattern-extractor) | o arquivo de CI concreto (detectar test runner / build) |
| debt-aging, quality-budgets (defaults), metrics | script de backup do banco |
| framework-audit, session archetypes, risk-tiering | queries de reconciliação de dados (schema-específicas) |
| a ESTRUTURA de ops-rules (categorias + checklist) | observabilidade (qual tracker) |

Regra de ouro: **se cita um produto (Supabase, Vercel, Stripe), é módulo, não core.** O core descreve a DIMENSÃO ("toda app com banco precisa de política de backup testada"); o módulo a implementa.

---

## 7. Manifestação concreta no gerador (checklist de implementação)

Ao gerar um projeto novo, o bootstrap deve:

1. Perguntar **perfil de risco** + **stack** (§5, §6).
2. Emitir os esqueletos CORE: `codebase-audit` skill, `ops-rules` (estrutura), `quality-budgets` (defaults), `metrics.md` (vazio), cláusulas de back-sweep + debt-aging nas rules de processo, o passo de back-sweep no pattern-extractor, o gatilho de cadência no sprint-proposer.
3. **Criar o scaffold de CI já no init** (piso em t=0).
4. Injetar o **módulo de stack** apropriado (ops content, CI runner, backup script).
5. Definir os **arquétipos de sessão** no protocolo + `session-end` ramificado por tipo.
6. Agendar o **framework-audit** na cadência do perfil.
7. Escalar tudo ao perfil de risco (um `prototype` recebe um subconjunto mínimo).

---

## 8. Evidência: a evolução do próprio framework ao longo do projeto

> Esta seção abstrai COMO o framework deste projeto evoluiu ao longo de ~146 sessões — a criação/refino de agents, skills, rules, hooks; o fluxo, a orquestração e as convenções de descrição. O valor: cada mecanismo que **emergiu tarde para remendar uma falha recorrente** é exatamente o que o gerador deveria shipar desde a sessão 1. (Análise minerada dos logs de adaptação, do Progress Log e dos próprios componentes — preenchida na própria S146.)

_[Preenchido com a síntese dos mineradores de evolução — ver subseções abaixo.]_

### 8.1 Arco de fluxo / orquestração / aprendizado

O framework deste projeto não nasceu pronto — ele **acretou em cinco fases**, e o padrão de quando cada mecanismo apareceu é a evidência central deste doc.

- **Fase 0 — Sem framework (S1–S9).** Build cru. Correções viravam prosa ad-hoc no log; a MESMA classe de bug (timezone `toISOString`→`parseLocal`, dupla-contagem) recorreu em S5/S6/S7 sem memória. **O custo de não ter loop de aprendizado está visível no próprio log.**
- **Fase 1 — Primeiro protocolo (S10).** Migração para "Agentic Engineering": loop de auto-validação, PRD retroativo, critérios de aceite, e os **primeiros 12 Known Bug Patterns minerados retroativamente de S1–S9** + o **cap de 20**. Lição: o artefato de aprendizado foi criado *depois* de 9 sessões de dor já paga.
- **Fase 2 — Sprint + model-switch (≈03-26 / S28).** Sprint-approved mode, exception stops, cap de 3 discoveries/sprint, extração de padrões por diff. O **1º MODEL SWITCH → Opus** dispara organicamente em S28 (tarefa de arquitetura: cron auto-close).
- **Fase 3 — Infra completa de skills/agents (Adapt.1 v1.6.0 ≈S37; Adapt.3 v2.1.0 ≈04-07).** Aqui nasce a espinha: `validator`+`arbitrator`; `evolution-policy` (FIX/DERIVED/CAPTURED + fronteira DATA/BEHAVIOR); `component-design` (gap-declaration); `session-end`+`context-recovery`; `auth-rules`+`multi-tenancy-rules`; Coverage Gap Declarations nos reviewers; especialistas (`data-integrity-checker`/`performance-auditor`) pré-instalados via vocabulário de gap. O Progress Log migrou de blocos completos → **tabela-índice** (blocos não sobrevivem a 100+ sessões — um *scaling move*).
- **Fase 4 — Estado estacionário + acreção de guardas (S46→S145).** Cadência estável de `+1/+2 KBP` por sessão; rules de domínio crescem com os módulos (`parking-rules` na Fase 7, `cadastro-rules` ≈S91). **PRD-dois-níveis** aprovado em S109; **criteria-enforcer AUTHORING mode** ≈S119.
- **Fase 5 — Camada de sistema-inteiro (S146).** `codebase-audit`, `quality-budgets`, `metrics`, **back-sweep** e o **piso de CI** — TODOS nesta sessão, após 145 sessões de review puramente diff-local e forward-only.

**O loop de aprendizado (o mecanismo mais importante):** uma lição nasce como **Known Bug Pattern** no `code-reviewer.md` (cap 20); ao bater o teto, padrões bem-envelhecidos (1 trigger, há muitas sessões) são **promovidos para um rules-file de domínio** (liberando slot), e os que nunca disparam em ~20+ sessões são **removidos**. Os comentários HTML no `code-reviewer.md` são um *ledger de proveniência* completo. É um **loop de aprendizado com custo de contexto LIMITADO** — a abstração nº1 para qualquer gerador.

### 8.2 Arco de componentes + convenções de descrição

O campo `created:` do frontmatter é o registro arqueológico. Os componentes nascem em **5 tiers**, mapeando um ciclo de vida claro:

- **Tier 0 — primitivos pré-framework** (`created: s1 (pre-framework)`): `code-reviewer`, `security-reviewer`, `red-team`, `blue-team`. Os primitivos irredutíveis de review; `derived_from: null` — bedrock confiado.
- **Tier 1 — skills de processo pré-validadas** (`framework-v1.6.0/v2.1.0 (pre-validated)`): toda a maquinaria do ciclo de sessão (`sprint-proposer`, `validation-orchestrator`, `session-end`+5 sub-skills, `context-recovery`). Cada `derived_from:` aponta para um *passo do protocolo*. **Shipadas como bundle versionado, não crescidas.**
- **Tier 2 — adaptação/template** (`arbitrator`, `validator`, especialistas): vieram de uma biblioteca-exemplo e foram mantidos por encaixarem.
- **Tier 3 — migrados skill→subagent em s37** (`criteria-enforcer`, `diff-pattern-extractor`, `prd-sync-checker`): *reclassificados* quando o trabalho passou a exigir contexto isolado.
- **Tier 4 — emergentes da auto-auditoria** (`2026-06-22`): `codebase-audit`, `ops-rules`, `quality-budgets` — nasceram de uma meta-auditoria do PRÓPRIO framework.

**Rules-files nascem por acúmulo:** quando os bug-patterns de um domínio estouram o cap do code-reviewer, são promovidos a um rules-file. Evidência quantitativa: `auth-rules.md` carrega **10** anotações "promoted from sN"; rules fundacionais (`multi-tenancy`, `component-design`, `database-rules`) carregam **0** — foram autorados deliberadamente, não crescidos.

**Convenções de descrição/autoria (reusáveis em qualquer projeto):**
- **Pushy Description** = PURPOSE + ACTIVATION: `[função-núcleo] · USE PROACTIVELY when [trigger] / when [reviewer] declares a [domain] gap · NOT needed for [exclusão] · Without this [consequência] · Produces [Report] → [OUTCOME_A/B]`. A **linha de função-núcleo é OBRIGATÓRIA** (um trigger sem substância é o anti-padrão nomeado).
- **Frontmatter de linhagem** (`invocation, effort, tools, receives, produces, created, derived_from, last_eval, fixes`) — torna o contrato de I/O e a proveniência explícitos; é o substrato de evolução do framework.
- **Alinhamento de vocabulário** (a ponte de gap): a declaração de gap do reviewer, a descrição do especialista e o orquestrador DEVEM compartilhar a frase exata — "se o vocabulário quebra em qualquer elo, o especialista existe mas nunca é spawnado".

**Decisões arquiteturais (princípios de base):**
- **Agent-vs-Rule por custo:** inspeção-de-código → Known Bug Pattern/rules (grátis); +queries DB → agente standalone (~15-25k tokens); +probes invasivos → tier-3 com aprovação humana.
- **Gap-declaration roteia pelo Claude principal** (workaround do limite "subagente não spawna subagente"): adicionar um especialista = uma frase de gap + uma descrição casada, **zero mudança de orquestração**.
- **Não reinventar mecanismos nativos** (`description:` = discovery; isolamento de agente = contexto fresco; globs `paths:` = lazy-load).
- **Preserve + Add** (default append; SUBSTITUI só com ganho real sem perda; DELETA só se provadamente morto).
- **Anti-bias firewall:** reviewers NUNCA recebem o Progress Log / log de sessão / a narrativa do implementador — só o diff, regras, critérios e reports prévios. Independência é engenheirada.

**Hooks:** exatamente UM hook determinístico (`smart-formatting` PostToolUse, formata após todo Write/Edit, `||true` nunca bloqueia) + o **piso de CI** (lint/build). O princípio: *hooks/CI possuem o que é determinístico e sem-julgamento (o piso que ninguém pode esquecer); agentes possuem tudo que exige julgamento.*

### 8.3 As abstrações que emergiram TARDE (o ouro para o gerador)

O sinal mais valioso não é *o que* o framework tem — é **QUANDO cada mecanismo apareceu**. Tudo que emergiu tarde existia como buraco por dezenas de sessões; logo, é exatamente o que o gerador deveria shipar desde a sessão 1.

| Mecanismo | 1ª aparição real | Veredito |
|---|---|---|
| Known Bug Patterns + cap | S10 (retroativo, minerando S1–S9) | **Tarde-ish** — as 9 primeiras sessões pagaram o preço cheio |
| Sprint mechanics / model-switch | ≈03-26 / S28 | Médio (orgânico, aceitável) |
| Validation routes A/B/C + validator/arbitrator | Adapt.1/Adapt.3 (≈S37–S60) | Médio — só plenamente ligado ~40 sessões adentro |
| Gap-declaration / FIX-DERIVED-CAPTURED / autonomy boundary | Adapt.3 | Médio |
| **criteria-enforcer AUTHORING mode** | **≈S119** | **MUITO TARDE** — ✅-falso-positivo de specs falhos passou 100+ sessões |
| **PRD-dois-níveis anti-drift** | **S109** | **TARDE** — só quando um spec de fase de fato divergiu |
| **Back-sweep (cegueira forward-only)** | **S146** | **MUITO TARDE** — 145 sessões de review só-para-frente |
| **codebase-audit / quality-budgets / metrics** | **S146** | **MUITO TARDE** — `appointments.ts` chegou a 3339 linhas e o PITR ficou OFF sem ninguém medir |
| **Piso de CI automático** | **S146** | **MUITO TARDE** — gates eram só intra-sessão (humano/IA podiam pular) |

**O meta-sinal (a tese deste doc, agora com evidência histórica):** os mecanismos que emergiram dolorosamente tarde são EXATAMENTE os que perguntam *"o SISTEMA está saudável?"* (codebase-audit/ops/budgets, S146), *"esta regra nova condena o código ANTIGO?"* (back-sweep, S146), *"este SPEC é sólido?"* (criteria-enforcer AUTHORING, S119) e *"os requisitos em 2 docs estão sincronizados?"* (PRD-dois-níveis, S109) — i.e., **tudo ALÉM do loop per-diff "esta mudança está boa?"**, que esteve presente cedo.

Um gerador que ship só o loop per-diff produz projetos que **não notam a ausência das camadas de sistema-inteiro e de authoring-time até ~100 sessões de dívida acumularem em silêncio.** Por isso §2 (eixo macro), §3.7 (framework auto-auditável) e a revisão de SPEC em authoring-time não são especulação — são as lições mais caras deste projeto, e devem nascer com o bootstrap.

> **Fechamento:** as abstrações de §2–§7 não foram inventadas no abstrato — cada uma corresponde a um mecanismo que este projeto descobriu que faltava, tarde, ao custo de dívida real. O gerador que as assar de origem entrega projetos que chegam à sessão 146 já com a robustez que o projeto-fonte levou 146 sessões para alcançar.

---

## 9. A dimensão que faltava: CONTINUIDADE, memória e integridade do loop

> **Nota de completude (verificação S147, 2026-06-23):** uma auditoria de completude do próprio §8 revelou que a análise estava pesada no eixo de *review/aprendizado* e **conflava "memória do framework" com "o loop KBP→rules"**. Isso é só a memória de PADRÃO. Existe uma SEGUNDA dimensão, ortogonal e igualmente carga-de-peso: **como um único agente opera de forma coerente ao longo de 146 sessões e faz deploy com segurança** — memória de DECISÃO/ESTADO, gates de deploy e integridade do loop. Esta seção a documenta no formato detalhado. (Sem ela, um bootstrap emite os eixos de review mas produz projetos onde perda de contexto = perda de conhecimento.)

Formato de cada mecanismo: **História · O que acontece · Por que acontece · Por que o framework-base deve absorver · Casos de uso / cenários.**

### 9.1 Memória durável em CAMADAS (logs append-only + Progress Log como índice + CLAUDE.md-contrato)

- **História:** Nas Fases 0–1, decisões viravam prosa solta; em Adapt.1 (≈S37) o Progress Log foi MIGRADO de blocos completos → **tabela-índice** porque "blocos não sobrevivem a 100+ sessões". O CLAUDE.md foi *enxugado* duas vezes (621→443→~160 linhas de protocolo inline → ponteiros).
- **O que acontece:** Três camadas distintas. (1) **Logs de sessão append-only** (`.claude/logs/`) — o registro DETALHADO (raciocínio, alternativas, erros), explicitamente **NÃO lido no início da sessão** (é propagado para frente), lido **sob demanda** para arqueologia ("por que isso foi decidido?"). (2) **Progress Log como TABELA-ÍNDICE** em `project.md` — uma linha por sessão, com o nome do log na última coluna; o detalhe vive nos logs, não no índice. (3) **CLAUDE.md como CONTRATO auto-carregado** todo início de sessão (estado atual, padrões-chave, File Map, ledger de migrations), mantido preciso pela skill `config-file-updater` ao fim da sessão.
- **Por que acontece:** Nenhuma janela de contexto cabe 146 sessões. A continuidade exige que o estado durável seja **em-forma-de-índice** (sobrevive) com detalhe **offloaded** para arquivos append-only por-sessão (recuperável sob demanda).
- **Por que o framework-base deve absorver:** É a dimensão que permite chegar à sessão 146 sem re-derivar tudo. O loop KBP→rules é só memória de *padrão*; a memória de *decisão/estado/handoff* (logs + índice + CLAUDE.md) é um sistema separado e igualmente essencial. Totalmente stack-agnóstico.
- **Cenário:** Sessão 90 pergunta "por que `performed_by` está em `appointment_services` e não em `appointments`?". Sem a camada de logs duráveis, o agente re-investiga (caro); aqui ele faz `grep` em `.claude/logs/` pelo log da S97 e tem o raciocínio em uma leitura. E sem a migração para índice, o próprio Progress Log teria estourado o orçamento de contexto por volta da sessão 40.

### 9.2 Sincronização do contrato: PRD pointer-sync BIDIRECIONAL

- **História:** Drift real pego em revisão manual (versão do PRD v3.4.0 vs v3.5.0 divergindo silenciosamente) levou ao discipline de sincronização.
- **O que acontece:** O `prd.md` (master versionado) é espelhado em `project.md` (`**PRD version:**`) por uma disciplina de **duas pontas**: o `prd-sync-checker` (início de sessão, passo 4 — **inclusive em sessões de continuação após compactação**) é o backstop que detecta divergência; o `project-md-updater` (fim de sessão) é a prevenção, re-lendo o PRD **mesmo se nenhum requisito mudou**. Em divergência de fato, ASK ao dono — nunca propaga em silêncio.
- **Por que acontece:** Requisitos espalhados em mais de um documento derivam em silêncio; um contrato auto-carregado errado (CLAUDE.md/PRD desatualizado) é o drift MAIS caro porque é silencioso e universal — contamina TODA sessão futura.
- **Por que o framework-base deve absorver:** "Um arquivo-contrato auto-carregado mantido preciso por uma skill de fim-de-sessão, com fronteira data/behavior, + um sync de início-de-sessão" é primitivo de base. Complementa o PRD-dois-níveis (§8.3) com a *mecânica* de sincronização.
- **Cenário:** Um spec de fase ganha uma regra nova sem bump de versão. O `prd-sync-checker` detecta por CONTEÚDO (compara marcadores de decisão datados contra o último changelog) e adiciona a entrada faltante + bump — exatamente a falha que a regra existe para pegar.

### 9.3 Post-Mortem de falha de validação — o motor de auto-correção POR-INCIDENTE (mecanismo MISSED, alto impacto)

- **História:** Formalizado em `session-rules.md`; é o mecanismo que vinha rodando "o tempo todo" e que a análise atribuiu erroneamente só ao novo ritual `framework-audit`.
- **O que acontece:** Quando o DONO acha um bug numa task que passou ✅, ANTES de corrigir o bug, o framework roda um roteamento **causa-raiz → correção sistêmica**: (1) qual passo de validação deveria ter pego; (2) por que disse ✅; (3) classifica a causa; (4) **roteia a melhoria para o documento certo** (critério FRACO → criteria-enforcer; ferramenta silenciou erro → KBP no code-reviewer; review não pegou padrão → checklist do code-reviewer; teste não escrito → skip-conditions do validation-orchestrator; contexto de subagente incompleto → context routing). Regra: "prevenir a CLASSE, não a instância". Só DEPOIS corrige o bug.
- **Por que acontece:** Um ✅-falso-positivo não é só um bug — é a evidência de um buraco no PROCESSO. Corrigir só o bug deixa o buraco aberto para a próxima.
- **Por que o framework-base deve absorver:** É o motor de loop-fechado de auto-melhoria sobre escapes de validação — a versão POR-INCIDENTE da tese "framework que descobre as regras que lhe faltam" (§3.7), complementar à versão PERIÓDICA (framework-audit). Totalmente generalizável. **É também o "eval loop" REAL** do framework (ver a correção honesta em §11).
- **Cenário:** O dono reporta em prod que a fatura de cartão dia-1 não carrega. Antes do fix: o framework identifica que o teste era de texto-fonte (passava contra o código bugado), classifica "teste não verificou valor", e endurece a skip-condition do validation-orchestrator para exigir teste de VALOR — então corrige o bug. O próximo bug da classe não escapa.

### 9.4 Gates de DEPLOY de fase (o padrão "critério de saída" / DEPLOY GUARD — MISSED)

- **História:** Visível nos blocos "DEPLOY GUARD" / "critério de saída do sprint" da Fase 10 (ex.: F10-S1 só shipava com "1 assinatura completando 2 ciclos no sandbox").
- **O que acontece:** O framework gateia o deploy de uma FEATURE MULTI-SESSÃO atrás de critérios de saída explícitos do dono, registrados como um bloco DEPLOY GUARD visível em `pendencias`, com um hard "NÃO abrir PR `dev→main` até o gate ser cumprido" + racional ("35 commits à frente → um PR deploya a FASE INTEIRA; ASS-07 não pode ser cherry-picked"). Quando cumprido, o bloco vira "✅ CUMPRIDO (Sn)" com o hash do PR, preservando o original como histórico.
- **Por que acontece:** O modo de falha "feature visível mas inerte/quebrada em prod" é exatamente o que um loop ingênuo "todas as tasks ✅ → deploya" causaria. Um trabalho code-complete em várias sessões pode estar quebrado no agregado.
- **Por que o framework-base deve absorver:** É um TIER de gate distinto — **deploy-de-fase**, acima do gate-de-diff (CI, §2.6) e do gate-de-task (validation). O conceito (critério de saída setado pelo dono como guard-block rastreável e conversível; "isto é cherry-pickável ou é tudo-ou-nada?") é base; os specifics (Asaas) são módulo.
- **Cenário:** A Fase 10 acumula 35 commits em `dev`. Sem o DEPLOY GUARD, um PR de "limpeza" mergearia a fase inteira inerte. Com ele, o merge só acontece após o smoke do dono confirmar a config de produção — e o bloco vira o registro permanente do que foi exigido.

### 9.5 Integridade do loop: a disciplina `⏭️` + a regra "Actionable findings" (UNDER-COVERED)

- **História:** Codificadas no `validation-orchestrator` após sessões em que rigor era silenciosamente degradado.
- **O que acontece:** Duas anti-trapaças de SAÍDA. (a) **`⏭️` significa "não-aplicável", NÃO "não consegui" / "o dev server não estava rodando"** — uma mudança em `.tsx` FORÇA a UI a ser ✅/❌ (Playwright exigido; "li o código e parece certo" é explicitamente rejeitado como não-verificação). (b) **Actionable findings:** qualquer bug/melhor-abordagem/edge-case visto DURANTE a validação mas não corrigido na task atual DEVE virar uma task rastreada em `pendencias` — "achados que morrem na prosa do report são invisíveis".
- **Por que acontece:** São os dois jeitos de um agente degradar rigor em silêncio: inflar `⏭️` para pular verificação difícil, e deixar descobertas evaporarem na prosa.
- **Por que o framework-base deve absorver:** São regras de integridade do loop, stack-agnósticas. A regra "achados não morrem na prosa" é literalmente a PONTE entre o review MICRO e o backlog MACRO — é como os achados da codebase-audit, os hits do back-sweep e as descobertas de validação TODOS viram trabalho rastreado.
- **Cenário:** Validando o ASS-18, o agente nota de passagem que o delete de grupo-cartão não bloqueia após a fatura paga. Não é o escopo da task — mas a regra força um item LOW em `pendencias` em vez de uma frase no report que ninguém relê.

### 9.6 Autonomia LIMITADA: sprint-approved mode + exception stops + discovery cap (UNDER-COVERED)

- **História:** Adicionada na Fase 2; o knob central de "quanto o agente faz sem supervisão".
- **O que acontece:** Um contrato de autonomia-limitada: aprovado o batch do sprint, o agente executa tasks Small/Medium SEM re-aprovação, MAS só para numa lista ENUMERADA de **exception stops** (3 ciclos de retry; ambiguidade/contradição de PRD; degradação de contexto; uma discovery que exige input humano; um falso-❌ escalado pelo arbitrator), e **capa discoveries em 3/sprint** (overflow → `pendencias`, não persegue).
- **Por que acontece:** Sem uma lista explícita de exception-stops, o agente OU pergunta demais (inútil) OU avança demais (perigoso). O cap de discoveries é o anti-rat-hole.
- **Por que o framework-base deve absorver:** É o núcleo da autonomia agêntica SEGURA — o "throttle" que permite múltiplas tasks por sessão sem nem carimbar-de-borracha nem cavar buraco. Totalmente generalizável.
- **Cenário:** No meio de um sprint de 4 tasks, o agente encontra uma 4ª discovery. O cap a manda para `pendencias` em vez de perseguir, e o sprint termina no escopo aprovado — robustez de foco.

### 9.7 Cobertura OBRIGATÓRIA de classes não-happy-path + herança de especificidade (criteria-enforcer §4b)

- **História:** O class-checklist entrou ≈S109; a herança de especificidade é do mesmo agente.
- **O que acontece:** Além de reescrever critérios fracos→fortes, o criteria-enforcer enforça duas coisas: (a) **herança de especificidade** — "um critério mais vago que sua FONTE (PRD/migration/rules) é FRACO mesmo tendo as 3 partes"; (b) o **class-checklist por-task** — se a task toca superfícies de corrida/claim-condicional, cross-org/RLS/anon, fronteira-de-calendário, ou async-stale, ao menos um critério DAQUELA classe DEVE existir; a ausência torna o conjunto FRACO **mesmo que cada critério individual seja forte**. Isto é fiado no validation-orchestrator ("um diff que toca uma superfície-gatilho com zero testes daquela classe NÃO está pronto").
- **Por que acontece:** "A implementação errada que passa é a que shipou só o happy-path." Critérios fortes individualmente ainda deixam passar a classe inteira não-testada.
- **Por que o framework-base deve absorver:** "Toda task que toca a superfície X deve carregar um teste da classe Y" é um multiplicador de rigor generalizável. As categorias (concorrência, tenancy, aritmética-de-borda, async-staleness) são quase-universais; as instâncias (RLS/cross-org) são parcialmente de stack.
- **Cenário:** Uma task de faturamento tem 5 critérios fortes, todos do happy-path. O class-checklist sinaliza ausência da classe "corrida/claim" → força um critério de idempotência sob concorrência. O bug de dupla-cobrança nunca chega ao código.

### 9.8 Sobrevivência de estado no MODEL-SWITCH (UNDER-COVERED como mecanismo)

- **História:** 1º disparo orgânico em S28 (cron auto-close = arquitetura).
- **O que acontece:** Protocolo completo de ESCALAR a capacidade do modelo no meio do projeto sem perder estado: salva estado via as 3 sub-skills → escreve um **marcador distinto** (`<!-- MODEL SWITCH — active -->`, abaixo do Progress Log, NÃO como linha de índice) → commit WIP → edita `settings.json` → pede restart → o `sprint-proposer` detecta o marcador e continua. Regra "não retomar o sprint interrompido — propor novo" evita executar plano stale.
- **Por que acontece:** Tarefas de arquitetura/segurança merecem um modelo mais capaz, mas a troca cruza uma fronteira de contexto (restart) que destruiria o estado sem o marcador.
- **Por que o framework-base deve absorver:** "Profundidade de raciocínio escalável via troca de modelo por-sessão com um marcador de estado que sobrevive ao restart" é material de base, distinto dos tiers per-task (`/effort high`) e per-agent (`effort:`) — os três empilham independentemente.
- **Cenário:** Uma sessão standard topa com uma RPC de dinheiro. O agente salva o marcador, pede restart em Opus `/effort high`, e o sprint-proposer retoma exatamente da task certa — sem re-explicar o contexto.

### 9.9 O modelo VERIFY de 3 tiers (red-team / blue-team) + tier-3 exige humano

- **História:** Instalado em Adapt.3; provado repetidamente ("só o red-team pegou" — PARK-CLOCK-01, S111).
- **O que acontece:** A cadeia adversarial gradua o rigor: REVIEW (inspeção de código) → QUERY (consultas ao banco) → **VERIFY (probes controlados/invasivos)**, onde o **tier-3 exige aprovação humana** antes de rodar (um probe que muta/estressa estado real). O red-team ataca; o blue-team verifica defesas e mantém um inventário de controles de segurança.
- **Por que acontece:** Code-reviewer e data-integrity podem AMBOS aprovar um achado de money-path e ainda assim errar (raciocinam do happy-path); só o adversário independente pega o caso onde dois mundos se cruzam.
- **Por que o framework-base deve absorver:** "Gate-de-probe-invasivo-exige-humano" é um primitivo de segurança generalizável; a cadeia adversarial completa é default para money-paths em projetos `production-financial` (§5).
- **Cenário:** Uma correção de pagamento de estacionamento passa no code-reviewer E no data-integrity E na suíte. O red-team, atacando, descobre que o guard discrimina pela entidade errada (sessão vs tx) e deixa passar o joint-close — perda de receita evitada antes do ship.

---

## 10. Claude como MOTOR DE AUTO-EVOLUÇÃO do framework

> Os componentes do framework SÃO Claude (subagentes + skills inline). Um subconjunto existe *especificamente para evoluir o framework*. Esta é a resposta à pergunta "como usar o Claude dentro do framework para evoluí-lo": o framework já é uma máquina de auto-evolução assistida por IA — esta seção a mapeia loop-a-loop e diz o que falta para torná-la first-class e SEGURA.

### 10.0 A LEI que governa tudo: a fronteira DATA / BEHAVIOR

Todo loop é gateado por `evolution-policy.md`. É o ÚNICO primitivo de segurança em que a máquina inteira se apoia, e é a primeira coisa que o gerador deve emitir:

- **Mudança de DATA** (o que o agente SABE) → Claude aplica **autonomamente**. Ex.: Known Bug Patterns, Architecture Patterns, File Map/Commands no CLAUDE.md, conteúdo de skill, *adicionar* um check a um agente, metadados de linhagem/eficácia (append-only). Racional: factual, derivado-do-diff, barato de reverter.
- **Mudança de BEHAVIOR** (como o agente AGE) → **exige aprovação humana**. Ex.: Protocolos (Session/Execution/Validation), limites de task/retry, mecânica de sprint, context routing, **rules-files (lógica de negócio de domínio)**, PRD, *remover ou enfraquecer* um check, mudar invocação/formato-de-report/trigger de um agente.
- Toda evolução é classificada por gatilho: **FIX** (algo que deveria funcionar falhou), **DERIVED** (funciona mas consolidável — ex.: 3+ KBP de um domínio → deriva rules-file), **CAPTURED** (padrão observado no uso). Log fixo: `"[FIX/DERIVED/CAPTURED]: [componente] — [o que mudou e por quê]"`.

> **Regra de ouro:** Claude edita autonomamente o que SABE (factual, reversível, ledgered); um humano aprova o que muda como Claude AGE (protocolo, lógica de negócio, o contrato de um agente). **Auto-modificação sem esta fronteira é insegura; com ela, o framework auto-modifica seu CONHECIMENTO livremente enquanto protege seu COMPORTAMENTO.**

Formato de cada loop: **História · O que Claude faz · Lê/Escreve · Fronteira de segurança · Princípio generalizável · Cenário.**

### 10.1 Loop de CAPTURA — `diff-pattern-extractor` (fim de sessão; a auto-modificação central)

- **História:** A extração por-diff entrou na Fase 2; o cap-management + back-sweep maturaram até S146.
- **O que Claude faz:** É spawnado como a 1ª ação de fim-de-sessão. (1) Lê SÓ `git diff` + `code-reviewer.md` — **NADA mais** (boundary anti-bias: não lê logs nem a narrativa do implementador; "padrões devem ser extraíveis do diff sozinho"). (2) Classifica via FIX/CAPTURED/DERIVED e escreve o padrão no `code-reviewer.md` com proveniência (`[added: sN | triggered: never | false-positive: 0]`). (3) **Cap-management:** teto de **20** padrões; ao bater ≥18, PARA e faz eviction AGORA (3 estratégias: remoção-por-inatividade / remoção-por-enforcement-de-tsc-ESLint / **promoção-a-rules-file** com um comentário-HTML de proveniência). (4) **Eficácia:** carimba `triggered: sN`. (5) **Back-sweep:** para cada regra nova/promovida, deriva assinatura grepável → varre o codebase inteiro → hits pré-existentes viram task `[back-sweep sN]`.
- **Lê/Escreve:** lê git diff + code-reviewer.md; escreve code-reviewer.md, rules-files (na promoção), pendencias (back-sweep).
- **Fronteira de segurança:** Capturar padrão é DATA → autônomo. Promoção a rules-file *toca* um artefato de classe-BEHAVIOR, mas é tratada como CONSOLIDAÇÃO (DERIVED), não lógica nova, e o ledger-HTML torna cada movimento auditável.
- **Princípio generalizável:** *Um loop de aprendizado de custo de contexto LIMITADO.* Lições nascem baratas (linha de checklist que o reviewer per-diff lê); ao saturar o store quente (cap 20), lições bem-envelhecidas graduam para o store frio (rules, sem cap), liberando o caminho quente. Contadores de eficácia + ledger = store auto-podante. O firewall diff-only mantém o padrão objetivo.
- **Cenário:** Um fix de timezone numa sessão. O extractor captura "nunca `toISOString` para data de calendário" como KBP; 30 sessões depois, com o store cheio, ele promove o padrão (que nunca mais disparou sozinho) para `database-rules.md`, libera o slot, e roda um back-sweep que acha 2 usos pré-existentes → vira task.

### 10.2 Loop de AUTHORING — `criteria-enforcer` (criação de task; endurece o SPEC antes do código)

- **História:** Pré-implementação desde cedo; o **AUTHORING mode entrou ≈S119** (tarde) após WB-PARK-01 ser autorado com um bug de SPEC (mandava reusar cópia de estágio-2 "desde o seu último serviço" para clientes que nunca fizeram serviço).
- **O que Claude faz:** Em dois modos — (a) pré-código (lê a task de pendencias) e (b) **AUTHORING** (quando uma task full-template NOVA é escrita). Aplica o padrão 3-partes (ação + resultado esperado + **sinal de falha**), review adversarial por-critério (teste de sabotagem "como uma impl errada ainda passa?"), o **class-checklist** não-happy-path (§9.7), e — só no AUTHORING — os testes de nível-spec **reuse-fit** (uma instrução "reusar X" arrasta cópia/placeholders/assunções ausentes no novo contexto?) e **variant-threading** (quais campos viram NULL quando um caminho ganha um branch novo?).
- **Lê/Escreve:** lê o bloco da task (+ arquivos do reuse no AUTHORING); escreve o bloco de critérios reescrito.
- **Fronteira de segurança:** Edita CRITÉRIOS de task, não código nem rules — e `session-rules.md` torna isto um gate obrigatório co-assinado pelo humano que autorou a task.
- **Princípio generalizável:** *Pegue o ✅-falso-positivo no AUTHORING, não na validação.* Uma implementação errada pode ser MANDADA por um spec falho; os critérios herdam a falha com forma perfeita. O fix é um revisor adversarial que roda contra o PLANO antes do código existir.
- **Cenário:** Uma task de "reusar o motor de win-back para parking" é autorada. O reuse-fit test detecta que o template de win-back assume "último serviço" — que não existe para quem só estacionou — e força um critério que prova a cópia correta. O bug de spec morre no nascimento.

### 10.3 Loop de SYNC — `prd-sync-checker` (início de sessão; mantém requisitos coerentes)

- **História:** PRD-dois-níveis aprovado 2026-06-12 (S109).
- **O que Claude faz:** No passo 4 do início (inclusive após compactação): Check A (versão PRD ↔ project.md), Check B (conteúdo: módulos/escopo/stack/regras — mismatch → ASK), Check C (master ↔ spec-de-fase: o spec é NORMATIVO, o resumo do `prd.md` não; em divergência de fato o spec prevalece e ele corrige o RESUMO; detecta "spec mudou sem bump" por conteúdo e adiciona o changelog faltante).
- **Lê/Escreve:** lê prd.md, specs de fase, project.md, pendencias, CLAUDE.md; propaga para os derivados; adiciona changelog.
- **Fronteira de segurança:** claro/não-contraditório → propaga; **ambíguo ou contradiz decisão de arquitetura → ASK**; §3.x (regra de negócio do dono) → sempre ASK. O PRD é classe-humana; Claude reconcilia os DERIVADOS a ele, nunca reescreve a decisão de produto do dono.
- **Princípio generalizável:** *Um doc de requisitos em dois níveis deriva em silêncio a menos que um agente de início-de-sessão reconcilie o resumo ao spec normativo e force o bump quando o spec se moveu sem um.*
- **Cenário:** Sessão de continuação após compactação. O sync-checker roda mesmo assim (a compactação não isenta), pega que o spec da Fase 10 ganhou a regra D-ASS20-4 sem bump, e corrige — a sessão não constrói sobre requisito stale.

### 10.4 Loop de AUDITORIA — `codebase-audit` (periódico; o SISTEMA, não a mudança)

- **História:** Criado em S146 (a camada macro que faltava); foi um ENSAIO MANUAL antes de virar skill.
- **O que Claude faz:** Disparado pelo `sprint-proposer` (Passo 0) quando `AUDIT_CADENCE` (12) sessões passaram ou em fronteira de fase. (1) Fan-out de largura: `general-purpose` em paralelo por dimensão (separação, segurança, perf, tipos/testes). (2) Profundidade SÓ em achados de money/segurança confirmados → especialistas (red-team, data-integrity, etc.). (3) Checklist de ops (`ops-rules`), (4) reconciliação financeira contra PROD (SELECT-only, anomalias=0), (5) métricas agregadas → `metrics.md` vs `quality-budgets`, (6) triagem de dívida envelhecida. Sintetiza em tasks; **arquiva achados, nunca auto-corrige**.
- **Lê/Escreve:** lê codebase inteiro, dev DB (MCP), prod (read-only), métricas; escreve metrics.md (append) + pendencias (tasks).
- **Fronteira de segurança:** investigação-only; read-only em prod; cost-disciplinado (largura barata, profundidade reservada).
- **Princípio generalizável:** *O review per-diff responde "esta mudança está boa?" para sempre e nunca "o SISTEMA está saudável?".* Precisa de um segundo observador periódico no eixo MACRO, escalado por tier de risco, que arquiva trabalho em vez de corrigir.
- **Cenário:** Sessão 12. O sprint-proposer propõe a auditoria; ela acha que um arquivo cresceu para 1300 linhas, que o PITR está OFF, e que 6 itens LOW envelheceram — tudo vira backlog priorizado antes de a dívida acumular mais.

### 10.5 Loop de CRIAÇÃO DE SKILL — Skill Creator (draft → test → eval → iterate) — **o mais fraco/aspiracional**

- **História:** Referenciado no CLAUDE.md como ferramenta de "Framework maintenance"; é um plugin externo (`skill-creator@claude-plugins-official`).
- **O que Claude faz (na teoria):** draft → test → eval → iterate de uma skill de processo nova. Na prática, o caminho de criação on-demand vive em `rules-agents-updater` §4 + um "Creation eval (subagent agents only): 2 cenários de teste" que é **explicitamente DEFERRABLE**.
- **Achado HONESTO (correção):** **Não há harness de eval real.** O eval é uma instrução MANUAL de rodar 2 cenários, deferrable. O suporte é SÓ campos de frontmatter: todo agente carrega `last_eval:` e `fixes:`, e em TODO o repo eles leem uniformemente `last_eval: none` e `fixes: []`. Nenhum componente tem `last_eval` populado.
- **O que ALIMENTA o loop de fato:** a regra `evolution-policy` "FIX → re-roda eval se o componente tem `last_eval`". Como nenhum tem, o sinal de "iterate" REAL é (a) o FIX-evolution do loop de captura (um bug que um review perdeu roteia um check de volta ao agente via o **Post-Mortem table** de §9.3) + (b) o discipline "prove manualmente, depois codifique".
- **Princípio generalizável (e a lacuna):** *Um loop draft/test/eval/iterate é o design certo, mas só é tão real quanto seu harness de eval.* Aqui o harness é um campo `last_eval` sem executor — o substrato de linhagem existe; o test-runner não. **Um framework-base DEVE shipar o harness, não só o campo** (ver §11).
- **Cenário:** Ao criar a `codebase-audit`, o eval foi o ensaio manual (rodamos a auditoria à mão na S146 e vimos que funcionava) — não um harness. O design certo seria um harness que rodasse 2 cenários da skill nova e populasse `last_eval` automaticamente.

### 10.6 O META-LOOP — `framework-audit` (Claude audita os PRÓPRIOS pontos cegos) — **o gerador de tudo**

- **História:** É o loop que GEROU o back-sweep e a codebase-audit. Rodou uma vez (S146) **porque o dono perguntou** "o que erramos no framework?". Nada no framework gerava essa pergunta.
- **O que Claude faz:** Uma sessão-meta que pergunta *"o que o meu PROCESSO não está pegando?"*. Na S146 achou 6 pontos cegos de FRAMEWORK (não bugs de código), todos instâncias de cegueira de eixo-único (MICRO-only), e o dono aprovou os 6 (batch classe-BEHAVIOR). Sua tagline: **"um framework robusto não é o que tem mais regras — é o que tem um mecanismo para descobrir as regras que lhe FALTAM."**
- **Status HONESTO:** o ritual está ESPECIFICADO (este doc) e PROVADO (S146), mas o repo ship só seus OUTPUTS (as 6 pontes). **Não há skill `framework-audit/` nem gatilho de cadência** do jeito que a codebase-audit tem no sprint-proposer. Continua sendo uma sessão-meta iniciada por humano — exatamente a dependência que a especificação quer remover.
- **Princípio generalizável:** *Auto-correção RECURSIVA.* Os mecanismos que emergiram tarde (§8.3: criteria-enforcer AUTHORING ≈S119, back-sweep S146, codebase-audit S146) são exatamente os que perguntam algo além de "esta mudança está boa?". Um framework que AGENDA uma meta-auditoria da própria cobertura descobre esses buracos na sessão 10, não na 146.
- **Cenário (o que o gerador deve emitir):** uma skill `framework-audit` que o sprint-proposer propõe em fronteira de fase (cadência maior que a codebase-audit), que fan-out de agentes lê os logs/protocolos/componentes e pergunta "qual classe de falha o processo não pega? que dimensão (ops? memória? autoria?) não tem dono? qual eval é aspiracional?" → produz um batch de melhorias de framework para o dono aprovar. **Esta sessão (S146) é o template literal dessa skill.**

### 10.7 Os portões HUMANOS (a fronteira de autonomia, consolidada)

| Portão | Onde | Por que um humano |
|---|---|---|
| Captura de padrão / eficácia / File Map | autônomo (DATA) | Factual, derivado-do-diff, append-only; barato reverter |
| Promoção KBP→rules-file | autônomo (DERIVED) mas ledgered | Toca rules-file, mas é relocação não-lógica-nova; proveniência-HTML mantém auditável |
| Arquivar back-sweep / achados | autônomo | Arquiva task; o fix é priorizado normalmente — nunca auto-corrige |
| Reescrita de critérios | autônomo, co-gate da task do humano | Endurece um contrato de aceite, não comportamento |
| Reconciliação de PRD | **ASK em ambiguidade/contradição**; §3.x sempre ASK | PRD/regra de negócio são decisões do dono |
| Rules-file de domínio novo; mudança de protocolo/limite/routing; remover/enfraquecer check; mudar trigger de agente | **aprovação humana** | Classe-BEHAVIOR — muda como o sistema AGE |
| Rodar codebase-audit / framework-audit | **dono aceita/adia** a proposta | Unidade grande de trabalho; priorização é do dono |
| Batch de melhorias do framework-audit | **aprovação explícita do dono antes de implementar** | Um batch de mudanças BEHAVIOR |

---

## 11. Correções HONESTAS + o que falta para "Claude evolui o framework" ser FIRST-CLASS

A verificação de completude fez duas correções de honestidade que o gerador NÃO pode ignorar — senão prometeria capacidades que não roda.

### 11.1 O "eval loop" é largamente ASPIRACIONAL — ship o harness, não o campo

- **O fato:** Todo agente carrega `last_eval:` e `fixes:`, mas em TODO o repo eles leem `none` / `[]`. O "eval" é uma instrução manual de 2 cenários, explicitamente DEFERRABLE. **O substrato de linhagem existe; o EXECUTOR não.**
- **O que de fato faz auto-correção:** (a) o **loop de captura** (KBP→rules), (b) o **Post-Mortem table** (§9.3 — a verdadeira espinha de auto-correção por-incidente), (c) o novo ritual `framework-audit`. NÃO um harness de eval.
- **A regra para o gerador:** *Não prometa um eval loop que você não roda.* Ou ship um **harness real** (um runner que executa N cenários de uma skill/agente nova e popula `last_eval`/`fixes` automaticamente), OU declare honestamente que a auto-correção é o Post-Mortem table + KBP loop e remova o `last_eval` aspiracional. Um campo de linhagem sem runner é dívida de documentação — exatamente a classe "documentar ≠ resolver" (§3.5) aplicada ao próprio framework.

### 11.2 O meta-loop `framework-audit` está ESPECIFICADO mas não AGENDADO — a peça que falta

- **O fato:** A codebase-audit tem skill + gatilho de cadência no sprint-proposer. O `framework-audit` — o GERADOR de todas as 6 melhorias — só rodou porque o dono perguntou. **Ele ainda não é uma skill agendada.**
- **A regra para o gerador:** ship o `framework-audit` como skill first-class COM cadência (em fronteira de fase, mais esparsa que a codebase-audit), espelhando a codebase-audit. Sem isso, todo projeto depende de um humano lembrar de fazer a pergunta-meta — e a evidência de §8.3 mostra que essa pergunta só é feita ~145 sessões tarde demais.

### 11.3 Existência vs aspiração — o estado real dos 6 loops

| Loop | Estado | Veredito |
|---|---|---|
| 1. Captura (`diff-pattern-extractor`) | shipado, wired, triggered | ✅ real |
| 2. Authoring (`criteria-enforcer`) | shipado, wired (2 modos) | ✅ real |
| 3. Sync (`prd-sync-checker`) | shipado, triggered (início de sessão) | ✅ real |
| 4. Auditoria (`codebase-audit`) | shipado + cadência, dry-run-proven | ✅ real (S146) |
| 5. Skill-creation (Skill Creator) | plugin externo, **SEM harness de eval real** | ⚠️ aspiracional |
| 6. Meta (`framework-audit`) | **especificado + provado, NÃO agendado** | ⚠️ a peça que falta |

**A leitura:** o framework já tem 4 dos 6 loops de auto-evolução assistida por IA funcionando de verdade. As duas peças que faltam (harness de eval real; framework-audit agendado) são precisamente o que transforma "Claude ajuda a evoluir o framework quando pedido" em "**o framework usa Claude para se evoluir continuamente, por padrão**".

> **→ As duas peças que faltam estão DESENHADAS em nível de implementação no companheiro `framework-base-deepdive.md`** (§A1 harness de eval real colhendo fixtures do Post-Mortem; §A2 a skill `framework-audit` agendada), junto das **meta-métricas** que dão sensores ao loop (§B) e do **interlock** que une os três num sistema fechado (§C). O aprendizado cross-projeto foi descartado lá (os repos não se comunicam — decisão do dono 2026-06-23); a versão realista é o ritual manual de colheita.

---

## 12. Síntese consolidada — o que o GERADOR deve shipar (visão completa, 2 dimensões)

A análise completa revela que o framework opera em **DUAS dimensões ortogonais**, e o gerador deve emitir AMBAS (escaladas por tier de risco):

### Dimensão A — JULGAR a mudança e APRENDER (review + learning)
Eixo MICRO (review per-diff, routes A/B/C, anti-bias firewall, VERIFY de 3 tiers) + eixo MACRO (codebase-audit) + as pontes (back-sweep TEMPORAL, ops LIFECYCLE) + o loop de aprendizado de custo-limitado (KBP cap 20 → promoção a rules). *Coberto em §2–§8, §9.7, §9.9, §10.1.*

### Dimensão B — OPERAR coerente e SHIPAR seguro (continuidade + integridade)
Memória em camadas (logs append-only + Progress Log índice + CLAUDE.md-contrato), PRD pointer-sync, model-switch survival, Post-Mortem table, gates de deploy de fase, disciplina `⏭️`/actionable-findings, autonomia limitada (exception-stops + discovery-cap), class-checklist obrigatório. *Coberto em §9, §10.2–§10.3.*

> **A lacuna histórica:** a Dimensão A foi shipada cedo e amadureceu; a Dimensão B cresceu por acreção ad-hoc e suas peças mais valiosas (Post-Mortem table, deploy gates, class-checklist) emergiram tarde. Um gerador deve emitir as DUAS dimensões de origem.

### A capacidade que coroa tudo — auto-evolução assistida por IA
Os 6 loops de §10, governados pela fronteira DATA/BEHAVIOR (§10.0). Quando completos (com as 2 peças de §11), o framework deixa de ser "um conjunto de regras" e vira "uma máquina que descobre e fecha os próprios buracos, usando Claude, com um humano só nos portões de comportamento".

### Top-10 para implementar PRIMEIRO no gerador (checklist acionável)

Ordenado por alavancagem (cada um justificado por "o buraco será descoberto na sessão N de qualquer forma"):

1. **A fronteira DATA/BEHAVIOR + FIX/DERIVED/CAPTURED** (§10.0) — o primitivo de segurança raiz; tudo se apoia nele.
2. **O loop de captura com store de custo-limitado** (KBP cap → promoção a rules, ledger de proveniência, firewall diff-only) — a abstração nº1 (§10.1).
3. **A memória em camadas** (logs append-only + Progress Log índice + CLAUDE.md-contrato + a migração blocos→índice de origem) — a Dimensão B inteira depende disto (§9.1).
4. **O Post-Mortem table** (causa-raiz → roteamento de melhoria sistêmica) — o motor de auto-correção REAL, não o `last_eval` (§9.3, §11.1).
5. **Back-sweep + codebase-audit + quality-budgets/metrics + CI floor** — as 4 peças MACRO/temporais que emergiram em S146 (§2, §8.3).
6. **criteria-enforcer com AUTHORING mode + class-checklist** — pega o ✅-falso de specs falhos no nascimento (§10.2, §9.7).
7. **prd-sync-checker + PRD-dois-níveis** — anti-drift de requisitos (§10.3, §8.3).
8. **Autonomia limitada** (sprint-approved + exception-stops + discovery-cap) + **disciplina `⏭️`/actionable-findings** — o throttle + a integridade de saída do loop (§9.6, §9.5).
9. **O risk-tiering** (`prototype`→`production-financial`) + **arquétipos de sessão** + **"prove-then-codify"** — para que a cerimônia escale ao projeto e não vire burocracia (§5, §3.8, §4).
10. **As 2 peças que faltam para a auto-evolução ser first-class:** um **harness de eval real** (não só `last_eval`) e a skill **`framework-audit` AGENDADA** (o meta-loop que gera as outras melhorias) (§11).

> **Fechamento do documento:** o gerador que assar a Dimensão A + a Dimensão B + os 6 loops de auto-evolução (com as 2 peças de §11) de ORIGEM entrega projetos que (a) chegam à sessão 146 com a robustez que o projeto-fonte levou 146 sessões para alcançar, e (b) — mais importante — **descobrem e fecham os próprios pontos cegos continuamente, usando Claude, sem depender de um humano lembrar de fazer a pergunta certa.** Essa é a diferença entre um framework que tem boas regras e um framework que melhora sozinho.
