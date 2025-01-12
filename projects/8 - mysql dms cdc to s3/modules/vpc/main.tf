resource "aws_default_vpc" "this" {
  
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.this.id]
  }
}