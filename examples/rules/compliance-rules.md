---
domain: compliance-lgpd-gdpr
applies_to: all modules that collect, store, process, or transmit personal data
---

# Compliance Rules (LGPD / GDPR)

## Scope

Aplica-se quando o sistema lida com **dados pessoais**: qualquer informação que identifica
ou pode identificar uma pessoa natural.

Exemplos que ativam este arquivo: nome, email, CPF, CNPJ, telefone, data de nascimento,
endereço, IP, dados de saúde, dados biométricos, localização, dados de cartão de pagamento.

Se o projeto não coleta nenhum dos acima: este arquivo não se aplica. Remova-o.

## Data Minimization

1. **Colete apenas o necessário** — cada campo tem uma finalidade documentada. Sem finalidade: não colete.
2. **Sem coleta especulativa** — "pode ser útil depois" não é justificativa válida.
3. **Dados sensíveis exigem base legal explícita** — saúde, biometria, origem racial/étnica, opiniões políticas, crenças religiosas, orientação sexual requerem base legal documentada no projeto.

## Consent Tracking

4. **Consentimento é específico e granular** — marketing, analytics, e compartilhamento com terceiros requerem sinais de consentimento separados.
5. **Consentimento registrado com timestamp e versão** — armazenar: `user_id`, `consent_type`, `granted_at`, `ip_address` (hash ou truncado), `consent_version`.
6. **Consentimento é revogável** — o sistema suporta revogação por tipo de consentimento independentemente. Revogar não pode exigir mais fricção que conceder.
7. **Processamento sem consentimento exige base legal** — interesse legítimo, contrato, ou obrigação legal: documentar no código e no inventário de dados do projeto.

## Right to Erasure (Deletion)

8. **Exclusão cobre todos os stores** — cascatear para: tabelas relacionadas, backups (purge agendado ou anonimização), processadores terceiros (email, analytics, error tracking), indexes de busca.
9. **Purge de backup tem SLA definido** — dados pessoais em backups devem ser purgados dentro de uma janela documentada (ex: 90 dias).
10. **Soft delete não é exclusão LGPD** — `deleted_at` timestamp não é suficiente. Hard-delete campos PII ou substituir por placeholders anonimizados (`[DELETED]`, UUID hash).
11. **Exclusão é auditada** — registrar que a exclusão foi solicitada e executada. O registro de auditoria NÃO deve conter o PII excluído — apenas user_id e timestamp.

## Data Portability

12. **Export cobre todos os dados pessoais** — incluir cada campo de dado pessoal em todas as tabelas.
13. **Formato machine-readable** — JSON ou CSV; não PDF.
14. **Export é autenticado e escopado** — usuário exporta apenas seus próprios dados; exports admin são audit-logged.

## Audit Trail

15. **Operações sensíveis geram audit log:**
    - Acesso a dados pessoais por staff/admin (quem acessou o quê, quando)
    - Alterações em campos PII (valor anterior → novo, quem, quando)
    - Solicitações de export e execução
    - Alterações de consentimento (concedido/revogado)
    - Solicitações e execução de exclusão de conta
16. **Audit log é append-only** — sem UPDATE/DELETE concedido ao app user na tabela de auditoria.
17. **Retenção de audit log** — mínimo 5 anos (janela de investigação administrativa LGPD).

## Data Retention Policies

18. **Período de retenção definido por categoria de dado:**

    | Categoria | Retenção | Base legal |
    |-----------|----------|-----------|
    | Dados de conta (usuário ativo) | Duração da conta + 6 meses | Contrato |
    | Dados de conta (usuário excluído, anonimizado) | Indefinido | Interesse legítimo (prevenção de fraude) |
    | Registros de transação | 5 anos | Obrigação legal (fiscal) |
    | Logs de consentimento | 5 anos após revogação | Obrigação legal (accountability LGPD) |
    | Logs de erro (com contexto de usuário) | 90 dias | Interesse legítimo |

19. **Purge ou anonimização automatizados** — política de retenção enforced por código (job agendado, TTL, database policy), não por processo manual.

## Data Processors

20. **Sub-processadores listados** — manter lista de serviços que recebem dados pessoais: error tracking, email delivery, analytics, payment processors, cloud providers. Cada um precisa de DPA.
21. **Mínimo de dados compartilhados** — não enviar campos desnecessários para terceiros. Ex: error tracking recebe user ID, não email ou CPF.
22. **Transferências internacionais documentadas** — se dados saem do Brasil (LGPD) ou do EEA (GDPR): mecanismo legal documentado.

## PCI-DSS Note (se aplicável)

Se o projeto lida com números de cartão brutos, CVV, ou tarja magnética:

- **Nunca armazenar CVV** — sob nenhuma circunstância, incluindo logs e error captures.
- **Números de cartão tokenizados** — usar serviço PCI-compliant (Stripe, Adyen, etc.); nunca armazenar PANs brutos.
- **PAN exibido mascarado** — mostrar apenas últimos 4 dígitos em UI e logs.

## Testing

```
QUERY: Após excluir conta, verificar todas as tabelas de dados pessoais.
  → SELECT * FROM [all personal data tables] WHERE user_id = [deleted_id]
  → Expected: 0 rows (hard delete) ou campos PII substituídos por valores anonimizados.
  FAILURE: email, CPF, ou telefone ainda presente em qualquer tabela.

VERIFY: Export de dados do usuário.
  → Trigger export para usuário A. Inspecionar arquivo gerado.
  → Expected: todas as tabelas com user_id = A representadas; formato JSON ou CSV.
  FAILURE: tabelas faltando, ou export retorna dados de outro usuário.

QUERY: Audit log de acesso admin a dados de usuário.
  → SELECT * FROM audit_log WHERE actor_role = 'admin' AND target_user_id = [id]
  → Expected: linha presente para cada evento de acesso admin.
  FAILURE: sem entrada de auditoria (acesso admin não logado).
```
