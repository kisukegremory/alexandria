

resource "aws_s3_bucket" "this" {
  bucket        = "${local.project_name}-bucket"
  force_destroy = true
}