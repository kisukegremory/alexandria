resource "aws_db_subnet_group" "this" {
  name       = "rds_subnet_group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "this" {
  family = "mysql8.0"
  name   = "mysql-cdc"
  parameter {
    name         = "binlog_format"
    value        = "ROW"
    apply_method = "immediate"
  }
}

resource "aws_db_instance" "this" {
  allocated_storage      = 20       // ainda dentro do free tier
  db_name                = "ninadb" // alterando o nome do banco de dados
  engine                 = "mysql"
  engine_version         = "8.0.39"       // versão mais nova
  instance_class         = "db.t4g.micro" // t3.micro e t4g.micro estão no free tier
  username               = "admin"
  password               = "admin123"
  parameter_group_name   = aws_db_parameter_group.this.name
  skip_final_snapshot    = true
  publicly_accessible    = true     // torna a instância acessível publicamente
  identifier             = "ninadb" // identificador na aws e tambem vira prefixo do link de acesso ao db
  apply_immediately      = true     // não espera até a próxima janela de manutenção e aplica na hora as mudanças
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
}

output "endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "Endpoint para conectar ao banco de dados"
}


output "db_config" {
  value = {
    address  = aws_db_instance.this.address
    dbname   = aws_db_instance.this.db_name
    username = aws_db_instance.this.username
    password = aws_db_instance.this.password
  }
}

# output "address" {
#   value = aws_db_instance.this.address
# }
# output "dbname" {
#   value = aws_db_instance.this.db_name
# }
# output "username" {
#   value = aws_db_instance.this.username
# }
# output "password" {
#   value = aws_db_instance.this.password
# }