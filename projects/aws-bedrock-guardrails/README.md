# aws-bedrock-guardrails

Chatbot de suporte da **Credix** (fintech fictícia) com Bedrock Guardrails — content filtering, topic denial e PII redaction.

Projeto de estudo para o AIF-C01. Detalhes de descobertas em [`spec.md`](spec.md).

## Setup

```bash
# Provisionar o guardrail
make apply

# Testar uma mensagem
make chat MSG="Como funciona o crédito consignado?"

# Ver trace completo do guardrail
make chat MSG="Qual a taxa do Nubank?" TRACE=--trace

# Rodar bateria de testes adversariais
make test

# Destruir
make destroy
```

---

## Como o Guardrail funciona

Guardrails não é um LLM — é uma camada de modelos de ML especializados que envolve qualquer modelo do Bedrock.

```
Input do usuário
      ↓
Guardrail (avaliação de entrada)
      ├── bloqueado → blocked_input_messaging   ← modelo NÃO é chamado
      └── ok
            ↓
       Nova Lite (ou qualquer modelo)
            ↓
       Guardrail (avaliação de saída)
            ├── bloqueado → blocked_outputs_messaging
            └── ok → resposta ao usuário
```

Se o input for bloqueado, o modelo nunca é invocado — você paga só pelo guardrail.

---

## Políticas configuradas neste projeto

### Content Filters

**Modelo:** classificador transformer (BERT-like) fine-tuned em datasets de conteúdo tóxico. Um único forward pass gera scores independentes para cada categoria.

```
texto → tokenizer (WordPiece/BPE) → token IDs → embedding matrix lookup → vetores iniciais
  → positional encoding → transformer encoder layers → vetor [CLS] → classification head → score [0.0, 1.0]
```
Tokenização converte texto em IDs inteiros — nenhum vetor ainda. O embedding é o passo seguinte (matrix lookup), primeiro passo aprendido do modelo.

`LOW / MEDIUM / HIGH` definem o ponto de corte no score de confiança:
- `HIGH` = corte baixo (~30%) → bloqueia casos borderline → mais falsos positivos
- `LOW`  = corte alto (~80%) → só bloqueia o óbvio → menos falsos positivos

`PROMPT_ATTACK` só tem `input_strength` — é um classificador de intenção de entrada (jailbreak, injection). Aplicar no output não faz sentido.

Políticas ativas: `HATE · INSULTS · VIOLENCE · MISCONDUCT · PROMPT_ATTACK` — todas em `HIGH`.

### Topic Denial

**Modelo:** embedding semântico + similaridade de cosseno. Não é um classificador.

```
definition + examples → embedding → centroide vetorial do tópico
texto do usuário      → embedding → cosine similarity → threshold → bloqueia
```

O threshold de similaridade **não é configurável** na API — você influencia indiretamente pela qualidade da `definition` e dos `examples`. Definitions específicas geram centroides estreitos (menos falsos positivos). Examples genéricos alargam o centroide.

Tópicos negados: **concorrentes** (Creditas, QITech, Nubank) · **assessoria jurídica** · **crédito fora do fluxo**.

### PII — Named Entity Recognition (NER)

**Modelo:** transformer com classificação por token (sequence labeling). Diferente do classificador de texto inteiro, o NER classifica cada token individualmente para localizar exatamente onde está o dado sensível.

Esquema BIO:
```
"Meu email é joao@gmail.com e CPF 123.456.789-00"
  O    O    O  B-EMAIL       O  O  B-CPF       I-CPF
```
Spans consecutivos `B + I` = uma entidade. O modelo sabe exatamente quais caracteres mascarar.

Ação `ANONYMIZE`: substitui por placeholder (`[EMAIL]`, `[REDACTED]`). O LLM recebe o input mascarado e responde normalmente — `stopReason` não será `guardrail_intervened`. Ideal para LGPD: preserva a experiência sem transmitir o dado real ao modelo.

Entidades cobertas: `EMAIL · PHONE · NAME` via NER, `CPF · conta bancária` via regex.

### Regex

Pattern matching determinístico — zero ML. Útil para entidades locais que o NER não cobre nativamente (CPF, conta bancária no formato brasileiro).

### Word Filter

String matching exato. Lista gerenciada pela AWS para `PROFANITY`.

---

## Sinal de bloqueio no código

```python
body        = json.loads(response["body"].read())
stop_reason = body.get("stopReason", "")
intervened  = stop_reason == "guardrail_intervened"
```

Com `trace="ENABLED"`, o campo `amazon-bedrock-guardrailTrace` no response body detalha qual política disparou.
