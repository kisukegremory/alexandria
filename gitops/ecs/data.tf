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