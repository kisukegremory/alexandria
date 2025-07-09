resource "aws_security_group" "ecs" {
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  name        = "${var.project_name}-ecs-sg"
  description = "allow inbound on port 80 and all for outbound"
}

resource "aws_vpc_security_group_egress_rule" "ecs" {
  security_group_id = aws_security_group.ecs.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Permite todo tráfego que vier do LB
resource "aws_vpc_security_group_ingress_rule" "ecs" {
  ip_protocol = "-1"
  referenced_security_group_id = data.terraform_remote_state.lb.outputs.security_group_id
  security_group_id = aws_security_group.ecs.id
}