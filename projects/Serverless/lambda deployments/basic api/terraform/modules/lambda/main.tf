resource "aws_lambda_function" "this" {
  function_name = var.project_name
  role          = var.iam_role_arn
  image_uri     = var.image_uri
  package_type  = "Image"
  timeout       = var.timeout
  memory_size   = var.memory_size
  tags          = var.commom_tags
}

resource "aws_lambda_function_url" "this" {
  function_name      = aws_lambda_function.this.function_name
  authorization_type = "NONE"
}