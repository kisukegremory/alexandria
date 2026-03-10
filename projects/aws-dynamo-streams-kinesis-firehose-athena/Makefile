# Variáveis
TF_DIR=terraform
APP_DIR=apps
AWS_PROFILE=nina
AWS_REGION=us-east-1

.PHONY: help init plan apply destroy seed check-s3 check-errors clean

help: ## Mostra os comandos disponíveis
	@echo "🛠️ Comandos disponíveis para o projeto DynamoDB -> Firehose -> S3:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ==============================================================================
# COMANDOS DE INFRAESTRUTURA (TERRAFORM)
# ==============================================================================
init: ## Inicializa o Terraform
	@echo "📦 Inicializando Terraform..."
	cd $(TF_DIR) && terraform init

plan: ## Roda o Terraform Plan
	@echo "🔍 Planejando infraestrutura..."
	cd $(TF_DIR) && terraform plan

apply: ## Roda o Terraform Apply (com auto-approve)
	@echo "🚀 Aplicando infraestrutura..."
	cd $(TF_DIR) && terraform apply -auto-approve

destroy: ## Destrói toda a infraestrutura (com auto-approve)
	@echo "💥 Destruindo infraestrutura..."
	cd $(TF_DIR) && terraform destroy -auto-approve

# ==============================================================================
# COMANDOS DA APLICAÇÃO (PYTHON)
# ==============================================================================
seed: ## Roda o script de carga de dados para o DynamoDB
	@echo "🌱 Injetando dados no DynamoDB..."
	cd $(APP_DIR) && uv run python main.py

# ==============================================================================
# COMANDOS DE OBSERVAÇÃO (AWS CLI)
# ==============================================================================
# Pega o nome do bucket criado pelo Terraform dinamicamente
BUCKET_NAME = $(shell cd $(TF_DIR) && terraform output -raw bucket_name 2>/dev/null || echo "BucketNaoEncontrado")

check-s3: ## Lista os arquivos de dados (.parquet) gerados no Data Lake
	@echo "🔎 Buscando arquivos Parquet no S3..."
	@aws s3 ls s3://$(BUCKET_NAME)/users_events/ --recursive --profile $(AWS_PROFILE) --region $(AWS_REGION) || echo "Ainda não há arquivos ou ocorreu um erro."

check-errors: ## Lista os arquivos de erro no Data Lake (se a conversão falhar)
	@echo "🚨 Checando se há arquivos de erro de conversão JSON/Parquet..."
	@aws s3 ls s3://$(BUCKET_NAME)/errors/ --recursive --profile $(AWS_PROFILE) --region $(AWS_REGION) || echo "Nenhum erro encontrado!"

clean: ## Remove arquivos locais do Terraform e cache do Python
	@echo "🧹 Limpando arquivos locais..."
	rm -rf $(TF_DIR)/.terraform $(TF_DIR)/.terraform.lock.hcl $(TF_DIR)/terraform.tfstate*
	find $(APP_DIR) -type d -name "__pycache__" -exec rm -r {} +