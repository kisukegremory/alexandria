# main.tf

# Cria o Cluster ECS
resource "aws_ecs_cluster" "meu_cluster" {
  name = "meu-cluster-ec2" # Nome do seu cluster

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Ambiente = "Producao"
  }
}