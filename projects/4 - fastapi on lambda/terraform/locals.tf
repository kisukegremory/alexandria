locals {
  project_name = "fastapi-terraform"
  common_tags = {
    managedBy = "terraform"
    project   = local.project_name
  }
}