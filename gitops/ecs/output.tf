output "cluster_id" {
  value = aws_ecs_cluster.meu_cluster.id
}

output "cluster_name" {
  value = aws_ecs_cluster.meu_cluster.name
}

output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.ecs_asg.name
}