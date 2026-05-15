terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "nina"
  default_tags {
    tags = {
      "ManagedBy" = "Terraform"
    }
  }
}
