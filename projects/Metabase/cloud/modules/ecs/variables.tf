variable "project_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "port" {
  type = number  
}
