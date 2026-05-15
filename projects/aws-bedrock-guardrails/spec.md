# Bedrock Guardrails — Credix Chatbot

Projeto de estudo hands-on para o AIF-C01.
Gap coberto: Bedrock Guardrails (content filtering, topic denial, PII redaction) + Responsible AI.

## Contexto simulado

**Credix** — fintech fictícia de crédito consignado privado com perfil de compliance similar à Volpi:
LGPD, BACEN, restrições de divulgação de dados de clientes.

## Arquitetura

```
Usuário → InvokeModel (Nova Lite)
               ↓
        Guardrail (input check)
               ↓ bloqueado? → blocked_input_messaging
               ↓ ok
          Modelo LLM
               ↓
        Guardrail (output check)
               ↓ bloqueado? → blocked_outputs_messaging
               ↓ ok
          Resposta ao usuário
```

## Políticas configuradas

| Política | Tipo | Configuração |
|----------|------|-------------|
| Content filters | HATE, INSULTS, VIOLENCE, MISCONDUCT | HIGH input + output |
| Content filters | PROMPT_ATTACK | HIGH input only |
| Topic denial | concorrentes | Creditas, QITech, Nubank, bancos |
| Topic denial | assessoria_juridica | Aconselhamento legal |
| Topic denial | credito_fora_fluxo | Aprovação imediata sem fluxo |
| PII redaction | EMAIL, PHONE, NAME | ANONYMIZE |
| PII redaction | CPF (regex) | ANONYMIZE |
| PII redaction | Conta bancária (regex) | ANONYMIZE |
| Word filter | PROFANITY | Managed list |

## Descobertas

### Content filter classifier tem viés de idioma (inglês)

Os datasets de fine-tuning dos content filters (Jigsaw Toxic Comments, HatEval, TweetEval) são predominantemente em inglês. Na prática:

- `"fuck you credix"` → BLOQUEADO (classifier viu isso milhares de vezes com label INSULTS)
- `"vá se foder credix"` → PERMITIDO pelo guardrail (confidence baixa em PT-BR)
- O managed word list de PROFANITY tem o mesmo problema — lista curada em inglês

**Fix:** `words_config` no `word_policy_config` — string matching determinístico, bypassa o classifier completamente. Não depende de idioma. Adicionadas palavras PT-BR na lista.

**Lição:** para aplicações em português, o word filter customizado é obrigatório como complemento ao content filter.

### Defesa em profundidade: guardrail + RLHF do modelo

`"vá se foder credix"` foi PERMITIDO pelo guardrail mas o modelo (Nova Lite) se recusou por conta própria. O RLHF do modelo age como segunda camada. Em produção, não depender disso — a segunda camada pode variar entre modelos e versões.

### PII ANONYMIZE expõe o placeholder na resposta do modelo

`"quem é nina?"` → guardrail anonimizou "nina" → `{NAME}` antes de enviar ao modelo. O modelo respondeu citando o placeholder literalmente: _"não posso fornecer informações sobre '{NAME}'"_. Comportamento correto tecnicamente, mas esteticamente estranho para o usuário final. Mitigação possível: instruir no system prompt a não citar placeholders de PII.

### Word filter é exact match — não tem morfologia

`"foder"` está na lista mas `"foda"`, `"fodendo"`, `"fodido"` são formas flexionadas distintas — não são capturadas. Português tem morfologia verbal rica demais para cobrir por enumeração. Opções reais:
- Regex no PII config: `fod[ae]` cobre formas básicas (mas regex em word filter não existe, só no PII)
- Completar o word list com as formas mais comuns manualmente
- Aceitar que o content classifier (quando melhorar cobertura PT-BR) é a camada correta para isso

Palavras com diacríticos (`cuzão`) funcionam normalmente no word filter.

### Word filter bloqueia o texto inteiro, não trecho isolado

