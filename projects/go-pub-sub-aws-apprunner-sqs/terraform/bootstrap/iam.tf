resource "aws_iam_role" "build" {
  name = "${replace(local.project_name, "/", ".")}-build-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "build.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "build" {
  role       = aws_iam_role.build.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_iam_role" "task" {
  name = "${replace(local.project_name, "/", ".")}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "tasks.apprunner.amazonaws.com" }
    }]
  })
}

data "aws_iam_policy_document" "task" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "sqs:*",
    ]
    resources = [aws_sqs_queue.this.arn]
  }
}


resource "aws_iam_policy" "task" {
  name   = "${replace(local.project_name, "/", "-")}-service-policy"
  policy = data.aws_iam_policy_document.task.json
}

resource "aws_iam_role_policy_attachment" "task" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.task.arn
}
