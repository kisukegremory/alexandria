variable "project_name" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "port" {
  type = number
}

variable "vpc_id" {
  type = string
}