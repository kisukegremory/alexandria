output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket" {
  value = {
    name = aws_s3_bucket.this.bucket
    id   = aws_s3_bucket.this.id
    arn  = aws_s3_bucket.this.arn
  }
}