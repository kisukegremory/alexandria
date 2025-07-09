resource "aws_ecs_service" "demo_app_service" {
  name            = "${var.project_name}-ecs-service"
  cluster         = data.aws_ecs_cluster.this.id
  task_definition = data.aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "metabase"
    container_port   = var.port
  }

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = var.security_group_ids
  }
}