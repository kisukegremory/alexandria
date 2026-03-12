terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      "ManagedBy" = "Terraform"
      "Project" = local.project_name
    }
  }
}


module "security_groups" {
  source = "./modules/security_groups"
  project_name = local.project_name
}

module "rds" {
  source = "./modules/rds"
  project_name = local.project_name
  security_group_ids = [module.security_groups.rds_id]
  subnet_ids = data.aws_subnets.default.ids
}

module "lb" {
  source = "./modules/alb"
  project_name = local.project_name
  security_group_ids = [module.security_groups.lb_id]
  subnet_ids = data.aws_subnets.default.ids
  vpc_id = aws_default_vpc.default.id
  port = local.metabase_port
}

module "ecs" {
  source = "./modules/ecs"
  project_name = local.project_name
  security_group_ids = [module.security_groups.service_id]
  subnet_ids = data.aws_subnets.default.ids
  target_group_arn = module.lb.target_group_arn
  port = local.metabase_port
}

output "lb_url" {
  value = module.lb.lb_url
}