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

module "s3_input_data" {
  source = "./modules/s3_input_data"
  bucket = "${local.project_name}-input-data"
  tags   = local.commom_tags
}


module "iam_lambda" {
  source        = "./modules/iam_lambda"
  project_name  = local.project_name
  s3_bucket_arn = module.s3_input_data.bucket_arn
  tags = local.commom_tags
}

module "lambda_vanilla" {
  source      = "./modules/lambda_vanilla"
  source_file = "${local.code_source}/lambda_vanilla/main.py"
  output_path = "${local.artifact_source}/${local.project_name}-vanilla.zip"
  role_arn    = module.iam_lambda.role_arn
  tags = local.commom_tags
}
