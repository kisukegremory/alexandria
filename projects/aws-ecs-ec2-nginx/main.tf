terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "nina-terraform-tfstates"
    key            = "services/demo-nginx/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "nina-terraform-tfstates-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "ManagedBy"   = "Terraform"
      "Project"     = var.project_name
      "Environment" = var.env
    }
  }
}