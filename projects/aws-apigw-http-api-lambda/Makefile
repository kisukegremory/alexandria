.PHONY: build clean deploy destroy plan test

# Configurações de Build
GOOS=linux
GOARCH=arm64
CGO_ENABLED=0

# Garante que a pasta artifacts exista
ensure-artifacts-dir:
	@mkdir -p artifacts/worker

build: ensure-artifacts-dir
	@echo "🔥 Building Worker (Monorepo Mode)..."

	# --- Worker ---
	@cd src/worker && \
	GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=$(CGO_ENABLED) \
	go build -tags lambda.norpc -ldflags="-s -w" \
	-o ../../artifacts/worker/bootstrap main.go
	
	@cd artifacts/worker && zip -q -r ../worker.zip bootstrap
	
	@echo "✅ Build complete! Artifacts ready in /artifacts"

clean:
	@rm -rf artifacts

# Atalhos para Terraform
init:
	@cd terraform && terraform init

plan: build
	@cd terraform && terraform plan

deploy: build
	@cd terraform && terraform apply -auto-approve

destroy:
	@cd terraform && terraform destroy -auto-approve

# --- NOVO TARGET DE TESTE ---
test:
	@echo "🚀 Getting API Endpoint from Terraform..."
	@# O comando abaixo roda tudo em um único sub-shell para manter a var URL viva
	@URL=$$(cd terraform && terraform output -raw api_endpoint); \
	if [ -z "$$URL" ]; then \
		echo "❌ Error: Terraform output 'api_endpoint' not found. Did you run 'make deploy'?"; \
		exit 1; \
	fi; \
	echo "📡 Sending POST request to: $$URL/ingest"; \
	echo "📦 Payload: {\"message\": \"Hello from Makefile\"}"; \
	echo "---------------------------------------------------"; \
	curl -s -X POST "$$URL/ingest" \
		-H "Content-Type: application/json" \
		-d '{"message": "Hello from Makefile"}' | jq . || echo "(Instale 'jq' para ver o JSON formatado)"