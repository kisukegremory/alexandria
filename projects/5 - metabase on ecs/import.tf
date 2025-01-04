import {
  to = aws_ecs_cluster.this
  id = "nina-cluster"
}

import {
  to = aws_ecs_task_definition.this
  id = "arn:aws:ecs:us-east-2:211125621777:task-definition/nina-nginx:3"
}