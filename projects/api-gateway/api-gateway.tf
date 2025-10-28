# 1. Cria o recurso principal da REST API
resource "aws_api_gateway_rest_api" "http_api" {
  name        = local.project_name
  description = "API Gateway com HTTP Proxy para um endpoint externo"
}