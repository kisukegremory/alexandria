resource "aws_internet_gateway" "public_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${local.project_name}-igw-public-a"
  }
}