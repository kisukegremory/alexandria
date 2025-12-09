resource "aws_db_subnet_group" "this" {
  name       = "${local.project_name}-rds-subnet-group"
  subnet_ids = data.aws_subnets.this.ids
}


resource "aws_db_instance" "this" {
  instance_class         = "db.t4g.micro"
  identifier             = "${local.project_name}"
  storage_type           = "gp3"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.6"
  db_name                = "postgres"
  username               = "alexandriauser"
  parameter_group_name = "default.postgres17"
  storage_encrypted = true
  password               = "alexandria"
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.this.id]
  skip_final_snapshot = true
  db_subnet_group_name   = aws_db_subnet_group.this.name
  apply_immediately      = true
  iam_database_authentication_enabled = true # Our little project's Star!
}