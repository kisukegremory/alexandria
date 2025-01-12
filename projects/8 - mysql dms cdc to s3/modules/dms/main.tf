resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "ninadb-replication-subnet-group"
  replication_subnet_group_description = "Subnet group for replication"
  subnet_ids                           = var.subnet_ids
}


resource "aws_dms_replication_instance" "test" {
  apply_immediately            = true
  allocated_storage            = 20
  replication_instance_class   = "dms.t2.micro"
  engine_version               = "3.5.2"
  multi_az                     = false
  publicly_accessible          = true
  replication_instance_id      = "ninadb-dms-replication-instance"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.this.id
  vpc_security_group_ids = [var.security_group_id]

}