resource "aws_db_subnet_group" "this" {
  name       = "${local.project_name}-rds_subnet_group"
  subnet_ids = data.aws_subnets.default.ids
}


resource "aws_db_instance" "this" {
  instance_class         = "db.t4g.micro"
  identifier             = "${local.project_name}-db"
  storage_type           = "gp2"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.1"
  db_name                = "metabaseappdb"
  username               = "metabase"
  password               = "mysecretpassword"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [module.sg.rds_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  apply_immediately      = true
}

output "rds_host" {
  value = aws_db_instance.this.address
}