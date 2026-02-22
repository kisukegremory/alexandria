
resource "aws_sqs_queue" "this" {
  name = "${var.service_name}-webhook-queue-${var.environment}"
}
