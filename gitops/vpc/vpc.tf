resource "aws_vpc" "this" {
  cidr_block           = "137.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = local.project_name
  }
}