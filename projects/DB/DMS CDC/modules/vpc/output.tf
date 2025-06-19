output "vpc_id" {
  value = aws_default_vpc.this.id
}

output "subnet_ids" {
  value = data.aws_subnets.this.ids
}

output "sg_rds_id" {
  value = aws_security_group.rds.id
}

output "sg_dms_id" {
  value = aws_security_group.dms.id
}