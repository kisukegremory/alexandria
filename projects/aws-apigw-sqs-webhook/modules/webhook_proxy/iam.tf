resource "aws_iam_role" "apigw_sqs_role" {
  name = "${var.service_name}-apigw-sqs-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}

data "aws_iam_policy_document" "apigw_sqs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl"
    ]
    resources = [
      aws_sqs_queue.this.arn
    ]
  }
}

resource "aws_iam_role_policy" "apigw_sqs_policy" {
  name   = "${var.service_name}-apigw-sqs-policy-${var.environment}"
  role   = aws_iam_role.apigw_sqs_role.id
  policy = data.aws_iam_policy_document.apigw_sqs_policy.json
}