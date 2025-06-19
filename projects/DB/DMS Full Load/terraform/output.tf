output "endpoint" {
  value       = aws_db_instance.this.address
  description = "Endpoint to connect to the database"
}