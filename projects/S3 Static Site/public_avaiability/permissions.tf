resource "aws_s3_bucket_public_access_block" "this" {
  bucket = data.terraform_remote_state.bucket.outputs.bucket_id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "this" {
  bucket = data.terraform_remote_state.bucket.outputs.bucket_id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource = [
          "${data.terraform_remote_state.bucket.outputs.bucket_arn}/*",
        ]
      }
    ]
  })

  depends_on = [ aws_s3_bucket_public_access_block.this ]
}
