resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "${var.project_name}-task-definition" # Um nome para agrupar suas definições de tarefa
  network_mode             = "bridge"

  # Definindo a quantidade de CPU e memória que sua tarefa precisa.
  # Para EC2, estes são limites "soft" e a máquina subjacente precisa ter capacidade suficiente.
  cpu    = "256" # 256 unidades de CPU (equivalente a 0.25 vCPU)
  memory = "512" # 512 MB de memória

  # Funções IAM para a tarefa e execução da tarefa
  # task_role_arn: Permissões para o contêiner dentro da tarefa (ex: acessar S3)
  # execution_role_arn: Permissões para o agente ECS executar a tarefa (ex: puxar imagens do ECR, enviar logs para CloudWatch)
  task_role_arn       = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  # Definindo os contêineres que farão parte desta tarefa
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest" # Imagem oficial do NGINX
      cpu       = 200             # CPU dedicada para este contêiner
      memory    = 360             # Memória dedicada para este contêiner
      memoryReservation = 360    # Memória reservada para este contêiner
      essential = true            # Se este contêiner parar, a tarefa inteira para

      portMappings = [
        {
          containerPort = 80 # Porta que o NGINX está escutando dentro do contêiner
          hostPort = 0
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.nginx_log_group.name}"
          "awslogs-region"        = "us-east-1"      # Sua região da AWS
          "awslogs-stream-prefix" = "nginx"
        }
      }

      # Variáveis de ambiente, se necessário
      environment = [
        {
          name  = "NGINX_PORT"
          value = "80"
        }
      ]
    }
  ])

  tags = {
    Name        = "nginx-ecs-task"
    Environment = "Development"
  }
}
