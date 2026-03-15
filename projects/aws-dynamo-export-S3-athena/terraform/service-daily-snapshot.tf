resource "aws_iam_role" "sfn_daily_snapshot_role" {
  name = "${local.project_name}-sfn-daily-snapshot-role"
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


data "aws_iam_policy_document" "daily_snapshot_policy" {
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
      "s3:AbortMultipartUpload",
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    actions   = ["glue:StartCrawler"]
    resources = [aws_glue_crawler.daily_export.arn]
  }
}

resource "aws_iam_role_policy" "daily_snapshot_policy" {
  name   = "${local.project_name}-sfn-daily-snapshot-policy"
  role   = aws_iam_role.sfn_daily_snapshot_role.id
  policy = data.aws_iam_policy_document.daily_snapshot_policy.json
}





resource "aws_sfn_state_machine" "daily_snapshot" {
  name     = "${local.project_name}-sfnmachine-daily-snapshot"
  role_arn = aws_iam_role.sfn_daily_snapshot_role.arn

  definition = jsonencode({
    Comment = "Exporta DynamoDB, faz Polling até acabar, e roda o Glue Crawler",
    StartAt = "ExtractDate",
    States = {

      # PASSO 1: Formata a Data
      ExtractDate = {
        Type = "Pass",
        Parameters = {
          "clean_date.$" = "States.ArrayGetItem(States.StringSplit($$.Execution.StartTime, 'T'), 0)"
        },
        ResultPath = "$.formatted",
        Next       = "StartExport"
      },

      # PASSO 2: Inicia o Export (Assíncrono)
      StartExport = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:dynamodb:exportTableToPointInTime",
        Parameters = {
          TableArn     = aws_dynamodb_table.this.arn
          S3Bucket     = aws_s3_bucket.this.bucket
          "S3Prefix.$" = "States.Format('events/daily_snapshot/dt={}/', $.formatted.clean_date)",
          ExportFormat = "ION"
        },
        ResultPath = "$.exportResult", # Salva o ExportArn aqui para usarmos depois
        Next       = "WaitState"
      },

      # PASSO 3: Dorme por 2 minutos
      WaitState = {
        Type    = "Wait",
        Seconds = 120,
        Next    = "CheckExportStatus"
      },

      # PASSO 4: Pergunta o Status atual
      CheckExportStatus = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:dynamodb:describeExport",
        Parameters = {
          "ExportArn.$" = "$.exportResult.ExportDescription.ExportArn"
        },
        ResultPath = "$.statusResult",
        Next       = "IsExportDone"
      },

      # PASSO 5: Toma a decisão (O Switch/Case)
      IsExportDone = {
        Type = "Choice",
        Choices = [
          {
            Variable     = "$.statusResult.ExportDescription.ExportStatus",
            StringEquals = "COMPLETED",
            Next         = "StartCrawler" # Se acabou, vai pro Crawler
          },
          {
            Variable     = "$.statusResult.ExportDescription.ExportStatus",
            StringEquals = "IN_PROGRESS",
            Next         = "WaitState" # Se não acabou, volta a dormir
          }
        ],
        Default = "ExportFailed" # Se for FAILED ou qualquer outra coisa, quebra.
      },

      # PASSO 6: Sucesso! Aciona o Crawler
      StartCrawler = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:startCrawler",
        Parameters = {
          Name = aws_glue_crawler.daily_export.name
        },
        End = true
      },

      # PASSO DE ERRO
      ExportFailed = {
        Type  = "Fail",
        Cause = "DynamoDB Export Falhou",
        Error = "ExportFailedError"
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
  recrawl_policy {
    # Garante o custo baixo lendo apenas o que é novo
    recrawl_behavior = "CRAWL_NEW_FOLDERS_ONLY"
  }

  schema_change_policy {
    update_behavior = "LOG"
    delete_behavior = "LOG"
  }

  # Modo com update de schema automático, mas pode gerar custos maiores no crawler
  # schema_change_policy {
  #   update_behavior = "UPDATE_IN_DATABASE"
  #   delete_behavior = "LOG"
  # }
}
