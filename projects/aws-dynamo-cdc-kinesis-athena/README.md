Esse é um padrão arquitetural de altíssimo nível para a sua biblioteca (Alexandria). Ter isso documentado de forma clara vai economizar horas de engenharia no futuro.

Abaixo está a proposta de `README.md` completa, escrita com o foco pragmático e direto que esse tipo de infraestrutura exige. Você pode copiar e colar diretamente no seu arquivo `apps/README.md` ou na raiz do projeto.

---

# 🏗️ Alexandria Pattern: Serverless No-Code CDC (DynamoDB to Athena)

Este repositório contém um padrão arquitetural "Plug & Play" para extrair dados analíticos do DynamoDB (Change Data Capture - CDC) e enviá-á-los para um Data Lake no Amazon S3, consultável via Amazon Athena.

O grande diferencial deste padrão é a **ausência total de código customizado para ETL (Zero Lambdas)**. Toda a extração, transformação e conversão de formato é delegada para serviços nativos e gerenciados da AWS.

## 🧠 Por que essa arquitetura? (Intelligent Laziness)

O DynamoDB é excelente para cargas transacionais (OLTP), mas péssimo e caro para consultas analíticas e agregações (OLAP). Ferramentas de BI (como Metabase, Superset ou QuickSight) não funcionam bem diretamente conectadas a ele.

Esta arquitetura resolve isso criando uma esteira que:

1. **Lê as mudanças em tempo real** usando DynamoDB Streams.
2. **Achata o JSON complexo** usando EventBridge Pipes (*Input Transformer*).
3. **Converte para Parquet** usando Kinesis Data Firehose e AWS Glue.
4. **Armazena no S3** particionado por data.
5. **Permite consultas via SQL** no Athena a um custo irrisório.

---

## 🎯 Quando utilizar (e quando NÃO utilizar)

**✅ Utilize quando:**

* Você precisa conectar ferramentas de BI (Metabase, etc.) aos dados transacionais de um microsserviço.
* A necessidade de atualização dos dados no painel é *Near Real-Time* (atraso tolerável de 1 a 15 minutos).
* Você quer isolar a carga analítica: rodar queries pesadas no Athena não consome nenhuma RCU (Read Capacity Unit) da sua tabela de produção no DynamoDB.
* Você quer minimizar a manutenção de infraestrutura (Zero Lambdas = Zero dependências para atualizar, zero timeouts para monitorar).

**❌ NÃO utilize quando:**

* Você precisa de análises *Sub-second Real-Time* (ex: um dashboard financeiro de alta frequência). Nesse caso, consulte o DynamoDB diretamente ou use o Amazon OpenSearch.
* Você só quer fazer um backup ou exportação pontual e histórica. Para isso, use a funcionalidade nativa **DynamoDB Export to S3** (que custa mais barato e não exige manter um pipeline de streaming ligado).

---

## ⚙️ Parâmetros de Ajuste (Tuning)

Dependendo do microsserviço que vai herdar este padrão, você precisará ajustar alguns parâmetros nos arquivos Terraform:

### 1. Kinesis Firehose: Buffer de Tempo e Tamanho (`kinesis.tf`)

O Athena sofre com o "Problema dos Arquivos Pequenos". Quanto maiores os arquivos Parquet, mais rápida e barata é a query.

* **Para Laboratório/Testes:** `buffering_interval = 60` (1 minuto) e `buffering_size = 5` (MB). Os dados chegam rápido para você ver.
* **Para Produção (Recomendado):** `buffering_interval = 900` (15 minutos) e `buffering_size = 128` (MB). Isso garante que o Firehose acumule bastante dado antes de gravar no S3, gerando arquivos pesados e ideais para o Athena.

### 2. EventBridge Pipes: Input Template (`pipes.tf`)

É aqui que a mágica da transformação sem código acontece. Se o esquema da sua tabela mudar, você deve ajustar o mapeamento JSONPath aqui.

* Se precisar capturar o valor *antes* da mudança (para cálculo de deltas), extraia da chave `<$.dynamodb.OldImage.NOME_DO_CAMPO.S>`.
* Se precisar do valor *atualizado*, use `<$.dynamodb.NewImage.NOME_DO_CAMPO.S>`.

### 3. AWS Glue: Partition Projection (`glue.tf`)

Este projeto usa *Partition Projection*. Isso significa que você **não precisa rodar Glue Crawlers** para que o Athena descubra novos dados diários.

* A propriedade `"projection.ano.range" = "2024,2030"` define até que ano o Athena vai simular a existência de partições. Atualize isso caso o projeto dure mais que o estipulado.

---

## 💸 Análise de Custos e Evolução (FinOps)

Este pipeline é **100% Serverless e Pay-per-Use**. Não há custos fixos (hora/instância) atrelados ao Kinesis Firehose ou EventBridge Pipes. O custo inicial (base) com a infraestrutura ociosa é virtualmente **$0**.

Conforme o tráfego evolui, os custos escalam linearmente com o **volume de dados processados**:

1. **DynamoDB Streams:** Cobrado por leitura de dados (Write capacity para gerar o stream é gratuita). ~$0.02 por 100.000 requisições de leitura (O Pipes faz isso de forma otimizada em *batches*).
2. **EventBridge Pipes:** ~$0.40 por milhão de requisições.
3. **Kinesis Firehose:** ~$0.029 por GB ingerido + ~$0.018 por GB convertido para Parquet.
4. **Amazon S3:** ~$0.023 por GB armazenado (Custo padrão de storage).
5. **Amazon Athena:** ~$5.00 por Terabyte escaneado nas queries.
* *Otimização:* Como o Glue salva os dados em formato **Parquet** (colunar e comprimido) e os particiona por **data**, o volume de dados escaneado pelo Athena cai drasticamente. Uma tabela em JSON que custaria $5.00 para consultar pode custar apenas $0.10 em Parquet particionado.



**Resumo de Evolução:** Para projetos de baixo a médio volume (alguns Gigabytes por mês), o pipeline inteiro custará poucos dólares. O custo só se torna um ponto de atenção na casa dos Terabytes gerados por dia.

---

## 🛠️ Como executar este laboratório localmente

Este projeto inclui um `Makefile` para abstrair os comandos do Terraform e Python.

**Pré-requisitos:**

* AWS CLI configurado (neste projeto, configurado para utilizar o profile `nina`).
* Terraform instalado.
* Python 3.14+ (gerenciado via `uv`).

**Passo a passo:**

1. **Subir a Infraestrutura:**
```bash
make init
make apply

```


2. **Injetar Dados de Teste:**
O script Python gera um ciclo completo de CDC (Insert, Modify e Remove) para acionar a Stream.
```bash
make seed

```


3. **Verificar os Dados:**
Aguarde o tempo configurado de buffer do Firehose (padrão de 60s no lab) e verifique se os arquivos `.parquet` pousaram no Data Lake:
```bash
make check-s3

```

*(Em caso de falha no mapeamento do Glue, verifique os logs de erro com `make check-errors`).*


4. **Consultar:**
Abra o console do AWS Athena, acesse o banco de dados `alexandria-db` e execute as queries na tabela `user_events`.


5. **Limpeza:**
Para não gerar custos desnecessários após o estudo:
```bash
make destroy
make clean

```