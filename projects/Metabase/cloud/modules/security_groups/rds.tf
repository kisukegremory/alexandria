
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow TLS inbound traffic for DB and all outbound traffic"
}


resource "aws_vpc_security_group_ingress_rule" "rds" {
  security_group_id = aws_security_group.rds.id
  ip_protocol       = "tcp"
  referenced_security_group_id = aws_security_group.service.id
  from_port         = 5432
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "rds" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0" # allow to all ips
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"

}

output "rds_id" {
  value = aws_security_group.rds.id
}