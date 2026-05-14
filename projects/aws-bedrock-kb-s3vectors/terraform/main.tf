resource "aws_s3vectors_vector_bucket" "vectors" {
  vector_bucket_name = "${local.project_name}-vector-bucket"
}

resource "aws_s3_bucket" "docs" {
  bucket = "${local.project_name}-docs-bucket"
}

resource "aws_s3vectors_index" "this" {
  vector_bucket_name = aws_s3vectors_vector_bucket.vectors.vector_bucket_name
  data_type          = "float32"
  dimension          = 1024 # quantidade de floats no victor
  distance_metric    = "cosine"
  index_name         = "kb-index"
}

