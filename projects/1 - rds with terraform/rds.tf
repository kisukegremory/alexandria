resource "aws_db_subnet_group" "this" {
  name       = "rds_subnet_group"
  subnet_ids = data.aws_subnets.this.ids
  tags       = local.common_tags
}


resource "aws_db_instance" "this" {
  db_name                = "ninadb"
  instance_class         = "db.t4g.micro"
  identifier             = "ninadb"
  storage_type           = "gp2"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.39"
  username               = "admin"
  password               = "nininha11"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  tags                   = local.common_tags
  apply_immediately      = true
}