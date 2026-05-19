resource "aws_bedrockagentcore_agent_runtime" "travel_planner" {
  agent_runtime_name = local.agent_runtime_name
  role_arn           = aws_iam_role.agentcore_execution.arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = "${aws_ecr_repository.travel_planner.repository_url}:latest"
    }
  }

  network_configuration {
    network_mode = "PUBLIC"
  }

  depends_on = [
    aws_iam_role_policy.agentcore_invoke_models,
    aws_iam_role_policy.agentcore_ecr,
  ]
}
