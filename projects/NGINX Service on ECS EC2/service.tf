resource "aws_ecs_service" "this" {
  name = "${var.project_name}-service"
  cluster = data.terraform_remote_state.cluster.outputs.cluster_id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  desired_count = 1

  ordered_placement_strategy {
    type = "binpack"
    field = "memory"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name = "nginx"
    container_port = local.port
  }
  force_new_deployment = true

  depends_on = [ aws_lb_listener_rule.this, aws_lb_target_group.this ]

  capacity_provider_strategy {
          base              = 1
          capacity_provider = data.terraform_remote_state.cluster.outputs.capacity_provider_name
          weight            = 100
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable = true
    rollback = true
  }

  lifecycle {
    create_before_destroy = true
  }
  timeouts {
    delete = "1m"
  }

}