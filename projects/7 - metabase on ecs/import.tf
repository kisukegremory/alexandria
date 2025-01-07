import {
  to = aws_ecs_cluster.this
  id = "metabase-cluster"
}

import {
  to = aws_ecs_task_definition.this
  id = "arn:aws:ecs:us-east-2:211125621777:task-definition/metabase-task-definition:1"
}