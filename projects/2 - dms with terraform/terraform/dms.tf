resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = local.project_name
  replication_subnet_group_description = "Subnet group for replication of ${local.project_name}"
  subnet_ids                           = data.aws_subnets.this.ids
  tags                                 = local.common_tags
}


resource "aws_dms_replication_instance" "test" {
  apply_immediately            = true
  allocated_storage            = 20
  replication_instance_class   = "dms.t2.micro"
  engine_version               = "3.5.2"
  multi_az                     = false
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible          = true
  replication_instance_id      = local.project_name
  replication_subnet_group_id  = aws_dms_replication_subnet_group.this.id
  tags                         = local.common_tags


  vpc_security_group_ids = [data.aws_security_group.default.id]

  depends_on = [
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
}


resource "aws_dms_endpoint" "rds_source" {
  endpoint_type = "source"
  endpoint_id   = "ninadb"
  engine_name   = "mysql"
  server_name   = aws_db_instance.this.address
  database_name = "production"
  username      = aws_db_instance.this.username
  password      = aws_db_instance.this.password
  port          = 3306
  tags          = local.common_tags

}

resource "aws_dms_s3_endpoint" "target" {
  endpoint_type = "target"
  endpoint_id   = aws_s3_bucket.this.id
  bucket_name = aws_s3_bucket.this.bucket
  service_access_role_arn = aws_iam_role.dms-access-for-endpoint.arn
  tags = local.common_tags
}