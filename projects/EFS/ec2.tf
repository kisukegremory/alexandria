# Get the most recent Amazon Linux 2 AMI
data "aws_ami" "aws_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}


data "aws_subnet" "first" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "availability-zone"
    values = ["us-east-1a"]
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

resource "aws_instance" "first" {
  ami = data.aws_ami.aws_ami.id
  associate_public_ip_address = false
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id = data.aws_subnet.first.id
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    delete_on_termination = true

  }
  tags = {
    Name = "${local.project_name}-first"
  }

}