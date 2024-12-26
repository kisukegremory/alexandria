

resource "aws_s3_bucket" "this" {
  bucket        = local.project_name
  force_destroy = true
}