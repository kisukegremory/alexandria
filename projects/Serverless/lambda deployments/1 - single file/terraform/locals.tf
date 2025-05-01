locals {
  project_name = "terraform-single-file-lambda"
  function_name   = "lambda_handler"
  artifact_source = "../artifacts"
  code_source     = "../src/main.py"
  role_name       = "${local.project_name}-role"
}