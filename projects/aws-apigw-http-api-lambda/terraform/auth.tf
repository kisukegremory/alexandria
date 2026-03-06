
# --- Lambda Authorizer ---
resource "aws_lambda_function" "authorizer" {
  function_name = "${local.prefix}-authorizer"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "bootstrap" # Sempre bootstrap para provided.al2023
  runtime       = "provided.al2023"
  architectures = ["arm64"]

  filename         = "../artifacts/authorizer.zip"
  source_code_hash = filebase64sha256("../artifacts/authorizer.zip")

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

# Permissão para o API GW invocar o Authorizer
resource "aws_lambda_permission" "gw_invoke_auth" {
  statement_id  = "AllowAPIGatewayInvokeAuth"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.auth.id}"
}

# --- Authorizer Definition ---
resource "aws_apigatewayv2_authorizer" "auth" {
  api_id          = aws_apigatewayv2_api.main.id
  authorizer_type = "REQUEST"
  authorizer_uri  = aws_lambda_function.authorizer.invoke_arn
  name            = "lambda-authorizer"

  # Configuração Crítica para V2 e Simple Response
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
  identity_sources                  = ["$request.header.Authorization"]
}

