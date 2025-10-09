output "rds" {
  value = {
    endpoint = aws_db_instance.this.endpoint
  }
}