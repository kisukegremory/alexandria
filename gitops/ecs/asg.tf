# Cria o Auto Scaling Group para as instâncias ECS
resource "aws_autoscaling_group" "ecs_asg" {
  name                = var.project_name
  desired_capacity    = 1 # Número desejado de instâncias
  max_size            = 5 # Número máximo de instâncias
  min_size            = 1 # Número mínimo de instâncias
  vpc_zone_identifier = [data.terraform_remote_state.network.outputs.private_subnet_a_id]
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = aws_launch_template.ecs_launch_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
    preferences {
      min_healthy_percentage = 50
    }
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

