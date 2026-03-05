resource "aws_apigatewayv2_api" "main" {
  name          = "${local.prefix}-gw"
  protocol_type = "HTTP"
  description   = "API V2 Serverless com Go e Graviton"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api-gw/${aws_apigatewayv2_api.main.name}"
  retention_in_days = var.retention_in_days
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default" # Auto-deploy ativado
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    # Formato JSON Estruturado para Logs (Essencial para Observabilidade)
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      httpMethod              = "$context.httpMethod"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      protocol                = "$context.protocol"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      authorizerError         = "$context.authorizer.error"
    })
  }
}
