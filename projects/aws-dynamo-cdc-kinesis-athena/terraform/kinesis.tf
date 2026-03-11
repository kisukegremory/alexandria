
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# IAM ROLE PARA O FIREHOSE
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "firehose" {
  name               = "alexandria-firehose-role-${local.project_name}"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}


# ------------------------------------------------------------------------------
# PERMISSÕES DO FIREHOSE (S3 e Glue)
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "firehose_policy" {
  # Permissão para gravar e listar no S3
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [
      aws_s3_bucket.datalake.arn,
    ]
  }
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.datalake.arn}/*"
    ]
  }

  # Permissão para ler o Schema da tabela no Glue
  statement {
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions"
    ]
    resources = [
      "arn:aws:glue:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:catalog",
      aws_glue_catalog_database.analytics.arn,
      aws_glue_catalog_table.dynamo_events.arn
    ]
  }
}

resource "aws_iam_role_policy" "firehose" {
  name   = "alexandria-firehose-policy"
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose_policy.json
}



resource "aws_kinesis_firehose_delivery_stream" "to_datalake" {
  name        = "alexandria-dynamo-to-s3-parquet"
  destination = "extended_s3"
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.datalake.arn

    # particionamento (avaliar conforme o volume de dados, pode ser interessante particionar por hora ou dia)
    prefix              = "${local.data_prefix}/ano=!{timestamp:yyyy}/mes=!{timestamp:MM}/dia=!{timestamp:dd}/"
    error_output_prefix = "${local.error_prefix}/ano=!{timestamp:yyyy}/mes=!{timestamp:MM}/dia=!{timestamp:dd}/!{firehose:error-output-type}/"

    buffering_interval = 60 # tempo máximo que o Firehose espera antes de enviar os dados para o S3 (em segundos)
    buffering_size     = 64 # tamanho máximo do buffer antes de enviar os dados para o S3 (em MB)


    data_format_conversion_configuration {
      schema_configuration {
        database_name = aws_glue_catalog_database.analytics.name
        table_name    = aws_glue_catalog_table.dynamo_events.name
        role_arn      = aws_iam_role.firehose.arn
      }

      input_format_configuration {
        deserializer {
          open_x_json_ser_de {
            convert_dots_in_json_keys_to_underscores = true # opcional, mas recomendado para evitar problemas com chaves que possuem pontos
          }
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {
            compression = "SNAPPY" # formato de compressão default para Parquet
          }
        }
      }
    }

  }



}
