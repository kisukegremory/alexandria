data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "ec2" {
  name   = "${local.project_name}-ec2-sg"
  vpc_id = data.aws_vpc.default.id
}


# # To Get My Public IP
# data "http" "my_public_ip" {
#   url = "https://ifconfig.co/json"
#   request_headers = {
#     Accept = "application/json"
#   }
# }

# locals {
#   my_public_ip = jsondecode(data.http.my_public_ip.response_body).ip
# }

# resource "aws_vpc_security_group_ingress_rule" "ec2-ingress" {
#   security_group_id = aws_security_group.ec2.id
#   cidr_ipv4         = "${local.my_public_ip}/32" # My IP
#   ip_protocol       = "tcp"
#   from_port         = 22
#   to_port           = 22
# }

resource "aws_vpc_security_group_egress_rule" "ec2-egress" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
}

resource "aws_security_group" "efs" {
  name   = "${local.project_name}-efs-sg"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "efs-ingress" {
  security_group_id            = aws_security_group.efs.id
  referenced_security_group_id = aws_security_group.ec2.id
  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
}

resource "aws_vpc_security_group_egress_rule" "efs-egress" {
  security_group_id = aws_security_group.efs.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
}


