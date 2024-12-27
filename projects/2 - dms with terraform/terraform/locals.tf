locals {
  project_name = "ninadb-to-s3"
  common_tags = {
    team    = "Gustavo"
    env     = "dev"
    project = local.project_name
  }
}