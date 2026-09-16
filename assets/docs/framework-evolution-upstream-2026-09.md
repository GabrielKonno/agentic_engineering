# Framework Upstream — absorção do lote "concorrência entre agentes do loop e escopo que muda depois do plano" (2026-09-15)

**Origem — doc absorvido (nome completo, conforme intake step 4; é o que o cross-check do Step 0
grepa):**
- `framework-evolution-2026-09-15-loop-concurrency-and-scope.md`

1 nota de evolução escrita por um projeto-fonte de perfil com caminhos de dinheiro, ao fim de uma
sessão de loop autônomo (Level 5) de 6 fases. Quatro evoluções de nível FRAMEWORK — duas graduadas
integralmente, uma ADAPTADA aos dois modos do loop, uma graduada como CONDICIONAL ao perfil
`production-financial`. Este doc registra O
QUE subiu, ONDE cada peça caiu, o que foi ADAPTADO e o que deliberadamente NÃO subiu. (Isolamento de
informação de projeto: o projeto é referido só por papel; o número da sessão-fonte, o hash de commit
do projeto e a sessão prevista da próxima auditoria dele foram removidos. Os números de caso da
sessão-fonte NÃO foram transcritos — nem aqui nem no template, que carrega só a forma geral — "mais
pontos de chamada", "uma rodada de mutação toda morta". Corrigido em 2026-09-16: a redação anterior
dizia que esses números "ficam só neste registro", e o registro nunca os conteve (`/audit` 2026-09-15 B-14).)

**Lotes anteriores desta linhagem:** `framework-base-upgrade.md` (2026-06-23),
`framework-evolution-upstream-2026-07.md` (2026-07-16) e `framework-evolution-upstream-2026-08.md`
(2026-08-31). O doc-irmão do lote de 2026-07 (lacunas de orquestração do loop) cobriu OUTRA classe de
concorrência — dois ESCRITORES no mesmo doc de fase — e não estas.

**A classe que une as quatro:** *o plano do loop assume que os recursos e o escopo são fixos no
momento da aprovação. Nenhum dos dois é.* O escopo muda quando alguém MEDE a task; os recursos colidem
quando dois agentes que o plano julgou independentes tocam a mesma coisa por um caminho que o plano
não enumerou.

**Força da evidência — registrada, não escondida:** cada lição foi observada em UMA sessão. O custo
de seguir cada regra é baixo, por isso subiram; o template as marca como HIPÓTESES e a tabela de
eficácia abaixo diz o que medir.

---

## 1. Um agente que ALTERA a árvore nunca roda em paralelo com um agente que a LÊ — ABSORVIDA INTEGRAL

**A classe:** a regra de contenção perguntava "dois agentes ESCREVEM o mesmo arquivo?". A pergunta
que faltava é "um agente ESCREVE o que o outro LÊ?". Enquanto um mutante está no disco, a árvore está
sabotada para todo leitor, e um veredito emitido nessa janela é sobre código que não existe — com
cara de legítimo.

| Peça | Destino no framework | Adaptação |
|---|---|---|
| A regra (mutador × leitor; ordem leitores → mutadores → `git status`/`git diff`) | `docs/modules/skills/autonomous-loop/SKILL.md` → "Resource contention" | Generalizada de "validador com mutation-check × revisor" para qualquer MUTADOR (fixer, formatter, script de edição em massa) e qualquer LEITOR (revisor, red-team, verificador de integridade) |
| A "regra mínima prática" da mesma seção | idem | Passa a exigir também que o trabalho paralelizado não MUTE nada que outro agente lê |
| Captura da lição no relatório | "Final report" → `Orchestration lessons` | Colisões mutador/leitor citadas como tipo de lição |

## 2. O SCRATCHPAD é um recurso compartilhado entre subagentes — ABSORVIDA INTEGRAL

**A classe:** o mapa de recursos só enumerava arquivos do repositório, o ambiente de teste e os docs
de fase. Um recurso fora do mapa não é declarado, e um recurso não declarado é exatamente onde duas
escritas colidem — aqui com perda silenciosa de um controle de segurança (uma trava de só-leitura num
script de consulta), que nenhum teste pega porque o script "funciona".

| Peça | Destino no framework | Adaptação |
|---|---|---|
| Scratchpad no mapa; nomes próprios por subagente; travas re-verificadas antes de reusar um helper | `autonomous-loop/SKILL.md` → "Resource contention" | Escrita como três ALWAYS dedicados (scratchpad no mapa; nomes próprios por subagente; travas re-verificadas) — corrigido de "dois" em 2026-09-16 (`/audit` 2026-09-15 B-13) |
| Declaração de recursos no prompt do implementador | `autonomous-loop/SKILL.md` → Step 3b "Resource declaration" | `scratchpad files` acrescentado à lista declarada |

## 3. Quando o criteria-enforcer muda o ESCOPO, o corte de fases é revisado antes de delegar — ABSORVIDA (adaptada ao modo contínuo)

**A classe:** o template mandava rodar o criteria-enforcer antes de delegar e só registrava "N
critérios fortalecidos". Quando o enforcer MEDE a task e ela cresce (mais pontos de chamada, uma
escrita irmã de pior consequência), o corte de fases aprovado foi calculado sobre o escopo ANTIGO.

