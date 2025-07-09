resource "aws_security_group" "lb" {
  vpc_id = data.aws_vpc.default.id
  name        = "${local.project_name}-lb-sg"
  description = "allow inbound on port 80 and all for outbound"
}


resource "aws_vpc_security_group_ingress_rule" "lb" {
  security_group_id = aws_security_group.lb.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.lb.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "lb" {
  security_group_id = aws_security_group.lb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}