data "aws_ecs_cluster" "this" {
  cluster_name = "metabase-cluster-gustavo"
}

data "aws_ecs_task_definition" "this" {
  task_definition = "arn:aws:ecs:us-east-2:211125621777:task-definition/metabase-task-definition:3"
}