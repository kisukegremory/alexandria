resource "aws_efs_file_system" "this" {
  creation_token         = local.project_name
  performance_mode       = "generalPurpose"
  encrypted              = true
  throughput_mode        = "bursting"
  availability_zone_name = "us-east-1a" # Single AZ!
  # Not usage of lifecycle!
}