
# Apenas um exemplo de como seria a integração do authorizer, não esqueça de atualizar o integration_request para passar o token correto no header Authorization
# resource "aws_lambda_function" "authorizer_python" {
#   function_name    = "api-token-authorizer"
#   role             = aws_iam_role.lambda_auth.arn
#   handler          = "main.lambda_handler"
#   runtime          = "python3.12" # Apenas para o mock inicial passar
#   filename         = data.archive_file.authorizer_python.output_path
#   source_code_hash = data.archive_file.authorizer_python.output_base64sha256
# }



resource "aws_lambda_function" "authorizer" {
  function_name    = "api-token-authorizer"
  role             = aws_iam_role.lambda_auth.arn
  handler          = "bootstrap"       # Para runtimes customizados, o handler é geralmente "bootstrap"
  runtime          = "provided.al2023" # Runtime customizado para Go
  architectures    = ["arm64"]
  filename         = data.archive_file.authorizer_zip.output_path
  source_code_hash = data.archive_file.authorizer_zip.output_base64sha256
}

resource "aws_api_gateway_authorizer" "custom_authorizer" {
  name           = "lambda-custom-authorizer"
  rest_api_id    = aws_api_gateway_rest_api.this.id
  authorizer_uri = aws_lambda_function.authorizer.invoke_arn
  type           = "TOKEN"
}

resource "aws_lambda_permission" "apigw_invoke_authorizer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  # Limita para que apenas este API Gateway específico possa chamar o Lambda
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}
