resource "aws_security_group" "rds" {
  name        = "rds_sg"
  description = "Allow TLS inbound traffic for DB and all outbound traffic"
  vpc_id      = aws_default_vpc.this.id
}


resource "aws_vpc_security_group_ingress_rule" "rds" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0" # allow to all ips
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0" # allow to all ips
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
}