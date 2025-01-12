variable "bucket" {
  type = map(string)
  default = {
    "id"   = "..."
    "name" = "..."
    "arn"  = "..."
  }
}

resource "aws_dms_s3_endpoint" "target" {
  endpoint_type           = "target"
  endpoint_id             = var.bucket["id"]
  bucket_name             = var.bucket["name"]
  service_access_role_arn = aws_iam_role.this.arn
}