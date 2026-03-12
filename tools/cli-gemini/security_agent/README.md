# Security Agent

Ele requer que se tenha tanto o uvx, quanto o gemini instalado, para rodar o script basta permitir:

```shell
chmod +x agent.sh # uma vez -> permite execução do shell
./agent.sh
```

1. Ele executará o bandit de forma recursiva olhando principalemente para problemas com criticidade média, alta
2. Interpretará com o gemini
3. irá gerar um report.md

- É possível alterar o modelo do gemini, por default deixei o flash, mas o ideal é o pro
- É possível mudar o caminho em que o agente irá checar, por default deixei apontando para os projetos serverless do repositório