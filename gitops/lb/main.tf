terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "nina-terraform-tfstates"
    key            = "load-balancer"
    region         = "us-east-1"
    dynamodb_table = "nina-terraform-tfstates-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "ManagedBy" = "Terraform"
      "Project" = local.project_name
    }
  }
}