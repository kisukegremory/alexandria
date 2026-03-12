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
  source            = "./modules/rds"
  security_group_id = module.vpc.sg_rds_id
  subnet_ids        = module.vpc.subnet_ids
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "nina-bucket-s3-dms"
}

module "s3_silver" {
  source      = "./modules/s3"
  bucket_name = "nina-bucket-s3-silver"
}

module "dms" {
  source            = "./modules/dms"
  security_group_id = module.vpc.sg_dms_id
  subnet_ids        = module.vpc.subnet_ids
  db_config         = module.rds.db_config
  bucket            = module.s3.bucket
}