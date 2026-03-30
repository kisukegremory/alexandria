resource "aws_sqs_queue" "dlq" {
  name = "dlq-queue"
}

resource "aws_sqs_queue" "app_queue" {
  name = "app-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}


output "queue_url" {
  value = aws_sqs_queue.app_queue.url
}
