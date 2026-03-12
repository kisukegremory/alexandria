terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "iam" {
  source       = "./modules/iam"
  project_name = local.project_name
  commom_tags  = local.common_tags
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = local.project_name
  commom_tags  = local.common_tags
}

# If you destroy ecr resource, may need to upload a new image before the lambda module (reading ECR Images: couldn't find resource)
module "lambda" {
  source       = "./modules/lambda"
  iam_role_arn = module.iam.iam_role_arn
  image_uri    = module.ecr.image_uri
  project_name = local.project_name
  commom_tags  = local.common_tags
  memory_size  = 300
}