data "aws_ecs_cluster" "this" {
  cluster_name = "metabase-cluster-gustavo"
}

data "aws_ecs_task_definition" "this" {
 task_definition = "arn:aws:ecs:us-east-2:{{account}}:task-definition/metabase-task-definition-yt:2"
}