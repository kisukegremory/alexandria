# Makefile para automação do laboratório API Gateway + SQS

export AWS_PROFILE=nina


.PHONY: init plan apply test receive ack clean

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply -auto-approve

# Dispara o webhook pegando as credenciais dinamicamente do Terraform state
test:
	@echo "==> Coletando credenciais e URLs geradas..."
	@URL=$$(terraform output -raw webhook_url); \
	API_KEY=$$(terraform output -raw api_key); \
	echo "==> Disparando cURL para o API Gateway ($$URL)..."; \
	curl -s -X POST $$URL \
	  -H "x-api-key: $$API_KEY" \
	  -H "Content-Type: application/json" \
	  -d '{"event": "test_automation", "status": "success", "source": "makefile"}'
	@echo "\n==> Payload enviado com sucesso!"

# Consome a mensagem do SQS para provar que a integração funcionou
receive:
	@echo "==> Lendo a fila SQS..."
	@QUEUE_URL=$$(terraform output -raw sqs_queue_url); \
	aws sqs receive-message \
	  --queue-url $$QUEUE_URL \
	  --region us-east-1 \
	  --max-number-of-messages 1 \
	  --output json

# Consome a mensagem e deleta da fila (ACK)
ack:
	@echo "==> Lendo a fila e extraindo o Receipt Handle com profile $$AWS_PROFILE..."
	@QUEUE_URL=$$(terraform output -raw sqs_queue_url); \
	RECEIPT_HANDLE=$$(aws sqs receive-message \
	  --queue-url $$QUEUE_URL \
	  --region us-east-1 \
	  --max-number-of-messages 1 \
	  --output json | jq -r '.Messages[0].ReceiptHandle'); \
	if [ "$$RECEIPT_HANDLE" != "null" ] && [ -n "$$RECEIPT_HANDLE" ]; then \
		echo "==> Mensagem encontrada! Dando ACK (deletando)..."; \
		aws sqs delete-message \
		  --queue-url $$QUEUE_URL \
		  --receipt-handle "$$RECEIPT_HANDLE" \
		  --region us-east-1; \
		echo "==> ACK concluído. Mensagem removida da fila."; \
	else \
		echo "==> Nenhuma mensagem encontrada na fila."; \
	fi

# Destrói a infraestrutura para não gerar custos esquecidos na conta
clean:
	@echo "==> Destruindo a infraestrutura..."
	terraform destroy -auto-approve