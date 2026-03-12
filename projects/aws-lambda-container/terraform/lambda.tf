resource "aws_lambda_function" "this" {
  function_name = local.project_name
  role          = aws_iam_role.this.arn
  image_uri     = data.aws_ecr_image.this.image_uri
  package_type  = "Image"
  timeout       = 120
  memory_size   = 1024
  environment {
    variables = {
      example_variable = "coxinha"
    }
  }
}