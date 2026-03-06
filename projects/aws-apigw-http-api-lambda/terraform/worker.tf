# --- Lambda Worker ---
resource "aws_lambda_function" "worker" {
  function_name = "${local.prefix}-worker"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"
  architectures = ["arm64"]

  filename         = "../artifacts/worker.zip"
  source_code_hash = filebase64sha256("../artifacts/worker.zip")
}

# Permissão para o API GW invocar o Worker
resource "aws_lambda_permission" "gw_invoke_worker" {
  statement_id  = "AllowAPIGatewayInvokeWorker"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.worker.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/ingest*"
}

# --- Integration (Worker) ---
resource "aws_apigatewayv2_integration" "worker" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.worker.invoke_arn

  integration_method     = "POST"
  payload_format_version = "2.0"
}


# --- Route Definition ---
resource "aws_apigatewayv2_route" "ingest" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /ingest"
  target    = "integrations/${aws_apigatewayv2_integration.worker.id}"

  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "ingest_auth" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /ingest-auth"
  target    = "integrations/${aws_apigatewayv2_integration.worker.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.auth.id
}

