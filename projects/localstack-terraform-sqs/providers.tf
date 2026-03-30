terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  # Configurações críticas para LocalStack
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    sqs = var.localstack_endpoint
  }
}


variable "localstack_endpoint" {
  description = "Endpoint URL for LocalStack SQS service(mudar para http://localstack:4566 se rodar via compose)"
  type        = string
  default     = "http://localhost:4566"
}
