# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "metabase-cluster"
resource "aws_ecs_cluster" "this" {
  name     = "metabase-cluster"
  tags     = {}
  tags_all = {}
  service_connect_defaults {
    namespace = "arn:aws:servicediscovery:us-east-2:361649602794:namespace/ns-g7iaxlcvr5r7jnge"
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# __generated__ by Terraform from "arn:aws:ecs:us-east-2:361649602794:task-definition/metabase-task-definition:1"
resource "aws_ecs_task_definition" "this" {
  container_definitions = jsonencode([{
    cpu = 1024
    environment = [{
      name  = "MB_DB_DBNAME"
      value = "metabaseappdb"
      }, {
      name  = "MB_DB_HOST"
      value = "metabase-on-ecs-db.csbsah9wiyn6.us-east-2.rds.amazonaws.com"
      }, {
      name  = "MB_DB_PASS"
      value = "mysecretpassword"
      }, {
      name  = "MB_DB_PORT"
      value = "5432"
      }, {
      name  = "MB_DB_TYPE"
      value = "postgres"
      }, {
      name  = "MB_DB_USER"
      value = "metabase"
    }]
    environmentFiles = []
    essential        = true
    image            = "metabase/metabase:latest"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/metabase-task-definition"
        awslogs-region        = "us-east-2"
        awslogs-stream-prefix = "ecs"
        max-buffer-size       = "25m"
        mode                  = "non-blocking"
      }
      secretOptions = []
    }
    memory            = 3072
    memoryReservation = 2048
    mountPoints       = []
    name              = "metabase-container"
    portMappings = [{
      appProtocol   = "http"
      containerPort = 3000
      hostPort      = 3000
      name          = "metabase-container-3000-tcp"
      protocol      = "tcp"
    }]
    systemControls = []
    ulimits        = []
    volumesFrom    = []
  }])
  cpu                      = jsonencode(1024)
  execution_role_arn       = "arn:aws:iam::361649602794:role/ecsTaskExecutionRole"
  family                   = "metabase-task-definition"
  ipc_mode                 = null
  memory                   = jsonencode(3072)
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
