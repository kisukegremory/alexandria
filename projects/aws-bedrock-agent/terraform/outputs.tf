output "agent_id" {
  value = aws_bedrockagent_agent.techcorp.id
}

output "agent_alias_id" {
  value = aws_bedrockagent_agent_alias.live.agent_alias_id
}

output "kb_id" {
  value = aws_bedrockagent_knowledge_base.techcorp.id
}

output "data_source_id" {
  value = aws_bedrockagent_data_source.docs.data_source_id
}

output "docs_bucket_name" {
  value = aws_s3_bucket.docs.bucket
}
