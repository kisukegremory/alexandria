
resource "aws_security_group" "rds" {
  name        = "nina-rds-sg"
  description = "Allow TLS inbound traffic for DB and all outbound traffic"
}


resource "aws_vpc_security_group_ingress_rule" "rds" {
  security_group_id = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.lb.id
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0" # allow to all ips
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"

}

output "rds_id" {
  value = aws_security_group.lb.id
}