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
    actions = ["dynamodb:ExportTableToPointInTime"]
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
}

resource "aws_iam_role_policy" "sfn_policy" {
  name   = "alexandria-sfn-dynamo-export-policy"
  role   = aws_iam_role.sfn_role.id
  policy = data.aws_iam_policy_document.sfn_policy.json
}


resource "aws_sfn_state_machine" "this" {
  name     = "${local.project_name}-sfnmachine"
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    Comment = "State machine to export DynamoDB table to S3"
    StartAt = "ExportTable" # O nome do estado inicial deve ser o mesmo do estado definido no bloco
    States = {
      ExportTable = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:dynamodb:exportTableToPointInTime" # O recurso específico para exportar a tabela do DynamoDB
        Parameters = {
          TableArn     = aws_dynamodb_table.this.arn
          S3Bucket     = aws_s3_bucket.this.bucket
          S3Prefix     = "${local.data_prefix}/daily_dump/"
          ExportFormat = "ION" # Se for "DYNAMODB_JSON", virá aquele "S" para os tipos de dados. O ION é mais leve e fácil de consultar no Athena
        }
        End = true
      }
    }
  })

}
