data "archive_file" "handler" {
  type        = "zip"
  source_file = "${path.module}/../lambda/handler.py"
  output_path = "${path.module}/../lambda/handler.zip"
}

resource "aws_lambda_function" "action_groups" {
  function_name    = "${local.project_name}-action-groups"
  role             = aws_iam_role.lambda_execution.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.handler.output_path
  source_code_hash = data.archive_file.handler.output_base64sha256
  timeout          = 30
}

resource "aws_lambda_permission" "bedrock" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.action_groups.function_name
  principal     = "bedrock.amazonaws.com"
}
