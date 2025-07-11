terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "./bucket.tfstate"
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

# Bucket needs to be unique
resource "random_string" "this" {
  length = 8  
  min_numeric = 8
}

resource "aws_s3_bucket" "this" {
  bucket = "nina-static-${random_string.this.result}"
  force_destroy = true
}


output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}