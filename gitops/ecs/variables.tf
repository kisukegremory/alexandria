variable "project_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type        = string
  description = "prod, dev"
}