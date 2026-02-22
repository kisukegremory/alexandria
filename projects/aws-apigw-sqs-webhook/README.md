# Webhook Proxy (API Gateway to SQS)

Este repositório contém um módulo Terraform desenhado para receber webhooks e enfileirá-los diretamente em uma fila SQS, sem a necessidade de processamento computacional intermediário (como AWS Lambda). É uma solução de baixo custo, alta latência e tolerante a falhas para ingestão de eventos de terceiros (ex: Stripe, GitHub, etc).

## 🏗️ Estrutura do Repositório

* `/modules/webhook_proxy`: Módulo principal reutilizável. Provisiona o API Gateway, a fila SQS, as roles do IAM com *least privilege* e, opcionalmente, chaves de API para autenticação.
* `/service_demo`: Implementação de exemplo consumindo o módulo. Focado em um webhook de *billing* (Stripe) rodando no ambiente `demo`.

## ⚙️ Arquitetura e Fluxo

1. O **API Gateway** recebe o payload HTTP POST (ex: `application/json`).
2. Uma **AWS Integration** transforma o request nativamente usando VTL (`$util.urlEncode($input.body)`) e despacha a ação `SendMessage` para a fila.
3. A mensagem fica disponível de forma assíncrona no **SQS** para ser consumida pelos workers do backend.

## 🚀 Como testar localmente (Intelligent Laziness)

Para evitar comandos longos e extração manual de outputs do Terraform, o diretório `service_demo` inclui um `Makefile` construído para gerenciar todo o ciclo de vida do laboratório.

*Certifique-se de ter o AWS CLI, Terraform e o `jq` instalados, e o profile configurado (o Makefile assume o profile `nina` por padrão).*

Acesse o diretório de demonstração:

```bash
cd service_demo

```

### 1. Provisionar a Infraestrutura

```bash
make init
make plan
make apply

```

### 2. Disparar o Webhook

Dispara um payload de teste. O Makefile extrai a URL e a API Key geradas diretamente do estado do Terraform:

```bash
make test

```

### 3. Validar o Enfileiramento

Para verificar se a mensagem chegou no SQS (sem deletá-la):

```bash
make receive

```

Para consumir a mensagem e confirmar o processamento (ACK / Delete):

```bash
make ack

```

### 4. Limpar o Ambiente

Para destruir todos os recursos e evitar custos ociosos:

```bash
make clean

```

## 🧩 Variáveis do Módulo (`modules/webhook_proxy`)

| Variável | Tipo | Descrição | Default |
| --- | --- | --- | --- |
| `service_name` | `string` | Nome base para os recursos do serviço. | **Obrigatório** |
| `endpoint_path` | `string` | Caminho do endpoint na URL (ex: `stripe-events`). | **Obrigatório** |
| `environment` | `string` | Ambiente de deploy (ex: `dev`, `prd`). | `"dev"` |
| `required_api_key` | `bool` | Se `true`, exige chave de API via header `x-api-key`. | `false` |

## 📦 Outputs do Módulo

* `invoke_url`: A URL pública completa para configurar no provedor do webhook.
* `api_key_value`: A chave gerada (se `required_api_key = true`). Sensível.
* `sqs_queue_url`: A URL da fila onde os payloads serão depositados.
