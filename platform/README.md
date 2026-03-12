# Platform Layer

> *"A boa engenharia de plataforma torna o caminho certo, o caminho mais fácil."*

Bem-vindo à camada de **Engenharia de Plataforma** da Alexandria. 

Este diretório contém a **infraestrutura base** (O "Canvas" ou "O Palco"). É aqui que provisionamos os alicerces onde os nossos experimentos, APIs e pipelines de dados irão rodar.

## Objetivo (Platform vs. Workload)

A regra de ouro deste diretório é a **Separação de Responsabilidades**:

* **O que ENTRA aqui:** Clusters Kubernetes (EKS, DOKS), Redes globais (VPCs, Subnets estendidas), Bancos de Dados centrais, Service Meshes e ferramentas de ingress global (Load Balancers base).
* **O que NÃO ENTRA aqui:** Código de aplicação, APIs em Go, scripts de ETL, Lambdas de regras de negócio. Isso pertence à pasta `/projects` (Os "Workloads").

A Plataforma **não sabe e não se importa** com o que está rodando em cima dela. Ela apenas provê computação, rede e armazenamento de forma resiliente.

## 🔌 Como a Plataforma se conecta aos Projetos?

Fiel ao princípio da "Preguiça Inteligente", a conexão entre a Plataforma e os Projetos é feita via **Injeção de Estado**, nunca via hardcode. 

Quando um ambiente é levantado aqui, ele deve exportar suas credenciais e IDs para que a pasta `/projects` possa consumi-los:

1. **Via Terraform Remote State:** A plataforma gera um `terraform.tfstate` no S3 (ou localmente). Os projetos em `/projects/` usam `data "terraform_remote_state" "platform"` para descobrir dinamicamente o ID da VPC, do Cluster ou do Load Balancer.
2. **Via SSM Parameter Store:** Alternativamente, a plataforma pode exportar variáveis sensíveis (como endpoints de banco ou URLs de API) para o SSM. Os projetos então fazem `aws ssm get-parameter` para consumir essas informações em tempo de execução.
3. **Via Kubeconfig:** Clusters provisionados aqui (como o `lab-k8s`) geram um arquivo `kubeconfig`. Os Makefiles dos projetos usam esse arquivo para aplicar Helm Charts e Manifestos diretamente no cluster vivo.

## 🗺️ Catálogo de Ambientes (Current Platforms)

* 🚀 **[`lab-k8s`](./lab-k8s/):** Provisionamento de um cluster Kubernetes efêmero na DigitalOcean (DOKS). Ideal para subir e destruir rapidamente laboratórios de observabilidade (LGTM) e testes de deploy. Exporta automaticamente o `kubeconfig-do.yaml` para uso local.



## 💸 FinOps & Ephemeralidade

A infraestrutura aqui desenhada é **efêmera por padrão**. 
Como laboratórios de plataforma (especialmente K8s) podem gerar custos fixos altos, todos os subdiretórios devem possuir comandos simples e destrutivos em seus `Makefiles`:

```bash
make up    # Levanta a plataforma do zero em minutos
make down  # Destrói a plataforma completamente (Evita surpresas no cartão)

```

Nenhum estado crítico de negócio deve ser mantido de forma persistente dentro da computação desta pasta sem um backup em S3 ou equivalente.