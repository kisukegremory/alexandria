# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "arn:aws:ecs:us-east-2:211125621777:task-definition/nina-nginx:3"
resource "aws_ecs_task_definition" "this" {
  container_definitions = jsonencode([{
    cpu               = 256
    environment       = []
    environmentFiles  = []
    essential         = true
    image             = "nginx"
    memory            = 512
    memoryReservation = 512
    mountPoints       = []
    name              = "nginx"
    portMappings = [{
      appProtocol   = "http"
      containerPort = 80
      hostPort      = 80
      name          = "nginx-80-tcp"
      protocol      = "tcp"
    }]
    systemControls = []
    ulimits        = []
    volumesFrom    = []
  }])
  cpu                      = jsonencode(256)
  execution_role_arn       = "arn:aws:iam::211125621777:role/ecsTaskExecutionRole"
  family                   = "nina-nginx"
  ipc_mode                 = null
  memory                   = jsonencode(512)
  network_mode             = "awsvpc"
  pid_mode                 = null
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = null
  tags                     = {}
  tags_all                 = {}
  task_role_arn            = null
  track_latest             = false
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

# __generated__ by Terraform from "nina-cluster"
resource "aws_ecs_cluster" "this" {
  name     = "nina-cluster"
  tags     = {}
  tags_all = {}
  service_connect_defaults {
    namespace = "arn:aws:servicediscovery:us-east-2:211125621777:namespace/ns-fmq5nq2jqw6zd6je"
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}
