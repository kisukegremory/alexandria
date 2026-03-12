resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-rds_subnet_group"
  subnet_ids = var.subnet_ids
}


resource "aws_db_instance" "this" {
  instance_class         = "db.t4g.micro"
  identifier             = "${var.project_name}-db"
  storage_type           = "gp3"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.4"
  db_name                = "metabaseappdb"
  username               = "metabase"
  manage_master_user_password = true
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = var.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.this.name
  apply_immediately      = true
}

output "rds_host" {
  value = aws_db_instance.this.address
}