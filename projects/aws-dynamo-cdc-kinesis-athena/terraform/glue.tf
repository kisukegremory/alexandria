# O Database no Athena/Glue
resource "aws_glue_catalog_database" "this" {
  name = "${local.project_name}-db"
}

# A Tabela que define o Schema para o Firehose (Contrato)
resource "aws_glue_catalog_table" "this" {
  name          = "user_events"
  database_name = aws_glue_catalog_database.this.name

  table_type = "EXTERNAL_TABLE"

  # ADICIONAMOS A DEFINIÇÃO DAS PARTIÇÕES AQUI
  partition_keys {
    name = "ano"
    type = "string"
  }
  partition_keys {
    name = "mes"
    type = "string"
  }
  partition_keys {
    name = "dia"
    type = "string"
  }

  parameters = {
    # ATIVAMOS O PARTITION PROJECTION
    "projection.enabled" = "true"

    # Ensinamos como o Athena deve projetar os anos
    "projection.ano.type"  = "integer"
    "projection.ano.range" = "2024,2030"

    # Ensinamos os meses
    "projection.mes.type"   = "integer"
    "projection.mes.range"  = "01,12"
    "projection.mes.digits" = "2" # Garante que março seja 03 e não 3

    # Ensinamos os dias
    "projection.dia.type"   = "integer"
    "projection.dia.range"  = "01,31"
    "projection.dia.digits" = "2"

    # Mostra o formato final do S3
    "storage.location.template" = "s3://${aws_s3_bucket.this.bucket}/${local.data_prefix}/ano=$${ano}/mes=$${mes}/dia=$${dia}"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.this.bucket}/${local.data_prefix}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    # Aqui você define as colunas que leriamos no analytics, ou seja, o contrato do que o Firehose vai enviar para o S3 e o Athena vai ler
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "event_type"
      type = "string"
    }
    columns {
      name = "timestamp"
      type = "string"
    }
  }
}

output "glue_database" {
  description = "O banco de dados do Glue/Athena"
  value       = aws_glue_catalog_database.this.name
}
