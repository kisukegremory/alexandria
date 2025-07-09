resource "aws_ecs_cluster" "meu_cluster" {
  name = var.project_name # Nome do seu cluster

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "ecs_asg" {
  name = "capacity-provider-${var.project_name}"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
    }

  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.meu_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_asg.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_asg.name
  }
}