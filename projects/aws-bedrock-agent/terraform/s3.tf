resource "aws_s3_bucket" "docs" {
  bucket_prefix = "${local.project_name}-docs-"
  force_destroy = true
}
