# UV

# Motivos para migração do poetry
Não vejo motivos para projetos já existentes, mas para projetos futuros pode agilizar o tempo de build e criação de projetos, alem de que o uvx é bizarro de bom

# Como instalar?

On macOS and Linux.
`curl -LsSf https://astral.sh/uv/install.sh | sh`

# Instalando versões do python

`uv python install 3.12 3.13 3.14`

# Começando um projeto

`uv init testpath -p 3.13 --description "testing project"`

# Começando um projeto as lib

`uv init testpath --lib -p 3.13 --description "testing project lib"`

# Adicionando pacotes

`uv add fastapi`

# Adicionando grupos de dependencias

`uv add fastapi --dev`
`uv add fastapi --group nina`

# Rodando código

`uv run python main.py`

# Rodando comandos isolados

`uvx ruff check .`
