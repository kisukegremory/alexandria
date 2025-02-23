resource "aws_security_group" "dms" {
  name        = "dms_sg"
  description = "Allow all outbound traffic"
  vpc_id      = aws_default_vpc.this.id
}

resource "aws_vpc_security_group_egress_rule" "dms" {
  security_group_id = aws_security_group.dms.id
  cidr_ipv4         = "0.0.0.0/0" # allow to all ips
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
}