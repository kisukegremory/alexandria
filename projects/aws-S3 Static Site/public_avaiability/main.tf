terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "./public_availability.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "ManagedBy" = "Terraform"
    }
  }
}


resource "aws_s3_bucket_website_configuration" "this" {
  bucket = data.terraform_remote_state.bucket.outputs.bucket_id

  index_document {
    suffix = "index.html"
  }

  depends_on = [ aws_s3_bucket_policy.this, aws_s3_bucket_public_access_block.this ]
}


output "site_url" {
  value = aws_s3_bucket_website_configuration.this.website_endpoint
  description = "value of website endpoint that we created!"
}