data "aws_subnets" "this" {
  
}

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

data "aws_region" "current" {
  
}

data "aws_caller_identity" "current" {
  
}