# Get the most recent Amazon Linux 2 AMI
data "aws_ami" "aws_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# resource "aws_ebs_volume" "first" {
#   availability_zone = "us-east-1a"
#   size              = 8
#   type = "gp3"

#   tags = {
#     Name = "${local.project_name}-first"
#   }
# }

data "aws_iam_role" "ec2_session_manager" {
  name = "AWSEC2SystemManagerRole"
}

resource "aws_security_group" "ec2" {
  name   = "${local.project_name}-ec2-sg"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_egress_rule" "ec2-egress" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
}


resource "aws_instance" "az-a" {
  ami                         = data.aws_ami.aws_ami.id
  associate_public_ip_address = true # Required for Session Manager with less configuration
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  subnet_id                   = data.aws_subnet.az-a.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name # Required for Session Manager with less configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true

  }
  tags = {
    Name = "${local.project_name}-az-a"
  }

  user_data = <<-EOT
  #!/bin/bash
  sudo -i
  sudo yum install -y amazon-efs-utils
  mkdir /data
  sudo mount -t efs -o tls ${aws_efs_file_system.this.id}:/ /data
  echo "$(date) Nina 1 estive aqui" >> /data/nina.log
  echo "$(date) Nina 1 estive aqui" >> /data/nina1.log
  EOT

}

resource "aws_instance" "az-b" {
  ami                         = data.aws_ami.aws_ami.id
  associate_public_ip_address = true # Required for Session Manager with less configuration
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  subnet_id                   = data.aws_subnet.az-b.id
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name # Required for Session Manager with less configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true

  }
  tags = {
    Name = "${local.project_name}-az-b"
  }

  user_data = <<-EOT
  #!/bin/bash
  sudo -i
  sudo yum install -y amazon-efs-utils
  mkdir /data
  sudo mount -t efs -o tls ${aws_efs_file_system.this.id}:/ /data
  echo "$(date) Nina 2 estive aqui" >> /data/nina.log
  echo "$(date) Nina 2 estive aqui" >> /data/nina2.log
  EOT

}
