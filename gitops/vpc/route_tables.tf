

####################### PUBLIC ROUTE TABLES #######################
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_a.id
  }
  tags = {
    "Name" = "${local.project_name}-public-a"
  }

}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_a.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_a.id
}



####################### PRIVATE ROUTE TABLES #######################
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = aws_vpc.this.cidr_block
    gateway_id = "local"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_a.id
  }
  tags = {
    "Name" = "${local.project_name}-private-a"
  }

}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}