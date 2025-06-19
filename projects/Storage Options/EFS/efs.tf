resource "aws_security_group" "efs" {
  name   = "${local.project_name}-efs-sg"
  vpc_id = data.aws_vpc.default.id
}


resource "aws_vpc_security_group_ingress_rule" "efs-ingress" {
  security_group_id            = aws_security_group.efs.id
  referenced_security_group_id = aws_security_group.ec2.id
  ip_protocol                  = "tcp"
  from_port                    = 2049 # NFS Port
  to_port                      = 2049
}

resource "aws_vpc_security_group_egress_rule" "efs-egress" {
  security_group_id = aws_security_group.efs.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
}

resource "aws_efs_file_system" "this" {
  creation_token   = local.project_name
  performance_mode = "generalPurpose"
  encrypted        = true
  throughput_mode  = "bursting"
  #   availability_zone_name = "us-east-1a" # Single AZ! if applied we can just mount on the same AZ
  tags = {
    Name = "${local.project_name}-efs"
  }
  # Not usage of lifecycle!
}

resource "aws_efs_mount_target" "az-a" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = data.aws_subnet.az-a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "az-b" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = data.aws_subnet.az-b.id
  security_groups = [aws_security_group.efs.id]
}