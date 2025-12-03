resource "aws_sqs_queue" "this" {
  name = "${replace(local.project_name, "/", "-")}-queue"
}
