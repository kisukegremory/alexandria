# AWS API Gateway Direct DynamoDB + Lambda Auth

Este projeto é um template pragmático ("Golden Path") para uma esteira de ingestão de dados serverless. Ele utiliza a integração direta do API Gateway com o DynamoDB para zerar custos de computação intermediária, protegido por um Custom Authorizer de altíssima performance escrito em Golang.



## 🏗️ Decisões Arquiteturais e Aprendizados (Design Document)

Este repositório foi construído contornando várias "armadilhas" clássicas da AWS e do Terraform. Abaixo estão as decisões técnicas que fundamentam a infraestrutura:

### 1. Integração Direta (API GW -> DynamoDB) e o Hack do VTL
Para focar em "preguiça inteligente" e economia, removemos o clássico Lambda Worker que faria o *insert* no banco. O API Gateway faz o `PutItem` direto usando **VTL (Velocity Template Language)**.
* **A Armadilha do 200 OK Falso:** O DynamoDB exige o tipo String (`"S"`) nativamente. Se passarmos um objeto JSON cru via `$input.json()`, o DynamoDB rejeita com `SerializationException`, mas o API Gateway masca o erro e retorna HTTP 200.
* **A Solução:** Utilizamos o método nativo `$util.escapeJavaScript($input.json('$.payload'))` no VTL do Terraform. Isso converte o payload em uma string JSON validamente escapada, permitindo que o DynamoDB grave o dado de forma íntegra.
* **Timestamp na Fonte:** Injetamos a data de criação no *backend* usando a variável de contexto `$context.requestTimeEpoch` diretamente no template VTL.

### 2. Gatilhos do Authorizer: Resource Policy vs IAM Role
Em vez de criar uma IAM Role (Execution Role) que o API Gateway precisaria assumir via `sts:AssumeRole` para invocar o Authorizer, utilizamos o padrão de **Resource-based Policy** (`aws_lambda_permission`).
* **O Motivo:** Reduz drasticamente a burocracia do IAM (menos código ocioso). É o padrão nativo da AWS para arquiteturas baseadas em eventos (Event-Driven), permitindo que o Lambda diga explicitamente: *"Eu permito ser invocado por este API Gateway"*.

### 3. Performance Extrema (Golang + Graviton)
O Custom Authorizer é o "gargalo" de toda requisição. Para mitigar o problema de *cold start*, a função foi escrita em **Golang** e compilada cruzada para a arquitetura **ARM64 (Graviton)** usando o runtime OS-only `provided.al2023`. Isso entrega o menor custo de execução e o menor tempo de resposta possível na AWS.

### 4. Terraform State Hack (API Gateway Deployments)
O recurso `aws_api_gateway_deployment` tem um bug arquitetural onde ele não percebe mudanças feitas no corpo do VTL (`request_templates`) ou no código do Authorizer, deixando o Stage público desatualizado (preso em cache).
* **A Solução:** Implementamos um bloco `triggers` que calcula o `sha1` do texto do VTL e do `.zip` do Golang. Se uma vírgula mudar no código ou no template, o Terraform é forçado a gerar um novo *Deployment* e atualizar o endpoint na ponta.

### 5. Isolamento de Artefatos (Clean IaC)
Para manter o repositório IaC imaculado e aderente às melhores práticas, os binários compilados pelo Go não poluem o diretório do Terraform.
* O `Makefile` orquestra a criação de uma pasta efêmera `/artifacts` na raiz.
* O Go compila o binário direto para lá.
* O Terraform busca o binário em `/artifacts` para criar o `.zip` da infra.
* A pasta é ignorada pelo `.gitignore`, desacoplando perfeitamente o ciclo de build da declaração de infraestrutura.

---

## 🚀 Como Executar

### Pré-requisitos
* AWS CLI configurado (Profile: `nina`)
* Terraform >= 1.5.0
* Golang >= 1.25

### Comandos Disponíveis (Makefile)

* `make infra-up`: Compila o binário Go em ARM64, cria a pasta de artefatos e aplica o Terraform.
* `make test-401`: Dispara um cURL na URL gerada passando um token inválido (Valida a barreira de proteção).
* `make test-200`: Dispara um cURL com o token válido e um payload de teste.
* `make scan-db`: Executa uma query no CLI para exibir os dados salvos no DynamoDB em formato de tabela no terminal.
* `make clean`: Destrói a infraestrutura na AWS e apaga a pasta local de artefatos.

```