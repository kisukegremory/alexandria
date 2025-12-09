terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "alexandria-terraform-tfstates"
    key          = "serverless-interaction/bootstrap/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "ManagedBy"   = "Terraform"
      "Environment" = terraform.workspace
      "Project"     = local.project_name
    }
  }
}
