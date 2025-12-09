resource "aws_secretsmanager_secret" "this" {
  name = "${local.project_name}-password"
}

resource "random_password" "this" {
  length  = 32
  special = false
  numeric = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = random_password.this.result
}