| Peça | Destino no framework | Adaptação |
|---|---|---|
| Re-checar o plano; colisão → re-corte; task virou GRANDE → sai | `autonomous-loop/SKILL.md` → Step 3a | ADAPTADA aos dois modos: no SEGMENTO, re-checar o corte de fases (Step 1b) — colisão re-corta, task grande é **STOP e re-propor** (remover task muda O QUE está no segmento, fora de "Bounded re-sequencing authority"); no CONTÍNUO não há corte de fases (C1 substitui o Step 1) — re-aplicar a admissão (C1, C3) e **HOLD**. A redação literal do doc-fonte contradiria a seção de re-sequenciamento e o modo contínuo |
| Linha de relatório `scope: …` | Step 3a (mandato) + slots `### Scope changes (Step 3a)` no "Final report" (segmento) e no digest do checkpoint contínuo (C5) | Enumeração de cada slot COPIADA do ramo do mandato do seu modo — segmento `unchanged / re-sequenced / stopped`, contínuo `unchanged / held` |

## 4. Revisores de caminho de dinheiro são COMPLEMENTARES — ABSORVIDA CONDICIONAL (`production-financial`)

**A classe:** a geometria de validação já é fixada pelo risco e o perfil `production-financial` já
torna o red-team obrigatório em caminhos de dinheiro. Faltava dizer que um APPROVE (ou uma rodada de
mutação toda morta) não dispensa os outros revisores — a tentação real num loop é encurtar a cadeia
depois de um veredito verde.

| Peça | Destino no framework | Adaptação |
|---|---|---|
| NEVER pular um revisor citando o APPROVE de outro ou a nota de mutação | `autonomous-loop/SKILL.md` → Step 3d "Validation geometry" | Condicional ao perfil; o verificador de integridade de dados entra "quando instalado" (é especialista de exemplo, instalado só se o gap foi mantido) |

---

## Deliberadamente NÃO absorvido

- **Os detalhes do domínio do projeto-fonte** (a natureza da escrita compensatória, do ponteiro para
  a linha de receita, do fluxo de "desfazer") — ficaram só como a CLASSE de defeito que cada revisor
  achou.
- **O identificador de sessão, o hash de commit e a sessão prevista da auditoria do projeto** —
  removidos; não são portáveis e identificam o projeto.
- **Nenhuma regra foi rejeitada.** A evidência de uma sessão foi registrada como hipótese (nota no
  template e tabela abaixo), não como motivo para adiar.

## Âncoras de eficácia — o que MEDIR, e quem mede

**Quem mede (acrescentado em 2026-09-16 — a versão original dizia só "a próxima auditoria", sem
dono; `/audit` 2026-09-15 B-11):**
- **Perguntas 1-2:** a `framework-audit` de cada projeto que roda o loop, Q4 → HYPOTHESIS check, que
  conta as linhas tipadas `- mutator/reader overlap:` e `- scratchpad collision:` que o
  `session-log-creator` grava em `## Orchestration lessons`. Ela existe só em `production`+; o
  projeto-fonte (perfil com caminhos de dinheiro) a tem. **Abaixo de `production`, estas perguntas
  ficam `unmeasured — no measurer at prototype / internal-tool`.** A segunda metade da pergunta 2 (os
  prompts de dispatch declaram arquivos de scratchpad?) fica `unmeasured — no measurer at any tier`:
  o check conta colisões, não declarações.
- **Pergunta 3:** `unmeasured — no measurer at any tier`. A regra de escopo do Step 3a é contrato, não
  hipótese, e nenhuma pergunta da `framework-audit` conta linhas `scope:`.
- **Pergunta 4:** a mesma skill, Q4 aspirational-vs-real, só em projetos `production-financial`.
- **Meta:** a `/audit` de verificação deste repo sobre o commit da absorção — executada em 2026-09-15
  Run 3, que achou B-11 e B-12.

Nenhuma pergunta se responde relendo este doc. Uma janela com ZERO ocorrências das perguntas 1-3 é
"regra não exercida", nunca "eficácia confirmada".

| # | Pergunta | Como responder |
|---|---|---|
| 1 | Algum loop rodou um agente que altera a árvore em paralelo com um revisor? Algum veredito foi descartado ou re-derivado por ter lido um mutante? | grep em `Orchestration lessons` dos relatórios finais e dos digests de checkpoint dos projetos que rodam o loop |
| 2 | Algum log registra colisão de arquivo de scratchpad entre subagentes? Os prompts de subagente declaram arquivos de scratchpad? | grep `scratchpad` nas `Orchestration lessons` e nos prompts de dispatch registrados |
| 3 | Quantas linhas `scope: widened` aparecem? Em quantas o corte foi re-sequenciado, e alguma task virou grande (`stopped` / `held`)? | grep `scope: widened` e `### Scope changes` nos relatórios de loop |
| 4 | Em tasks de caminho de dinheiro de projetos `production-financial`, a cadeia completa rodou em todas? Algum log justifica pular um revisor citando outro? | grep dos relatórios de validação dessas tasks pelas três assinaturas de revisor |
| — | **Meta:** esta absorção introduziu achado da MESMA classe (um escopo ou recurso que o plano não enumera)? | a `/audit` de verificação sobre o commit desta absorção |

## Disposição devolvida ao projeto

O doc-fonte `framework-evolution-2026-09-15-loop-concurrency-and-scope.md` está agora
**dischargeable**: a próxima sessão do próprio projeto marca o cabeçalho como `upstreamed`, citando
este registro e o commit que o grava. Este repo não edita o doc do projeto (regra no-touch).
