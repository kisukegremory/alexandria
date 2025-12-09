# Serverless Interaction API (Go + App Runner)

Este projeto é uma Proof of Concept (PoC) de uma arquitetura *serverless-first* voltada a eventos. Ele demonstra a criação de uma API em **Go** altamente otimizada, hospedada no **AWS App Runner**, que atua como produtora de mensagens para uma fila **SQS**, com infraestrutura totalmente gerenciada via **Terraform**.

## Architecture Flow

```mermaid
graph LR
    User[Client] -- HTTPS POST /movies --> AppRunner[AWS App Runner Service]
    subgraph "AWS Infrastructure"
        ECR[Amazon ECR] -- Docker Image --> AppRunner
        AppRunner -- IAM Role (Assume) --> SQS[Amazon SQS]
        Terraform[Terraform State] -.-> AppRunner
        Terraform -.-> SQS
        Terraform -.-> ECR
    end
````

## 🧠 Index of Knowledge & Patterns (Engenharia)

Este repositório implementa os seguintes conceitos técnicos e padrões de design, servindo como referência de estudo:

### 1\. Golang & Otimização

  * **SDK v2 AWS:** Utilização do `github.com/aws/aws-sdk-go-v2` para interação nativa com serviços (SQS), mais performática que a v1.
  * **Struct Validation:** Uso de tags e `go-playground/validator` para garantir a integridade do payload JSON antes do processamento, falhando rápido (fail-fast).
  * **Dependency Injection (Simplificada):** O cliente SQS é inicializado no startup (`main`) e reutilizado, evitando o overhead de abrir novas conexões SSL por request.

### 2\. Docker & Container Engineering

  * **Multi-Stage Build:** Separação do estágio de compilação (`golang:alpine`) do estágio de execução.
  * **Distroless/Scratch Image:** O container final roda `FROM scratch` (vazio), contendo apenas o binário estático e certificados.
      * *Benefício:* Imagem final minúscula (\< 15MB) e superfície de ataque reduzida a zero (sem shell, sem package manager).
  * **SSL Certificates Hack:** Cópia manual de `/etc/ssl/certs/ca-certificates.crt` do builder para o scratch. Isso é crucial para permitir que o binário Go faça chamadas HTTPS para a API da AWS.

### 3\. AWS & Terraform (IaC)

  * **App Runner:** Abstração moderna de container serverless (PaaS), eliminando a necessidade de gerenciar clusters ECS ou Kubernetes.
  * **IAM Least Privilege:**
      * `build-role`: Permissão estrita para o App Runner puxar imagens do ECR.
      * `task-role`: Permissão estrita para a aplicação enviar mensagens apenas para a fila SQS específica (scopado pelo ARN).
  * **ECR Lifecycle Policies:** Regra automatizada no Terraform (`ecr.tf`) para manter apenas as últimas 3 imagens, otimizando custos de armazenamento.
  * **Remote State:** Backend configurado no S3 (`alexandria-terraform-tfstates`) com criptografia e travamento de estado.

-----

## 🛠️ Stack Tecnológica

  * **Linguagem:** Go 1.25.4
  * **Infraestrutura:** Terraform \~\> 6.0
  * **Cloud:** AWS (App Runner, ECR, SQS, IAM)
  * **Container:** Docker

-----

## 🚀 Setup & Execução

### Pré-requisitos

  * Go 1.25+
  * Terraform
  * AWS CLI configurado
  * Docker

### 1\. Infraestrutura (Terraform)

Provisione os recursos na AWS antes de rodar a aplicação para gerar as URLs necessárias (ECR e SQS).

```bash
cd terraform/bootstrap
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

*Isso criará o repositório ECR, a Fila SQS e o Serviço App Runner.*

### 2\. Build & Deploy (Docker)

O projeto utiliza um `Makefile` para facilitar o push da imagem para o ECR.

> **Nota:** Certifique-se de estar logado na AWS CLI. Verifique se o ID da conta no Makefile corresponde à sua conta AWS.

```bash
cd api
make push
```

*O App Runner está configurado com `auto_deployments_enabled = true`. Assim que a imagem nova chegar no ECR, o deploy iniciará automaticamente.*

### 3\. Execução Local (Docker Compose)

Para testar a integração localmente sem subir no App Runner, injetando as credenciais da AWS da sua máquina host:

```bash
# 1. Crie um .env com a URL da fila criada pelo Terraform
echo "QUEUE_URL=$(aws sqs get-queue-url --queue-name serverless-interaction-api-queue --output text)" > .env
echo "AWS_PROFILE=default" >> .env

# 2. Suba o ambiente
docker-compose up --build
```

-----

## 📡 API Reference

### Create Movie

Envia um filme para processamento na fila SQS.

**Endpoint:** `POST /movies`

**Payload:**

```json
{
  "name": "Dr. Stone",
  "imdb": 9
}
```

**Exemplo via cURL:**

```bash
curl -X POST http://localhost:8080/movies \
  -H "Content-Type: application/json" \
  -d '{"name": "Overlord", "imdb": 10}'
```

-----

## 📂 Estrutura do Projeto

```
.
├── api/                  # Código Fonte Go e Dockerfile
│   ├── main.go           # Handler da API e lógica SQS
│   └── Makefile          # Automação de Build/Push ECR
├── terraform/            # Infraestrutura como Código
│   └── bootstrap/        # Definição de recursos AWS (AppRunner, IAM, SQS)
├── docker-compose.yml    # Ambiente local
└── run.sh                # Script utilitário para execução rápida local
```
