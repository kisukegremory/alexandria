AGENT_ID       := $(shell cd terraform && terraform output -raw agent_id 2>/dev/null)
AGENT_ALIAS_ID := $(shell cd terraform && terraform output -raw agent_alias_id 2>/dev/null)
KB_ID          := $(shell cd terraform && terraform output -raw kb_id 2>/dev/null)
DATA_SOURCE_ID := $(shell cd terraform && terraform output -raw data_source_id 2>/dev/null)
DOCS_BUCKET    := $(shell cd terraform && terraform output -raw docs_bucket_name 2>/dev/null)
SESSION_ID     ?= $(shell python3 -c "import uuid; print(uuid.uuid4())")
MSG            ?= Preciso de ajuda com TI.

.PHONY: init apply destroy prepare publish upload-docs ingest ingest-status invoke test

init:
	cd terraform && terraform init

apply:
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy

# Required after apply and after any agent/action-group/KB change before invoking
prepare:
	aws bedrock-agent prepare-agent \
		--agent-id $(AGENT_ID) \
		--profile nina \
		--region us-east-1

# Taint the alias so Terraform re-creates it, which publishes a new agent version
publish:
	cd terraform && terraform taint aws_bedrockagent_agent_alias.live && terraform apply

upload-docs:
	aws s3 sync docs/ s3://$(DOCS_BUCKET)/ \
		--profile nina \
		--region us-east-1

ingest:
	aws bedrock-agent start-ingestion-job \
		--knowledge-base-id $(KB_ID) \
		--data-source-id $(DATA_SOURCE_ID) \
		--profile nina \
		--region us-east-1

ingest-status:
	aws bedrock-agent list-ingestion-jobs \
		--knowledge-base-id $(KB_ID) \
		--data-source-id $(DATA_SOURCE_ID) \
		--profile nina \
		--region us-east-1 \
		--query 'ingestionJobSummaries[0].{status:status,stats:statistics}' \
		--output table

invoke:
	AGENT_ID=$(AGENT_ID) AGENT_ALIAS_ID=$(AGENT_ALIAS_ID) \
		uv run python agent.py "$(MSG)"

# Persistent session for conversational testing
chat:
	AGENT_ID=$(AGENT_ID) AGENT_ALIAS_ID=$(AGENT_ALIAS_ID) SESSION_ID=$(SESSION_ID) \
		uv run python agent.py "$(MSG)"

test:
	AGENT_ID=$(AGENT_ID) AGENT_ALIAS_ID=$(AGENT_ALIAS_ID) \
		uv run pytest test_scenarios.py -v
