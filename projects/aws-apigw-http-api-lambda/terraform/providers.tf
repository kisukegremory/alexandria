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
  project_name = "aws-apigw-http-api"
  prefix       = "alexandria-api-v2"
}
