terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}


module "iam_lambda" {
  source        = "./modules/iam_lambda"
  project_name  = local.project_name
}

module "httpx_layer" {
  source      = "./modules/httpx_layer"
  output_path = "${local.artifact_source}/${local.project_name}-httpx-layer.zip"
  source_dir  = "./httpx-layer"
}


module "lambda_layered" {
  source      = "./modules/lambda_layered"
  source_file = "${local.code_source}/lambda_layered/main.py"
  output_path = "${local.artifact_source}/${local.project_name}-layered.zip"
  layers      = [module.httpx_layer.httpx_layer_arn]
  role_arn    = module.iam_lambda.role_arn
}