terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket         = "alexandria-terraform-tfstates"
    key            = "projects/api-gateway/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile = true
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      "ManagedBy"   = "Terraform"
    }
  }
}