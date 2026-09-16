# Framework Upstream — absorção do lote "mecanizar o que dependia de LEMBRAR" (2026-09-16)

**Origem — doc absorvido (nome completo, conforme intake step 4; é o que o cross-check do Step 0
grepa):**
- `framework-evolution-2026-09-16-mechanize-the-remembered.md`

1 nota de evolução escrita por um projeto-fonte de perfil `production-financial`, ao fim da sua 4ª
meta-auditoria de processo. Doze itens: nove melhorias (P1-P9) e três políticas (POL-1..3), todos
aprovados pelo dono do projeto. Este doc registra O QUE subiu, ONDE cada peça caiu, o que foi
ADAPTADO e o que deliberadamente NÃO subiu. (Isolamento de informação de projeto: o projeto é
referido só por papel; números de sessão, hashes de commit, nomes de scripts e de arquivos de regra
do projeto foram removidos — o template carrega só a forma geral de cada regra.)

**Lotes anteriores desta linhagem:** `framework-base-upgrade.md` (2026-06-23),
`framework-evolution-upstream-2026-07.md`, `framework-evolution-upstream-2026-08.md` e
`framework-evolution-upstream-2026-09.md`. O lote de 2026-08 absorveu a integridade de cadência
(`status: COMPLETE/INCOMPLETE`) e a regra do invocador (component-design §9); este lote é a medição
de que as duas, como PROSA, continuaram falhando — e o endurecimento de cada uma.

**A classe que une as doze:** *a regra existia; o que faltava era alguém LEMBRAR de executá-la no
momento certo.* Medido pelo projeto numa janela de 20 sessões: a cadência de auditoria nunca disparou
sozinha; cinco scripts de guarda com saída 1 viviam só em prosa; 14 de 20 logs não registram a
checagem de sincronia do PRD nem declaram o pulo; 0 de 20 logs têm recibo de revisão relível; duas
auditorias mediram produção e nenhuma gravou o valor de volta no item que o define.

**Força da evidência — registrada, não escondida:** cada item vem de UMA janela de medição num único
projeto, mas cada um é o 2º ou 3º incidente de uma classe que o framework já tinha nomeado (§6, §9,
integridade de cadência). Por isso subiram como CONTRATO onde a classe já era contrato, e como
HIPÓTESE só onde a regra é nova (P6).

---

## Disposição por item

