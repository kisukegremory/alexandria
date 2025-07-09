resource "aws_s3_bucket" "this" {
  bucket        = "nina-bucket-${var.project_name}"
  force_destroy = true
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

####### Optional
# # Bucket versioning
# resource "aws_s3_bucket_versioning" "this" {
#   bucket = aws_s3_bucket.this.id
#   versioning_configuration {
#     status = "Enabled" # To we not lose any version of the states
#   }
# }

# # Bucket encryption
# resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
#   bucket = aws_s3_bucket.this.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # Bucket lifecycle
# resource "aws_s3_bucket_lifecycle_configuration" "this" {
#   # Must have bucket versioning enabled first
#   depends_on = [aws_s3_bucket_versioning.this]

#   bucket = aws_s3_bucket.this.id

#   rule {
#     id = "Tier optimization"

#     transition {
#       days          = 60
#       storage_class = "INTELLIGENT_TIERING"
#     }

#     noncurrent_version_expiration {
#       noncurrent_days = 7
#     }

#     status = "Enabled"
#   }
# }