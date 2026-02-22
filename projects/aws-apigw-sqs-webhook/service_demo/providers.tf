terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "nina"
  region  = "us-east-1"
}

module "billing_webhook" {
  source           = "../modules/webhook_proxy"
  service_name     = "billing"
  endpoint_path    = "stripe-events"
  environment      = "demo"
  required_api_key = true
}
