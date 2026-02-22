# Cria a chave de API se a variável required_api_key for verdadeira
resource "aws_api_gateway_api_key" "this" {
  count       = var.required_api_key ? 1 : 0
  name        = "${var.service_name}-api-key-${var.environment}"
  description = "API Key for ${var.service_name} in ${var.environment} environment"
  enabled     = true
}

# Cria um plano de uso e associa a API
resource "aws_api_gateway_usage_plan" "this" {
  count       = var.required_api_key ? 1 : 0
  name        = "${var.service_name}-usage-plan-${var.environment}"
  description = "Usage plan for ${var.service_name} in ${var.environment} environment"

  # Esse plano dá acesso a esta api em específico, mas pode ser expandido para incluir outras APIs se necessário
  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  # Limites de uso (opcional, pode ser ajustado conforme necessário)
  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }

}

# Associa a chave de API ao plano de uso, se necessário
resource "aws_api_gateway_usage_plan_key" "this" {
  count       = var.required_api_key ? 1 : 0
  key_id      = aws_api_gateway_api_key.this[0].id
  key_type    = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[0].id
}
