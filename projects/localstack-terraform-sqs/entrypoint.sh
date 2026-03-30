#!/bin/sh
until curl -s http://localstack:4566/_localstack/health | grep -E '"sqs": "(running|available|initialized)"'; do
  echo "Aguardando SQS reportar status pronto..."
  sleep 2
done

echo "LocalStack pronto! Iniciando Terraform..."
# O Terraform init vai criar a pasta .terraform no seu host via volume
terraform init
terraform apply -auto-approve