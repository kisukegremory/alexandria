resource "aws_security_group" "this" {
  name        = "${local.project_name}-sg"
  description = "allow inbound on port 5432 and all for outbound"
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "this" {
    security_group_id = aws_security_group.this.id
    description = "Allow ingress connection for my ip only"
    ip_protocol       = "tcp"
    cidr_ipv4         = "${data.http.ip.response_body}/32"
    from_port         = 5432
    to_port           = 5432
}