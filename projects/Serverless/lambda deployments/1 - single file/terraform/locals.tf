locals {
  project_name = "terraform-lambda-vanilla"
  commom_tags = {
    managedBy = "terraform"
    project   = local.project_name
    team      = "me and myself"
  }
  function_name   = "lambda_handler"
  artifact_source = "./artifacts"
  code_source     = "./src"
}