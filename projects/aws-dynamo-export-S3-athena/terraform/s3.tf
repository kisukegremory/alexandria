resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "this" {
  bucket        = "alexandria-${local.project_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

locals {
  data_prefix    = "events"
  error_prefix   = "errors"
  queries_prefix = "queries"
}

resource "aws_s3_bucket_lifecycle_configuration" "cleanup_old_dumps" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "cleanup-old-one-off-dumps"
    status = "Enabled"

    # O Filtro garante que ele só vai apagar as coisas dentro dessa pasta específica
    # Ele não vai apagar a pasta "queries_output" do Athena, por exemplo.
    filter {
      prefix = "${local.data_prefix}/daily_dump/AWSDynamoDB/"
    }

    # A Ação: Expirar (deletar permanentemente) após 3 dias
    expiration {
      days = 3
    }

    # Bônus: limpa também uploads multipartes que falharam no meio do caminho
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}


output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
