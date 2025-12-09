output "rds" {
  value = {
    endpoint = aws_db_instance.this.endpoint
  }
}


output "role" {
  description = "Role information required on awscli"
  value       = {
    arn = aws_iam_role.this.arn
    name = aws_iam_role.this.name
  }
}