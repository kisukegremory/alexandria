#!/bin/bash

# 1. Defina o caminho do seu repositório
REPO_PATH="../../projects/Serverless" # Ou o caminho para seu_repositorio_local

# 2. Defina o modelo Gemini a ser usado
GEMINI_MODEL="gemini-2.5-flash" # "gemini-2.5-pro"

# 3. Defina o prompt inicial para o Gemini
read -r -d '' GEMINI_INITIAL_PROMPT << EOM
Você é um especialista em segurança de código. Analise o relatório de vulnerabilidades JSON a seguir gerado pela ferramenta Bandit. Para cada vulnerabilidade detectada (especialmente as de severidade MÉDIA ou ALTA), explique em termos simples:
1. A natureza da vulnerabilidade.
2. O potencial impacto de segurança.
3. Uma sugestão prática de correção (preferencialmente com um trecho de código Python corrigido).

Se não houver vulnerabilidades, apenas declare isso.

---
Relatório Bandit:
EOM

# 4. Execute o Bandit, pegue a saída JSON, concatene com o prompt e envie para o Gemini
GEMINI_FINAL_PROMPT=$(echo "${GEMINI_INITIAL_PROMPT}" && uvx bandit -r "${REPO_PATH}" -x "${REPO_PATH}/.venv") 

echo "Starting Analysis"
GEMINI_ANALYSIS=$(echo "${GEMINI_FINAL_PROMPT}" | gemini --model "${GEMINI_MODEL}" -p)
echo "${GEMINI_ANALYSIS}" > report.md