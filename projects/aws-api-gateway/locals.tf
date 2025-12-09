locals {
  project_name = "nina-api-gateway"
  function_name   = "lambda_handler"
  artifact_source = "artifacts/lambda.zip"
  code_source     = "./lambda_src/main.py"
}
