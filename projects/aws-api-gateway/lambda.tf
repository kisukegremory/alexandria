data "archive_file" "this" {
  type        = "zip"
  source_file = local.code_source
  output_path = local.artifact_source
}

resource "aws_lambda_function" "this" {
  function_name    = local.function_name
  filename         = data.archive_file.this.output_path
  role             = aws_iam_role.lambda.arn
  source_code_hash = data.archive_file.this.output_base64sha256
  runtime          = "python3.13"
  handler          = "main.lambda_handler"
  timeout          = 10
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.http_api.execution_arn}/*"  
}