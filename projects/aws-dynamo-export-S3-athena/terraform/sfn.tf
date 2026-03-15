resource "aws_iam_role" "sfn_role" {
  name = "alexandria-sfn-dynamo-export-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}


data "aws_iam_policy_document" "sfn_policy" {
  # Permissão para acionar a API do DynamoDB
  statement {
    actions = [
      "dynamodb:ExportTableToPointInTime",
      "dynamodb:DescribeExport" # Permite perguntar o status do export
    ]
    resources = [
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/*" # O export precisa de acesso ao nível da tabela
    ]
  }

  # Permissão que a AWS exige para o serviço do Dynamo gravar no S3 em seu nome
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:AbortMultipartUpload"
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    actions   = ["glue:StartCrawler"]
    resources = [aws_glue_crawler.daily_export.arn]
  }
}

resource "aws_iam_role_policy" "sfn_policy" {
  name   = "alexandria-sfn-dynamo-export-policy"
  role   = aws_iam_role.sfn_role.id
  policy = data.aws_iam_policy_document.sfn_policy.json
}

