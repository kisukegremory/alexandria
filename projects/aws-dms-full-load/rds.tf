data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.this.id]
  }
}

resource "aws_default_vpc" "this" {

}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow TLS inbound traffic for DB and all outbound traffic"
  vpc_id      = aws_default_vpc.this.id
  tags        = local.common_tags
}


resource "aws_vpc_security_group_ingress_rule" "allow_mysql_port" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0" # allow to all ips
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "name" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0" # allow to all ips
  from_port         = -1
  to_port           = -1
  ip_protocol       = "-1"
}


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
  password               = "admin"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  tags                   = local.common_tags
  apply_immediately      = true
}