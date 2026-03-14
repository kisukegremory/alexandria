resource "aws_athena_workgroup" "this" {
  name = "${local.project_name}-workgroup-${random_id.bucket_suffix.hex}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${aws_s3_bucket.this.bucket}/${local.queries_prefix}/"
    }
  }

  force_destroy = true
}


output "athena_workgroup" {
  description = "O nome do Workgroup do Athena"
  value       = aws_athena_workgroup.this.name
}
