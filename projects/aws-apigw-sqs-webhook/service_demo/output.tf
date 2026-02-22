output "webhook_url" {
  value       = module.billing_webhook.invoke_url
  description = "The URL of the billing webhook endpoint to be used with curl or Postman for testing."
}

output "api_key" {
  value       = module.billing_webhook.api_key_value
  description = "The API key for the billing webhook endpoint."
  sensitive   = true
}

output "sqs_queue_url" {
  value       = module.billing_webhook.sqs_queue_url
  description = "The URL of the SQS queue that receives messages from the billing webhook."
}


