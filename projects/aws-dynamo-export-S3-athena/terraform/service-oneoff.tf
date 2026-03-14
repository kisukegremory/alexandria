

resource "aws_sfn_state_machine" "one_off_export" {
  name     = "${local.project_name}-sfnmachine-oneoff"
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


# O Table no Athena/Glue -> ONEOFF
resource "aws_glue_catalog_table" "one_off" {
  count = var.create_one_off_table ? 1 : 0 # Só cria a tabela depois que a State Machine for criada, para garantir que o export já tenha rodado pelo menos uma vez e gerado os hashes

  name          = "${local.project_name}-table-oneoff" # somente olhará para um dos hashes gerados pelo export, então é mais um teste do que algo dinâmico
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
    location = "s3://${aws_s3_bucket.this.bucket}/${local.data_prefix}/daily_dump/AWSDynamoDB/${var.one_off_hash}/data/" # Mude para o seu primeiro hash gerado na primeira run do export

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
}
