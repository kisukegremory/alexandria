output "endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "Endpoint to connect to the database"
}