locals {
  project_name = "terraform-rds"
  common_tags = {
    team    = "Gustavo"
    env     = "dev"
    project = local.project_name
  }
}