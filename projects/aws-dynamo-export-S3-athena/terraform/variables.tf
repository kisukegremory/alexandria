variable "create_one_off_table" {
  description = "Flag para criar a tabela one-off no Glue. Deve ser true apenas na primeira execução, para garantir que o export já tenha rodado e gerado os hashes necessários."
  type        = bool
  default     = true
}

variable "one_off_hash" {
  type    = string
  default = "01773518422993-b2efcc1b" # Substitua pelo hash gerado na primeira execução do export. Você pode encontrar esse hash olhando no S3 após rodar a State Machine pela primeira vez.
}
