resource "aws_security_group" "lb" {
  name        = "nina-lb-sg"
  description = "allow inbound on port 80 and all for outbound"
}


resource "aws_vpc_security_group_ingress_rule" "lb" {
  security_group_id = aws_security_group.lb.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "lb" {
  security_group_id = aws_security_group.lb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "service" {
  name        = "nina-service-sg"
  description = "Allow inbound traffic from nina-lb-sg cidr"
}

resource "aws_vpc_security_group_ingress_rule" "service" {
  security_group_id            = aws_security_group.service.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.lb.id
}

resource "aws_vpc_security_group_egress_rule" "service" {
  security_group_id = aws_security_group.service.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}