resource "null_resource" "grant_rds_iam" {
  depends_on = [aws_db_instance.this]

  provisioner "local-exec" {
    command = <<-EOT
      export PGPASSWORD='${aws_db_instance.this.password}'
      psql -h ${aws_db_instance.this.address} -p 5432 -U ${aws_db_instance.this.username} -d postgres -c "
        CREATE USER iam_auth WITH LOGIN;
        GRANT rds_iam TO iam_auth;
        GRANT CREATE ON SCHEMA public TO iam_auth;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO iam_auth;
        GRANT ALL PRIVILEGES ON DATABASE postgres TO iam_auth;
      "
    EOT
    
    // Opcionalmente, você pode configurar o 'when' para só executar na criação
    when = create 
  }
}