# Bedrock Knowledge Base com S3 Vectors

Projeto de estudo hands-on para o AIF-C01.
Gap coberto: Bedrock Knowledge Bases (RAG nativo) + S3 Vectors como vector store.

## Arquitetura

```
S3 Bucket (docs) ──► Bedrock Data Source ──► Knowledge Base ──► S3 Vectors Index
                          (ingestion job)          ↑
                                              IAM Role (Bedrock service)
```

**Embedding:** `amazon.titan-embed-text-v2:0` (1024 dims, cosine)
**Geração:** configurável via `MODEL` em `main.py`

S3 Vectors não é um S3 bucket comum — é um tipo separado com hierarquia própria:
`Vector Bucket → Vector Index → Vectors (chave + embedding + metadata)`

---

## Descobertas

### 1. Limite de 2048 bytes de metadata (S3 Vectors preview)

O Bedrock armazena o texto do chunk + metadados (source URI, chunk ID, data source ID) como *filterable metadata* de cada vetor no S3 Vectors. Esse campo tem limite de 2048 bytes.

Com o padrão de 300 tokens o limite estoura. Reduzimos para 200 → 150 e ainda assim, ao usar o vault do Obsidian como fonte (~348 docs), ~49% dos documentos falharam na ingestão. Markdown rico — frontmatter YAML, wikilinks `[[...]]`, tabelas, listas aninhadas — infla o byte count independente do número de tokens.

**Conclusão:** S3 Vectors (preview) é adequado para texto simples e PDFs de documentação técnica. Incompatível com markdown denso como fonte de dados.

### 2. Chunk size é hiperparâmetro de RAG, não só workaround

A escolha do `max_tokens` afeta diretamente a qualidade do retrieval:

- **Chunks menores:** retrieval mais preciso (menos ruído no contexto), mas pode perder contexto entre chunks
- **Chunks maiores:** mais contexto por chunk, retrieval menos preciso (traz conteúdo irrelevante junto)
- **Overlap:** garante que informação na borda entre dois chunks aparece em ambos — resolve casos onde a resposta está na junção

Para documentação técnica densa, 150–300 tokens com 10–20% de overlap é um ponto de partida razoável.

### 3. Citations ≠ chunks recuperados

`top_k` (ou `numberOfResults`) controla quantos chunks o S3 Vectors retorna. Citations são outra coisa: mapeiam trechos da *resposta gerada* para os chunks que os embasaram.

Com `top_k=1`: 1 chunk recuperado, mas N citations — uma por parágrafo da resposta que usou aquele chunk.
Com `top_k=3`: 3 chunks recuperados, mas o modelo pode citar só 1 se os outros forem irrelevantes para a resposta específica.

Citations sem fonte → o modelo gerou aquele trecho do próprio conhecimento de treinamento, sem retrieval.

### 4. Modelos diferentes, comportamentos diferentes com o mesmo contexto

| Modelo | Citações | Idioma | Síntese |
|---|---|---|---|
| Nova Micro | Cita tudo que recebe | Espelha a pergunta | Parafraseia chunks |
| Nova Lite | Seletivo | Segue o idioma dos chunks | Sintetiza |
| Nova Pro | Muito seletivo | Segue o idioma dos chunks | Sintetiza, descarta irrelevante |

Micro parece "mais rico em fontes" mas é menos inteligente sobre o que usou. Pro lê todos os chunks e descarta internamente o que não importa — comportamento similar ao que um reranker faria explicitamente.

Controle de idioma e grounding via `generationConfiguration.promptTemplate` no payload do `retrieve_and_generate`, usando `$search_results$` como placeholder para os chunks.

### 5. Alucinação silenciosa no retrieve_and_generate

Pergunta sobre Pulumi (ausente no PDF): o modelo misturou conhecimento de treinamento com os chunks sem nenhum sinal de alerta. A resposta gerada sobre Pulumi estava factualmente errada. A única forma de detectar: ausência de citation naquele trecho da resposta.

Mitigações:
- Usar `retrieve` separado, checar scores de similaridade antes de gerar — se o score máximo estiver abaixo de um threshold, não chamar o LLM
- Adicionar instrução explícita no prompt template: *"se a resposta não estiver nos documentos, diga que não encontrou"*
- Bedrock Guardrails com grounding habilitado

### 6. retrieve vs retrieve_and_generate

`retrieve_and_generate` é um pipeline gerenciado: uma chamada, citations automáticas, menos código. Faz sentido separar quando:

- Quero checar scores antes de decidir se gero (evita alucinação e custo de geração)
- Quero controle total do prompt (sistema, few-shot, instruções específicas)
- Quero consultar múltiplas KBs e fazer merge dos chunks antes de gerar
- Quero fazer reranking manual dos chunks recuperados

`retrieve` retorna os chunks com score de similaridade cosine — útil para debugar se o retrieval está trazendo conteúdo relevante.

---

## Limitação de escopo deste projeto

| Funciona bem | Não funciona |
|---|---|
| PDFs de documentação técnica | Markdown rico (Obsidian vault) |
| Arquivos .txt simples | Notas com frontmatter YAML extenso |
| Documentos em inglês ou português sem formatação pesada | Wikilinks, tabelas, listas aninhadas |

O próximo sub-projeto (`aws-bedrock-kb-pgvector`) testa a mesma arquitetura com Aurora + pgvector como vector store — sem o limite de 2048 bytes, com a adição de filtros SQL por pasta/tag.
