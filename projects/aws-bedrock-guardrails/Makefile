PROFILE = nina
REGION  = us-east-1
AWS     = aws --profile $(PROFILE) --region $(REGION)

TF = terraform -chdir=terraform

GUARDRAIL_ID      = $(shell $(TF) output -raw guardrail_id)
GUARDRAIL_VERSION = $(shell $(TF) output -raw guardrail_version)

.PHONY: apply destroy publish chat chat-draft test

apply:
	$(TF) apply

## Republica o guardrail após mudanças no DRAFT (taint + apply)
publish:
	$(TF) taint aws_bedrock_guardrail_version.v1
	$(TF) apply

destroy:
	$(TF) destroy

## Envia uma mensagem ao chatbot (versão publicada)
## Uso: make chat MSG="Qual a taxa de juros?"
## Uso com trace: make chat MSG="..." TRACE=--trace
TRACE ?=
chat:
	uv run chatbot.py $(GUARDRAIL_ID) $(GUARDRAIL_VERSION) "$(MSG)" $(TRACE)

## Testa contra o DRAFT atual (sem precisar publicar nova versão)
## Uso: make chat-draft MSG="..."
chat-draft:
	uv run chatbot.py $(GUARDRAIL_ID) DRAFT "$(MSG)" $(TRACE)

## Roda a bateria completa de testes adversariais
test:
	uv run test_cases.py $(GUARDRAIL_ID) $(GUARDRAIL_VERSION)
