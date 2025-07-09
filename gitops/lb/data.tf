data "aws_vpc" "default" {
  filter {
    name = "tag:Name"
    values = ["nina-vpc"]
  }
}

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

data "aws_acm_certificate" "this" {
    domain = "nina.live"
}