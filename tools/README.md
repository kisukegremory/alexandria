# 🛠️ Alexandria DevTools & CLIs

> *"Gaste 5 horas automatizando uma tarefa para não ter que gastar 5 minutos fazendo-a manualmente todos os dias."*

Bem-vindo à "Oficina" da Alexandria. 

Este diretório (anteriormente conhecido como `setup/`) é dedicado a **Ferramentas de Produtividade, Scripts de Automação e CLIs (Command Line Interfaces)**. 

Enquanto a pasta `/projects` contém o produto final e a `/platform` contém a infraestrutura, a `/tools` contém os **aceleradores** que nos ajudam a construir os outros dois de forma mais rápida, segura e padronizada.

## 🎯 O Objetivo (The "Intelligent Laziness" Core)

A regra para um projeto existir aqui é simples: **Ele deve poupar tempo humano.**

* **O que ENTRA aqui:** * Ferramentas de linha de comando (Go, Python/Typer).
  * Scripts de automação de segurança (Agentes LLM, Linters).
  * Injetores de dependências e sincronizadores de segredos (SSM, Secrets Manager).
  * Wrappers de ferramentas complexas para simplificar o uso no dia a dia.
* **O que NÃO ENTRA aqui:** * Infraestrutura da AWS (Terraform).
  * Aplicações web, APIs ou fluxos de dados de negócio.

## 🧰 O Arsenal (Catálogo Atual)

Nossa caixa de ferramentas está em expansão. Atualmente, contamos com:

* 🔐 **[`go-ssmsync`](./go-ssmsync/):** Um utilitário de ouro escrito em Go. Sincroniza e injeta variáveis de ambiente entre arquivos locais (`.secrets`) e o AWS Systems Manager (SSM) Parameter Store. Feito para ser acoplado no topo de `Makefiles` de outros projetos para resolver o caos de gestão de segredos.
* 🤖 **[`security_agent`](./security_agent/):** Um script bash pragmático que une o `bandit` (análise estática de segurança em Python) com o **Gemini**. Ele não apenas acha vulnerabilidades no código, mas usa IA para explicar o risco e sugerir o *fix* em um relatório Markdown.
* 🧹 **[`cli-sqlfluff`](./cli-sqlfluff/):** Wrapper e configuração base para linting e formatação de código SQL usando o `uv` e `sqlfluff`. Garante que todas as queries de Data Engineering sigam um padrão rigoroso.
* 🐱 **[`py-typer (ninacli)`](./py-typer/):** Boilerplate e estudo de caso para criação de CLIs robustas, tipadas e coloridas em Python usando a biblioteca `Typer`. A semente para a futura ferramenta "Golden Path" da empresa.
* 📦 **Guias de Gestão de Pacotes:** Exemplos de setups otimizados para ferramentas modernas de isolamento e instalação global, como **[`py-uv`](./py-uv/)** (o padrão ouro atual em Python) e **[`py-pipx`](./py-pipx/)**.

## 🚀 Como Utilizar as Ferramentas

A filosofia aqui é que essas ferramentas sejam executáveis em **qualquer lugar** do repositório, ou instaladas globalmente na sua máquina (`~/.local/bin` ou `~/go/bin`).

**Para ferramentas em Go (como o ssmsync):**
Recomenda-se instalar o binário globalmente na máquina para ser chamado em qualquer Makefile:
```bash
cd go-ssmsync
go install .

```

**Para ferramentas em Python (como o ninacli ou sqlfluff):**
Utilizamos o `uv` (ou `uvx` / `pipx`) para rodar os utilitários de forma isolada, sem poluir as dependências globais do sistema:

```bash
uvx sqlfluff lint meu_arquivo.sql

```

**Para Scripts em Bash:**
Garanta permissão de execução antes de usá-los:

```bash
chmod +x security_agent/agent.sh

```

---

*“Se você faz algo mais de duas vezes, escreva um script para isso.”*
