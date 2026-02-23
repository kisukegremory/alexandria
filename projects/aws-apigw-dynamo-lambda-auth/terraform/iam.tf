resource "aws_iam_role" "apigw_dynamo" {
  name = "${local.project_name}-apigw-dynamo-role"

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

data "aws_iam_policy_document" "apigw_dynamo" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
    ]
    resources = [
      aws_dynamodb_table.this.arn
    ]
  }
}

resource "aws_iam_role_policy" "apigw_dynamo" {
  name   = "${local.project_name}-apigw-dynamo-policy"
  role   = aws_iam_role.apigw_dynamo.id
  policy = data.aws_iam_policy_document.apigw_dynamo.json
}


resource "aws_iam_role" "lambda_auth" {
  name = "${local.project_name}-lambda-auth-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "lambda_auth_basic" {
  role       = aws_iam_role.lambda_auth.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