| Item | O que é | Veredito | Destino no framework | Adaptação |
|---|---|---|---|---|
| **P1** | `COMPLETE` vira checklist por passo; ⏭️ só com razão ESTRUTURAL; pulo por capacidade = `INCOMPLETE`; marcador `IN PROGRESS` antes do fan-out | **ADAPTADA** | `rules/session_rules.md` → "Cadence integrity"; `skills/codebase-audit` (Status + `### Steps:`); `skills/framework-audit` (linha `IN PROGRESS`); `templates/metrics_md.md`, `templates/framework_metrics_md.md` | O projeto aplicou a duas auditorias pelo nome; aqui a regra é geral (todo mecanismo periódico) e o formato da linha de passos é o do template |
| **P2** | Recibo de revisão = relatório final do revisor salvo e commitado, citado por linha num ledger; portão antes do deploy | **ADAPTADA** | `rules/session_rules.md` → "Autonomous loop watchdog" (RECEIPT) e "Deploy gates"; `skills/validation-orchestrator` → "Review receipts"; `skills/session-log-creator` → `## Review receipts` (+ `scripts/create-log.sh`) | **SUBSTITUI** o recibo "agent id + relatório" (um id de spawn não é relível depois da sessão). O script de CI do projeto é stack-específico e NÃO subiu: o template carrega a checagem como bloco de shell e deixa o script como opção. Relatórios e o ledger `receipts.md` vão para `.claude/logs/review-reports/` — sob um diretório que os dois comandos-gêmeos JÁ criam, então nenhum comando de instalação mudou. O ledger (e não o log, escrito só no fim da sessão) é o que o portão lê, e ele lê só LINHAS DE RECIBO — a 1ª versão procurava o hash em qualquer log e casava a lista `## Commits`, um falso verde achado pelo verificador pré-commit |
| **P3** | A auditoria grava a medição DENTRO do item de reconciliação; consome os back-sweeps semânticos adiados | **ADAPTADA** | `skills/codebase-audit` steps 4 e 6; `agents/diff_pattern_extractor.md` step 6 | O template já mandava anotar `back-sweep: not greppable` — nota que ninguém lia. Agora vira TASK `[back-sweep sN] not greppable`, e o step 6 da auditoria é o leitor. O script do projeto que valida baselines é específico do formato dele e NÃO subiu |
| **P4** | Todo script de guarda precisa de invocador EXECUTÁVEL (CI ou passo de skill); prosa não conta | **GRADUADA** | `rules/component_design.md` §9 (a mesma regra um nível abaixo); `skills/codebase-audit` step 6 (checagem mecânica) | O meta-guard do projeto é Node e ficou local; o template carrega a enumeração em shell |
| **P5** | Recibo de início de sessão: cadência derivada, resultado da sincronia do PRD, peso de cadência na linha do Progress Log | **ADAPTADA** | `skills/session-log-creator` → `## Session entry` + autoverificação; `skills/project-md-updater` step 1 (`counts as N sessions for audit cadence`) | O projeto gera o bloco por script; o template já emite as linhas `PRD sync:` / `Audit cadence:` / `Loop marker:` no `sprint-proposer`, então a adaptação é COPIAR essas linhas para o log e verificar por grep. O peso da cadência também fecha o achado X-11 desta mesma sessão |
| **P6** | Agente é MUTADOR pelo que o PROMPT manda fazer, nunca pelo NOME | **ADAPTADA (hipótese)** | `skills/autonomous-loop` → "Resource contention" e Step 3b | **SUBSTITUI** a frase "a reader is a code-reviewer, red-team or integrity checker", que permitia literalmente o incidente de origem. Acrescenta isolamento por worktree como alternativa à serialização e fecha o achado B-12 (a declaração de recursos não carregava a classe) |
| **P7** | Aviso de tamanho em ~140k e falha em ~150k para componentes de processo | **ADAPTADA (leve)** | `skills/codebase-audit` step 1 (Separation) + linha `### Process component sizes:` | O script de CI do projeto não subiu; a auditoria mede com `wc -c`. Os números são os que o projeto usa como limite recomendado — o framework não tinha nenhum |
| **P8** | Dois instrumentos do projeto (vivacidade e teto de padrões) no mesmo predicado | **NÃO ABSORVIDA** | — | Os dois scripts são do projeto. A lição geral ("dois instrumentos sobre o mesmo conceito compartilham o predicado") já é a regra de fonte única que o framework carrega |
| **P9** | `security-reviewer` quando o diff toca DADO ENVIADO AO CLIENTE | **ADAPTADA** | `skills/validation-orchestrator` → Route 1 (Security check) e Route 2 | O gatilho do projeto citava a stack dele (ações de servidor, props de componente de servidor); o template usa formas gerais (forma de retorno de ação/rota/RPC, props servidor→cliente, figura privilegiada, dado pessoal) e acrescenta o report `security-reviewer: ran | skipped` |
| **POL-1** | Decisão do dono → documento normativo no MESMO commit | **ADAPTADA** | `rules/session_rules.md` → nova seção "Owner decision → normative document in the SAME commit"; invocador: `skills/session-log-creator` → `## Owner decisions` | O projeto tem PRD em dois níveis (master + specs de fase); o template fala em "o PRD (ou o spec de fase que é normativo para a fase)" e amarra à entrada no Changelog do PRD + bump de versão (`/prd_change` é comando deste repo, não do projeto) |
| **POL-2** | Split literal e cópia de template isentos do skill-gate, COM linha declarada no commit | **GRADUADA** | `rules/evolution_policy.md` → "Component creation gate"; `skills/skill-gate` → "Scope check" APONTA para a isenção (2º commit do lote) | O 1º commit gravou a isenção só na política, e o executor seguia mandando todo split para o portão — achado pelo back-sweep depois do commit. A isenção ainda não tem quem ESCREVA a linha no momento da cópia nem quem a LEIA: finding aberto B-25 em `assets/docs/audit-2026-09-15.md` |
| **POL-3** | Três docs de evolução antigos do projeto avaliados e um arquivado | **NÃO ABSORVIDA** | — | Higiene interna do projeto; o ciclo de vida desses docs já está no template de `evolution_policy` |

**Achados de construção (do mesmo doc):** dois dos cinco subiram como regra geral em
`rules/session_rules.md` → "Execution proof": (a) nunca canalizar um portão por filtro (`| tail`) — o
status visto é o do filtro, e um commit do projeto saiu com portão vermelho assim; (b) script de
portão chama subprocessos SEM shell — no Windows o `cmd.exe` engole `^` e o 1º commit de todo
intervalo deixava de ser checado. Os outros três (CR solto gravado por substituição com `$` multilinha;
barras cortadas por `node -e` e por heredoc) são específicos de ferramenta e já estão cobertos pela
disciplina de edição que o projeto carrega; não subiram.

## Deliberadamente NÃO absorvido

