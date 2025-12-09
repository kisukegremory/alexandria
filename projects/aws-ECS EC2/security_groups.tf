
# security_group.tf

# Security Group para as instâncias ECS
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Permite tráfego para o container ECS"
  vpc_id      = var.vpc_id

  # Libera todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite acesso na porta 80 de qualquer lugar (exemplo para um servidor web)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}