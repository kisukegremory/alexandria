terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      "ManagedBy" = "Terraform"
      "Project" = local.project_name
    }
  }
}

module "s3" {
  source = "./modules/s3"
  project_name = local.project_name
}

module "ses" {
  source = "./modules/ses"
  project_name = local.project_name
  bucket_arn = module.s3.bucket_arn
}

