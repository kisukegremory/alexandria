locals {
  project_name = "terraform-dms-from-rds"
  common_tags = {
    team    = "Gustavo"
    env     = "dev"
    project = local.project_name
  }
}