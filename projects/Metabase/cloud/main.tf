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
      "Project"   = local.project_name
    }
  }
}

module "security_groups" {
  source = "./modules/security_groups"
  project_name = local.project_name
}

module "db" {
  source = "./modules/rds"
  project_name = local.project_name
  security_group_ids = [module.security_groups.rds_id]
  subnet_ids = data.aws_subnets.default.ids
}

module "load_balancer" {
  source = "./modules/alb"
  project_name = local.project_name
  security_group_ids = [module.security_groups.lb_id]
  subnet_ids = data.aws_subnets.default.ids
  port = local.metabase_port
  vpc_id = aws_default_vpc.default.id
}

module "ecs" {
  source = "./modules/ecs"
  subnet_ids = data.aws_subnets.default.ids
  target_group_arn = module.load_balancer.target_group_arn
  security_group_ids = [module.security_groups.service_id]
  port = local.metabase_port
}

output "url" {
  value = module.load_balancer.lb_url
}