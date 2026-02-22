output "api_key_value" {
  value       = var.required_api_key ? aws_api_gateway_api_key.this[0].value : "Auth Disabled"
  description = "O valor da API Key se habilitada"
  sensitive   = true
}

output "invoke_url" {
  value       = "${aws_api_gateway_stage.this.invoke_url}/${aws_api_gateway_resource.this.path_part}"
  description = "URL de invocação do webhook"
}

output "sqs_queue_url" {
  value       = aws_sqs_queue.this.url
  description = "URL da fila SQS onde as mensagens do webhook serão enviadas"
}
