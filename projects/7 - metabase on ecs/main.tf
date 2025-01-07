terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      "ManagedBy" = "Terraform"
      "Project"   = "metabase-on-ecs"
    }
  }
}


module "sg" {
  source = "./modules/sg"
}