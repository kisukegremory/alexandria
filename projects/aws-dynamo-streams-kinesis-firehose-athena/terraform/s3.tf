resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "datalake" {
  bucket        = "alexandria-${local.project_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

locals {
  data_prefix    = "users_events"
  error_prefix   = "errors"
  queries_prefix = "queries"
}

output "bucket_name" {
  value = aws_s3_bucket.datalake.bucket
}
