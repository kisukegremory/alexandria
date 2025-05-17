resource "aws_efs_file_system" "this" {
  creation_token         = local.project_name
  performance_mode       = "generalPurpose"
  encrypted              = true
  throughput_mode        = "bursting"
  availability_zone_name = "us-east-1a" # Single AZ!
  tags = {
    Name = "${local.project_name}-efs"
  }
  # Not usage of lifecycle!
}

resource "aws_efs_mount_target" "first" {
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = data.aws_subnet.first.id
  security_groups = [aws_security_group.efs.id]
}