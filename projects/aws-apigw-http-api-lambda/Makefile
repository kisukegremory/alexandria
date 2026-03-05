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

	# --- Worker ---
	@cd src/worker && \
	GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=$(CGO_ENABLED) \
	go build -tags lambda.norpc -ldflags="-s -w" \
	-o ../../artifacts/worker/bootstrap main.go
	
	# Zipando (precisa entrar na pasta artifacts para o bootstrap ficar na raiz do zip)
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