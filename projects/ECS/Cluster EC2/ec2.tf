# ec2.tf

# Busca a AMI mais recente otimizada para ECS
data "aws_ssm_parameter" "ami_ecs" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# Cria um Launch Template para as instâncias do cluster
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-lt-"
  image_id      = data.aws_ssm_parameter.ami_ecs.value
  instance_type = "t2.micro" # Escolha o tipo de instância adequado

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_profile.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs_sg.id] # Referencia o Security Group
  }

  # Script para registrar a instância no cluster ECS correto
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.meu_cluster.name} >> /etc/ecs/ecs.config
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Instancia-ECS"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}