- **Os scripts do projeto** (portão de recibo, recibo de sessão, meta-guard de invocadores, guard de
  tamanho, validação de baselines, vivacidade de padrões) — todos Node, todos acoplados ao layout do
  projeto. O template carrega a REGRA e uma checagem em shell; um projeto pode transformá-la em script
  e ligá-la ao CI, e a regra P4 obriga que, se o fizer, o script tenha invocador.
- **Números de sessão, hashes e nomes de arquivos de regra do projeto** — removidos; identificam o
  projeto e não são portáveis.
- **Nenhuma regra de contrato foi rejeitada por evidência fraca.** P6 é a única marcada como hipótese.

## Âncoras de eficácia — o que MEDIR, e quem mede

**Quem mede (cada âncora nomeia a componente e a pergunta; `framework-audit` só existe em
`production`+):**
- **P2 e P5:** `framework-audit` → Q4 (aspirational-vs-real): conta, nos logs da janela, as seções
  `## Review receipts` e `## Session entry` vazias contra as sessões que commitaram código. Em
  `prototype` / `internal-tool` as duas regras são enviadas (via `session_rules`, `validation-orchestrator`
  e `session-log-creator`) mas ficam **`unmeasured — no measurer at prototype / internal-tool`**.
- **P3:** `codebase-audit` → linha `### Deferred back-sweeps:` (a própria execução conta os vereditos) e
  `framework-audit` → Q4 did-it-land. A escrita de volta na reconciliação só existe em
  `production-financial`. Em `internal-tool` o consumo dos back-sweeps é enviado e medido só pela
  própria linha da auditoria — sem verificador externo: **`unmeasured — no measurer at internal-tool`**.
- **P4 e P7:** `codebase-audit` → linhas `### Guard invokers:` e `### Process component sizes:` — instalada
  em `internal-tool`+. Em `prototype`: **`unmeasured — no measurer at prototype`**.
- **P1:** `framework-audit` → Q4 (um gatilho de cadência que nunca dispara). Abaixo de `production`:
  **`unmeasured — no measurer at prototype / internal-tool`**.
- **P6:** `framework-audit` → Q4 → HYPOTHESIS check, que já conta as linhas tipadas
  `- mutator/reader overlap:` em `## Orchestration lessons`. Abaixo de `production`:
  **`unmeasured — no measurer at prototype / internal-tool`**.
- **P9:** `framework-audit` → Q5 → linha "Mechanism utilization" (especialistas que nunca rodaram),
  lendo o report `security-reviewer: ran | skipped` dos relatórios de validação. Abaixo de `production`:
  **`unmeasured — no measurer at prototype / internal-tool`**.
- **POL-2:** **`unmeasured — no measurer at any tier`** — nenhuma componente lê a linha
  `skill-gate: exempt` nem detecta o bypass silencioso (finding aberto B-25).
- **POL-1:** `unmeasured — no measurer at any tier` como contagem; o `prd-sync-checker` continua sendo o
  detector das derivas que escaparem, não um contador da regra.
- **Meta:** a `/audit` de verificação deste repo sobre o commit da absorção.

Uma janela com ZERO ocorrências é "regra não exercida", nunca "eficácia confirmada".

| # | Pergunta | Como responder |
|---|---|---|
| 1 | Os logs das sessões que commitaram código trazem `## Review receipts` com linha? Algum deploy foi bloqueado por `NO RECEIPT`? Alguma isenção foi usada, e a razão era legítima? | grep `## Review receipts` e `review receipts:` nos logs da janela |
| 2 | Os logs trazem `## Session entry` preenchido? As linhas do Progress Log de sessões de loop carregam `counts as N sessions`? | grep nos logs e no Progress Log |
| 3 | A auditoria gravou os valores de volta nos itens de reconciliação? Algum `[back-sweep sN] not greppable` ficou sem veredito? | leitura dos itens depois da auditoria; grep `not greppable` no backlog |
| 4 | Algum script de guarda novo nasceu com invocador? A auditoria reportou algum `NO INVOKER`? | linha `### Guard invokers:` dos relatórios de auditoria |
| 5 | Algum status `COMPLETE` trouxe ⏭️ sem razão estrutural? | grep `steps:` nas linhas de métricas |
| 6 | Algum dispatch registrou a classe MUTADOR/LEITOR? O `security-reviewer` saiu de zero execuções? | grep nas linhas de dispatch e em `security-reviewer:` |
| — | **Meta:** esta absorção introduziu achado da MESMA classe (uma regra que depende de lembrar)? | a `/audit` de verificação sobre o commit desta absorção |

## Disposição devolvida ao projeto

O doc-fonte `framework-evolution-2026-09-16-mechanize-the-remembered.md` está agora
**dischargeable**: a próxima sessão do próprio projeto marca o cabeçalho como `upstreamed`, citando
este registro e o commit que o grava. Este repo não edita o doc do projeto (regra no-touch).
