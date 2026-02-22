variable "service_name" {
  description = "Nome do serviço a ser utilizado"
  type        = string
}

variable "endpoint_path" {
  description = "O Caminho do webhook na URl (ex: webhooks, events)"
  type        = string
}

variable "environment" {
  description = "Ambiente onde o webhook será utilizado (ex: dev, stg, prd)"
  type        = string
  default     = "dev"
}

variable "required_api_key" {
  description = "Indica se o webhook exigirá a chave nativa do API Gateway para autenticação"
  type        = bool
  default     = false
}



