resource "aws_security_group" "ec2" {
  name = "${local.project_name}-ec2-sg"
  description = "Allow inbound traffic for load balancer"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_egress_rule" "ec2" {
  cidr_ipv4 = "0.0.0.0/0"
  security_group_id = aws_security_group.ec2.id
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "ec2" {
  ip_protocol = "-1"
  referenced_security_group_id = data.aws_security_group.load_balancer.id
  security_group_id = aws_security_group.ec2.id
}