#!/bin/bash

# Este script configura um novo perfil no ~/.aws/config para assumir uma Role IAM.
export AWS_PROFILE="nina"
ROLE_ARN=$(aws iam get-role --role-name rds-iam-auth-db-conn-role --query 'Role.Arn' --output text)
PROFILE_NAME="${2:-rds-iam-auth}"  # Nome do perfil de destino (padrão: teste-role)
SOURCE_PROFILE="${3:-nina}"   # Perfil de origem (padrão: default)
CONFIG_FILE="$HOME/.aws/config"
REGION="us-east-2"               # Defina sua região padrão

echo "--- Configuração do AWS CLI para Assume Role ---"
echo "Role ARN:           $ROLE_ARN"
echo "Perfil Destino:     $PROFILE_NAME"
echo "Perfil de Origem:   $SOURCE_PROFILE"
echo "Região:             $REGION"
echo "Arquivo de Config:  $CONFIG_FILE"
echo "------------------------------------------------"

# 1. Cria o diretório .aws se ele não existir
mkdir -p "$HOME/.aws"

# 2. Remove a configuração existente (se houver)
sed -i "/\[profile $PROFILE_NAME\]/,+3d" "$CONFIG_FILE" 2>/dev/null

# 3. Bloco de configuração a ser adicionado
CONFIG_BLOCK="
[profile $PROFILE_NAME]
role_arn = $ROLE_ARN
source_profile = $SOURCE_PROFILE
region = $REGION
"

# 4. Adiciona a nova configuração ao arquivo
echo "$CONFIG_BLOCK" >> "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Configuração do perfil '$PROFILE_NAME' adicionada com sucesso ao $CONFIG_FILE."
    echo ""
    echo "Para testar, use o comando: aws s3 ls --profile $PROFILE_NAME"
else
    echo "❌ ERRO: Falha ao escrever no arquivo de configuração."
fi

export AWS_PROFILE="$PROFILE_NAME"