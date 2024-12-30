data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.this.id]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "rds_subnet_group"
  subnet_ids = data.aws_subnets.this.ids
  tags       = local.common_tags
}

resource "aws_db_instance" "this" {
  allocated_storage      = 20       // ainda dentro do free tier
  db_name                = "ninadb" // alterando o nome do banco de dados
  engine                 = "mysql"
  engine_version         = "8.0.39"       // versão mais nova
  instance_class         = "db.t4g.micro" // t3.micro e t4g.micro estão no free tier
  username               = "admin"
  password               = "admin123"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = true     // torna a instância acessível publicamente
  identifier             = "ninadb" // identificador na aws e tambem vira prefixo do link de acesso ao db
  apply_immediately      = true     // não espera até a próxima janela de manutenção e aplica na hora as mudanças
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

output "endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "Endpoint para conectar ao banco de dados"
}