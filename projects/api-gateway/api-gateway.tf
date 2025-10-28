# 1. Cria o recurso principal da REST API
resource "aws_api_gateway_rest_api" "http_api" {
  name        = local.project_name
  description = "API Gateway com HTTP Proxy para um endpoint externo"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.http_api.id
  triggers = {
      redeployment = sha1(jsonencode([
      aws_api_gateway_resource.external_resource.id,
      aws_api_gateway_integration.lambda.id
      ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.http_api.id
  stage_name    = "dev"
}