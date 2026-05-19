output "ecr_url" {
  value = aws_ecr_repository.travel_planner.repository_url
}

output "execution_role_arn" {
  value = aws_iam_role.agentcore_execution.arn
}

output "agent_runtime_id" {
  value = aws_bedrockagentcore_agent_runtime.travel_planner.agent_runtime_id
}
