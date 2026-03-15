
# O Table no Athena/Glue -> ONEOFF
resource "aws_glue_catalog_table" "one_off" {

  name          = "oneoff" # somente olhará para um dos hashes gerados pelo export, então é mais um teste do que algo dinâmico
  database_name = aws_glue_catalog_database.this.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    # Diz ao Athena que o dado está compactado nativamente pelo DynamoDB
    "compressionType" = "gzip"
    "classification"  = "ion"
  }

  storage_descriptor {
    # Você precisa apontar para a subpasta "data/" dentro do Hash gerado
    # Exemplo: "s3://alexandria-dynamo-export-.../events/daily_dump/AWSDynamoDB/0123456789-hash/data/"
    location = "s3://${aws_s3_bucket.this.bucket}/${local.data_prefix}/daily_dump/AWSDynamoDB/*/data/" # Mude para o seu primeiro hash gerado na primeira run do export

    # As bibliotecas nativas do ION na AWS
    input_format  = "com.amazon.ionhiveserde.formats.IonInputFormat"
    output_format = "com.amazon.ionhiveserde.formats.IonOutputFormat"

    ser_de_info {
      serialization_library = "com.amazon.ionhiveserde.IonHiveSerDe"
    }

    # Só precisamos declarar as colunas finais. O ION resolve a tipagem!
    columns {
      name = "item"
      type = "struct<user_id:string,name:string,plan:string,is_active:boolean>"
    }
  }

  lifecycle {
    ignore_changes = [storage_descriptor[0].location]
  }
}


resource "aws_iam_role" "sfn_oneoff_role" {
  name = "${local.project_name}-sfn-oneoff-role"
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


data "aws_iam_policy_document" "sfn_oneoff_policy" {
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
      "s3:GetObject" # Athena usage
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution" # Necessário por causa do ".sync" no Step Functions
    ]
    resources = [
      "arn:aws:athena:*:*:workgroup/*" # Permite rodar no workgroup padrão ('primary')
    ]
  }

  statement {
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:UpdateTable"
    ]
    resources = [
      "arn:aws:glue:*:*:catalog",
      aws_glue_catalog_database.this.arn,
      aws_glue_catalog_table.one_off.arn
    ]
  }
}

resource "aws_iam_role_policy" "sfn_oneoff_policy" {
  name   = "${local.project_name}-sfn-oneoff-policy"
  role   = aws_iam_role.sfn_oneoff_role.id
  policy = data.aws_iam_policy_document.sfn_oneoff_policy.json
}


resource "aws_sfn_state_machine" "one_off_export" {
  name     = "${local.project_name}-sfnmachine-oneoff"
  role_arn = aws_iam_role.sfn_oneoff_role.arn

  definition = jsonencode({
    Comment = "State machine to export DynamoDB table to S3"
    StartAt = "ExportTable" # O nome do estado inicial deve ser o mesmo do estado definido no bloco
    States = {
      # PASSO 1: Inicia o Export (Assíncrono)
      ExportTable = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:dynamodb:exportTableToPointInTime" # O recurso específico para exportar a tabela do DynamoDB
        Parameters = {
          TableArn     = aws_dynamodb_table.this.arn
          S3Bucket     = aws_s3_bucket.this.bucket
          S3Prefix     = "${local.data_prefix}/daily_dump/"
          ExportFormat = "ION" # Se for "DYNAMODB_JSON", virá aquele "S" para os tipos de dados. O ION é mais leve e fácil de consultar no Athena
        },
        ResultPath = "$.exportResult", # Salva o ExportArn aqui para usarmos depois
        Next       = "WaitState"
      }
      # PASSO 2: Dorme por 2 minutos (Dynamo demora um pouco para gerar o arquivo, então damos um tempo antes de perguntar se já está pronto)
      WaitState = {
        Type    = "Wait",
        Seconds = 120,
        Next    = "CheckExportStatus"
      },

      # PASSO 3: Pergunta o Status atual
      CheckExportStatus = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:dynamodb:describeExport",
        Parameters = {
          "ExportArn.$" = "$.exportResult.ExportDescription.ExportArn"
        },
        ResultPath = "$.statusResult",
        Next       = "IsExportDone"
      },

      # PASSO 4: Toma a decisão (O Switch/Case)
      IsExportDone = {
        Type = "Choice",
        Choices = [
          {
            Variable     = "$.statusResult.ExportDescription.ExportStatus",
            StringEquals = "COMPLETED",
            Next         = "ExtractHash" # Se acabou, vai pro Crawler
          },
          {
            Variable     = "$.statusResult.ExportDescription.ExportStatus",
            StringEquals = "IN_PROGRESS",
            Next         = "WaitState" # Se não acabou, volta a dormir
          }
        ],
        Default = "ExportFailed" # Se for FAILED ou qualquer outra coisa, quebra.
      },

      # PASSO 5: isolar o Hash dinâmico do ARN
      ExtractHash = {
        Type = "Pass"
        Parameters = {
          # Corta a string arn:aws:dynamodb:us-east-1:12345:table/NOME_DA_TABELA/export/HASH_FINAL e pega só o HASH_FINAL usando as funções nativas do Step Functions
          "hash.$" = "States.ArrayGetItem(States.StringSplit($.statusResult.ExportDescription.ExportArn, '/'), 3)"
        }
        ResultPath = "$.extracted"
        Next       = "UpdateAthenaLocation"
      }

      # PASSO 6: Roda a query no Athena para alterar a localização da tabela e espera terminar (.sync)
      UpdateAthenaLocation = {
        Type     = "Task"
        Resource = "arn:aws:states:::athena:startQueryExecution.sync"
        Parameters = {
          # Montamos o comando DDL injetando o Hash extraído no passo anterior
          "QueryString.$" = "States.Format('ALTER TABLE `${aws_glue_catalog_database.this.name}`.`${aws_glue_catalog_table.one_off.name}` SET LOCATION \\'s3://${aws_s3_bucket.this.bucket}/${local.data_prefix}/daily_dump/AWSDynamoDB/{}/data/\\';', $.extracted.hash)"
          # O Athena exige um diretório de output mesmo para queries DDL
          ResultConfiguration = {
            OutputLocation = "s3://${aws_s3_bucket.this.bucket}/${local.queries_prefix}/"
          }
        }
        End = true
      }

      # PASSO DE ERRO
      ExportFailed = {
        Type  = "Fail"
        Cause = "DynamoDB Export Falhou"
        Error = "ExportFailedError"
      }
    },
  })
}


