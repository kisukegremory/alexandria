data "aws_vpc" "default" {
  default = true
}

# Get only public subnets
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name = "map-public-ip-on-launch" 
    values = [true]
  }
}

# Get only public subnet on that AZ
data "aws_subnet" "az-a" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
  filter {
    name = "map-public-ip-on-launch" 
    values = [true]
  }
}

data "aws_security_group" "load_balancer" {
  id = var.lb_sg
}