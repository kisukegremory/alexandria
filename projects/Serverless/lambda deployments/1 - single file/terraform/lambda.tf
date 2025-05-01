data "archive_file" "this" {
  type        = "zip"
  output_path = local.artifact_source
  source_file = local.code_source
}

resource "aws_lambda_function" "this" {
  function_name    = local.function_name
  filename         = data.archive_file.this.output_path
  role             = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.this.output_base64sha256
  runtime          = "python3.13"
  handler          = "main.lambda_handler"
  timeout          = 10
}