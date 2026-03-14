# VS Code

## Como instalar (meu contexto no ZorinOS):

Para garantir que o comando `code .` funcione de forma fluida e sem dores de cabeça com permissões de sandbox, a abordagem mais pragmática no ZorinOS (que é baseado em Ubuntu) é **instalar via terminal usando o repositório oficial da Microsoft (APT)**.

As versões da loja de aplicativos (geralmente Flatpak ou Snap) rodam em ambientes isolados. Isso significa que elas podem te dar uma dor de cabeça enorme na hora de reconhecer ferramentas instaladas localmente no seu sistema quando você usa o terminal integrado do VS Code (como o Terraform, os binários do Go, ou seus ambientes virtuais de Python).


Ela instala a versão nativa e já coloca o executável `code` diretamente no seu `$PATH`, Abra o terminal e rode os comandos abaixo sequencialmente:

1. Instale as dependências básicas:
```bash
sudo apt-get install wget gpg

```


2. Baixe e instale a chave GPG da Microsoft:
```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

```


3. Adicione o repositório do VS Code:
```bash
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'

```


4. Atualize os pacotes e instale:
```bash
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install code

```



Pronto. Agora basta entrar em qualquer diretório no terminal e rodar `code .` que ele abrirá a pasta atual


## Como Atualizar

Essa é a beleza de ter instalado via APT (o repositório oficial). O aviso aparece na interface, mas o controle da atualização fica totalmente na sua mão, no terminal, resolvido em segundos e sem depender de processos em segundo plano de lojas de aplicativos.

Como nós adicionamos a chave da Microsoft direto nas fontes do ZorinOS lá no início, o seu sistema operacional já sabe exatamente onde buscar a versão nova,
Abra o terminal (pode ser o próprio terminal integrado do VS Code) e rode este comando combinado:

```bash
sudo apt update && sudo apt install --only-upgrade code
```


## Extensões Recomendadas

**HashiCorp Terraform**
*https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform*

Alem disso configure o auto lint do terraform fmt com:

1. Aperte Ctrl + Shift + P para abrir a paleta de comandos.

2. Digite Preferences: Open User Settings (JSON) e dê Enter (isso abre as configurações globais em formato de código).

3. Adicione este bloco exato em qualquer lugar dentro das chaves principais {} do arquivo:
```json
  "[terraform]": {
    "editor.defaultFormatter": "HashiCorp.terraform",
    "editor.formatOnSave": true
  }
```

Isso vai garantir que toda vez que você salvar um arquivo `.tf`, ele seja automaticamente formatado usando o `terraform fmt` da extensão, mantendo seu código limpo e padronizado sem esforço extra.

**Terraform Link Docs**
*https://marketplace.visualstudio.com/items?itemName=TylerHarris.terraform-link-docs*
Simplesmente adiciona um atalho para abrir a documentação oficial do recurso que você está editando, super útil para consultas rápidas.