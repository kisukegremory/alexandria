data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nina-terraform-tfstates"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "lb" {
  backend = "s3"
  config = {
    bucket         = "nina-terraform-tfstates"
    key            = "load-balancer"
    region         = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket         = "nina-terraform-tfstates"
    key            = "ecs-cluster.tfstate"
    region         = "us-east-1"
  }
}

data "aws_route53_zone" "live" {
  name         = "nina.live"
  private_zone = false
}