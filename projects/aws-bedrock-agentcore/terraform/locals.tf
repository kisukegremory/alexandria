data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  project_name        = "travel-planner"
  agent_runtime_name  = "travel_planner"
  supervisor_model = "amazon.nova-pro-v1:0"
  subagent_model   = "amazon.nova-lite-v1:0"
  account_id     = data.aws_caller_identity.current.account_id
  region         = data.aws_region.current.region
}
