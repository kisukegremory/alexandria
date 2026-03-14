
resource "aws_sfn_state_machine" "daily_snapshot" {
  name     = "${local.project_name}-sfnmachine-daily-snapshot"
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    Comment = "State machine to export DynamoDB table to S3 with clean Date partitions"
    StartAt = "ExtractDate"

    States = {
      # PASSO 1: Corta a data suja (ISO 8601) e extrai apenas o YYYY-MM-DD
      ExtractDate = {
        Type = "Pass"
        Parameters = {
          # Corta pelo 'T' e pega o índice 0 do array resultante
          "clean_date.$" = "States.ArrayGetItem(States.StringSplit($$.Execution.StartTime, 'T'), 0)"
        }
        ResultPath = "$.formatted" # Salva o resultado temporariamente no JSON do processo
        Next       = "ExportTable"
      }

      # PASSO 2: Executa a exportação usando a data limpa que criamos no passo anterior
      ExportTable = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:dynamodb:exportTableToPointInTime"
        Parameters = {
          TableArn = aws_dynamodb_table.this.arn
          S3Bucket = aws_s3_bucket.this.bucket

          # Injeta a variável limpa na string do caminho do S3
          "S3Prefix.$" = "States.Format('events/daily_snapshot/dt={}/', $.formatted.clean_date)"
          ExportFormat = "ION"
        }
        End = true
      }
    }
  })
}



# IAM Role para o Crawler
resource "aws_iam_role" "glue_crawler_role" {
  name = "${local.project_name}-glue-crawler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# Anexa a política gerenciada da AWS para o Glue
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Política inline para permitir leitura e escrita de logs/dados no S3
resource "aws_iam_role_policy" "glue_s3" {
  name = "${local.project_name}-glue-s3-policy"
  role = aws_iam_role.glue_crawler_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = ["${aws_s3_bucket.this.arn}/*"]
      }
    ]
  })
}

# O Crawler
resource "aws_glue_crawler" "daily_export" {
  name          = "${local.project_name}-daily-export-crawler"
  database_name = aws_glue_catalog_database.this.name
  role          = aws_iam_role.glue_crawler_role.arn

  # Agendamento nativo do Crawler para rodar todo dia às 02h15 UTC
  schedule = "cron(15 2 * * ? *)"

  s3_target {
    # Aponta para a pasta raiz dos snapshots. O Crawler vai procurar as partições "dt=" aqui dentro.
    path = "s3://${aws_s3_bucket.this.bucket}/${local.data_prefix}/daily_snapshot/"

    exclusions = [
      "**manifest*"
    ]
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas" # Agrupa partições com o mesmo schema, mesmo que estejam em pastas diferentes, para evitar criar tabelas demais no Glue
    }
  })

  # Modo de recrawl para evitar custos desnecessários e acelerar o processo, lendo apenas o que é novo, requer atualização de schema "manual" para evitar que mudanças inesperadas no Dynamo atrapalhem as consultas no Athena
  #   recrawl_policy {
  #     # Garante o custo baixo lendo apenas o que é novo
  #     recrawl_behavior = "CRAWL_NEW_FOLDERS_ONLY"
  #   }

  #   schema_change_policy {
  #     update_behavior = "LOG"
  #     delete_behavior = "LOG"
  #   }

  # Modo com update de schema automático, mas pode gerar custos maiores no crawler
  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }
}
