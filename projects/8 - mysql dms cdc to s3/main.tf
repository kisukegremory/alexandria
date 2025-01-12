terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"
}

module "rds" {
  source = "./modules/rds"
  security_group_id = module.vpc.sg_rds_id
  subnet_ids = module.vpc.subnet_ids
}