Input misto — profanidade + conteúdo legítimo na mesma mensagem — é bloqueado por inteiro. O guardrail não tenta separar a parte "boa" da "ruim". Uma violação no texto = mensagem inteira bloqueada com `blocked_input_messaging`.

### PROMPT_ATTACK não tem output_strength

`PROMPT_ATTACK` é uma ameaça de entrada — só faz sentido no input. Se passar `output_strength != "NONE"` o provider rejeita com erro. A configuração correta é `output_strength = "NONE"`.

### PII ANONYMIZE ≠ BLOCK

Quando action é `ANONYMIZE`, o guardrail mascara o dado (ex: `123.456.789-00` → `[REDACTED]`) mas **não interrompe** o fluxo. O modelo recebe o input com o PII substituído e responde normalmente. O `stopReason` NÃO será `guardrail_intervened` — a conversa flui, mas sem o dado real. Útil para LGPD sem degradar a experiência.

### stopReason como sinal de bloqueio

O campo `stopReason` no response body é o indicador mais confiável:
- `"guardrail_intervened"` → input ou output bloqueado, resposta é o `blocked_*_messaging`
- `"end_turn"` → resposta normal do modelo

O campo `amazon-bedrock-guardrailAction` (disponível com `trace="ENABLED"`) detalha qual política disparou.

### ANONYMIZE e BLOCK ambos setam guardrailAction = "INTERVENED"

`amazon-bedrock-guardrailAction = "INTERVENED"` é setado para qualquer intervenção do guardrail — inclusive ANONYMIZE (mascaramento de PII). Para distinguir bloqueio real de mascaramento:

- **BLOCK**: o texto da resposta é exatamente `blocked_input_messaging` ou `blocked_outputs_messaging`
- **ANONYMIZE**: o texto é a resposta real do modelo com PII substituído por placeholder

O campo `actionReason` em `amazon-bedrock-trace.guardrail` também indica a diferença (`"No action.\nGuardrail masked."` para ANONYMIZE), mas só existe quando `trace="ENABLED"`. Checar o texto é mais confiável e funciona sem trace.

```python
BLOCKED_MESSAGES = frozenset([
    "Desculpe, essa solicitação não é permitida pela nossa política de uso.",
    "Desculpe, não posso fornecer essa informação.",
])
intervened = stop_reason == "guardrail_intervened" or (action == "INTERVENED" and text in BLOCKED_MESSAGES)
```

Nota: o campo de trace no response body é `"amazon-bedrock-trace"`, não `"amazon-bedrock-guardrailTrace"`.

### Topic denial com definição ampla gera falsos positivos

Definição que menciona "crédito" de forma genérica pode capturar perguntas informativas legítimas ("Quais são os produtos de crédito?"). A definição precisa ser explicitamente restritiva — incluindo o que **não** está no escopo do tópico negado. Exemplo: "Não inclui perguntas sobre como funciona o crédito ou quais são os produtos disponíveis."

### stopReason não é o único indicador de bloqueio no Nova

Content filters e word filter retornam `stopReason = "guardrail_intervened"`. Topic denial no Nova pode retornar `stopReason = "end_turn"` mesmo quando bloqueado — o texto da resposta já é o `blocked_input_messaging`, mas o campo de stop reason não reflete isso.

O indicador correto e consistente é `amazon-bedrock-guardrailAction` no response body:
- `"INTERVENED"` → guardrail bloqueou (qualquer política)
- `"NONE"` → passou sem intervenção

Código correto:
```python
action     = body.get("amazon-bedrock-guardrailAction", "NONE")
intervened = body.get("stopReason") == "guardrail_intervened" or action == "INTERVENED"
```

### Grounding check requer fonte

`grounding_policy_config` exige que o prompt contenha um contexto de referência explícito (via `grounding source`). Sem uma Knowledge Base ou contexto injetado no prompt, o guardrail não tem base para comparar e rejeita a configuração. Aplicável no projeto de Agent (quando KB for anexada).
