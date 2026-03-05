.PHONY: build clean deploy destroy plan

# Configurações de Build para AWS Lambda (Graviton/AL2023)
# CGO_ENABLED=0 é crucial para binários estáticos no Alpine/Amazon Linux
GOOS=linux
GOARCH=arm64
CGO_ENABLED=0

# Garante que a pasta artifacts exista
ensure-artifacts-dir:
	@mkdir -p artifacts/authorizer
	@mkdir -p artifacts/worker

build: ensure-artifacts-dir
	@echo "🔥 Building binaries for provided.al2023 (arm64)..."
	
	# --- Authorizer ---
	@env GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=$(CGO_ENABLED) \
		go build -ldflags="-s -w" -o artifacts/authorizer/bootstrap src/authorizer/main.go
	# Zipando com caminho relativo para não criar pastas desnecessárias dentro do zip
	@cd artifacts/authorizer && zip -q -r ../authorizer.zip bootstrap
	
	# --- Worker ---
	@env GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=$(CGO_ENABLED) \
		go build -ldflags="-s -w" -o artifacts/worker/bootstrap src/worker/main.go
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