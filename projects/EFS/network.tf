data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "first" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
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
