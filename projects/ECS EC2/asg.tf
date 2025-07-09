# asg.tf

# Cria o Auto Scaling Group para as instâncias ECS
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "ecs-asg"
  desired_capacity    = 2 # Número desejado de instâncias
  max_size            = 5 # Número máximo de instâncias
  min_size            = 1 # Número mínimo de instâncias
  vpc_zone_identifier = ["sua-subnet-id-1", "sua-subnet-id-2"] # SUBSTITUA pelos IDs de suas sub-redes

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}