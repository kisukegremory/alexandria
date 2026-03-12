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

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "managedBy" = "terraform"
      "project"   = local.project_name
    }
  }
}