.PHONY: build infra-init infra-up test-401 test-200 scan-db clean

export AWS_PROFILE=nina
export AWS_REGION=us-east-1
TF_DIR = terraform
ARTIFACTS_DIR = artifacts

build:
	@echo "=> Preparando diretório de artefatos..."
	@mkdir -p $(ARTIFACTS_DIR)
	@echo "=> Compilando Golang (arm64)..."
	cd src/authorizer && GOOS=linux GOARCH=arm64 go build -tags lambda.norpc -o ../../$(ARTIFACTS_DIR)/bootstrap main.go

infra-init:
	cd $(TF_DIR) && terraform init

infra-up: build
	@echo "=> Aplicando infraestrutura com o binário Go..."
	cd $(TF_DIR) && terraform apply -auto-approve

test-401:
	@echo "=> Testando endpoint com token INVÁLIDO (Esperando 401)..."
	$(eval API_URL := $(shell cd $(TF_DIR) && terraform output -raw api_url))
	@curl -s -i -X POST $(API_URL) \
		-H "Authorization: Bearer fake-token" \
		-H "Content-Type: application/json" \
		-d '{"id": "123", "event_type": "teste", "payload": { "chave": "valor" }}'

test-200:
	@echo "=> Testando endpoint com token VÁLIDO (Esperando 200 + Gravação no Dynamo)..."
	$(eval API_URL := $(shell cd $(TF_DIR) && terraform output -raw api_url))
	@curl -s -i -X POST $(API_URL) \
		-H "Authorization: Bearer alexandria-secret" \
		-H "Content-Type: application/json" \
		-d '{"id": "777", "event_type": "compra_aprovada", "payload": { "item": "teclado" }}'

scan-db:
	@echo "=> Inspecionando os dados ingeridos no DynamoDB..."
	@aws dynamodb scan \
		--table-name aws-apigw-dump-example-table \
		--query "Items[*].{ID:id.S, EventType:event_type.S, CreatedAt:created_at.S, Payload:payload.S}" \
		--output table

clean:
	@echo "=> Destruindo infraestrutura e limpando artefatos..."
	cd $(TF_DIR) && terraform destroy -auto-approve
	rm -rf $(ARTIFACTS_DIR)