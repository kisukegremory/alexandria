terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "nina"
  region  = "us-east-1"
}

locals {
  project_name = "aws-apigw-dump-example"
}
