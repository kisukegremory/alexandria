resource "aws_nat_gateway" "public_a" {
  allocation_id = data.aws_eip.public_a.id
  subnet_id     = aws_subnet.public_a.id
  tags = {
    "Name" = "${local.project_name}-nat-a"
  }
}