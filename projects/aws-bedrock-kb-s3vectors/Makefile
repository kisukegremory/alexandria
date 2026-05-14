
PROFILE   = nina
REGION    = us-east-1
AWS       = aws --profile $(PROFILE) --region $(REGION)

TF            = terraform -chdir=terraform

KB_ID         = $(shell $(TF) output -raw knowledge_base_id)
DS_ID         = $(shell $(TF) output -raw data_source_id)
DOCS_BUCKET   = $(shell $(TF) output -raw docs_bucket_name)

.PHONY: apply destroy upload sync ingest ingest-status query

apply:
	$(TF) apply

destroy:
	$(TF) destroy

## Envia um arquivo para o bucket de documentos
## Uso: make upload FILE=meu-doc.pdf
upload:
	$(AWS) s3 cp $(FILE) s3://$(DOCS_BUCKET)/

## Sincroniza uma pasta local com o bucket (só envia o que mudou)
## Uso: make sync DIR=/caminho/da/pasta
## Uso filtrando por extensão: make sync DIR=/caminho EXT=md
EXT ?= *
sync:
	$(AWS) s3 sync $(DIR) s3://$(DOCS_BUCKET)/ \
		--exclude "*" --include "*.$(EXT)" \
		--delete

## Dispara o job de ingestão (lê docs, gera embeddings, escreve vetores)
ingest:
	$(AWS) bedrock-agent start-ingestion-job \
		--knowledge-base-id $(KB_ID) \
		--data-source-id $(DS_ID)

## Verifica o status do último job de ingestão
## Uso: make ingest-status JOB_ID=<id retornado pelo ingest>
ingest-status:
	$(AWS) bedrock-agent get-ingestion-job \
		--knowledge-base-id $(KB_ID) \
		--data-source-id $(DS_ID) \
		--ingestion-job-id $(JOB_ID)

## Faz uma query na knowledge base via RAG
## Uso: make query Q="sua pergunta aqui"
## Uso com top-k customizado: make query Q="..." TOP_K=3
TOP_K ?= 5
query:
	uv run main.py $(KB_ID) "$(Q)" --top-k $(TOP_K)
