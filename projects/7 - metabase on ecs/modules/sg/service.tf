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

output "service_id" {
  value = aws_security_group.lb.id
}