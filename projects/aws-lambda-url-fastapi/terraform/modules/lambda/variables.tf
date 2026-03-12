variable "project_name" {
  description = "Base name to resources as a prefix"
}

variable "commom_tags" {
  description = "commom tags"
}

variable "iam_role_arn" {
  description = "iam role to be used on lambda"
}

variable "image_uri" {
  description = "docker image uri from ecr to be used on lambda"
}

variable "timeout" {
  default     = 120
  description = "lambda timeout"
}

variable "memory_size" {
  default     = 1024
  description = "lambda memory size"
}