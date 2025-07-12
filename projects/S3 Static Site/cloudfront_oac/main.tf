terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "./cloudfront_oac.tfstate"
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

resource "aws_cloudfront_origin_access_control" "this" {
  name = "oac-${data.terraform_remote_state.bucket.outputs.bucket_id}"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  origin {
    domain_name = data.terraform_remote_state.bucket.outputs.bucket_regional_domain_name
    origin_id = aws_cloudfront_origin_access_control.this.id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_control.this.id
    viewer_protocol_policy = "redirect-to-https"
    
  default_ttl = 300
  max_ttl = 3600
  min_ttl = 300

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

