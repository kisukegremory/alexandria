resource "aws_elasticache_parameter_group" "this" {
  name   = "${local.project_name}-redis-params"
  family = "redis7" # Ajuste a família para a versão do Redis que você deseja usar.
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.project_name}-subnet-group"
  subnet_ids = data.aws_subnets.this.ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = local.project_name
  description          = "Redis cluster for ${local.project_name}"
  node_type            = "cache.t4g.micro"
  num_cache_clusters   = 1
  multi_az_enabled     = false
  # engine configuration
  engine                     = "redis"
  engine_version             = "7.1"
  parameter_group_name       = aws_elasticache_parameter_group.this.name
  auto_minor_version_upgrade = true
  # snapshot
  # final_snapshot_identifier = "${local.project_name}-snapshot"
  # snapshot_retention_limit  = 7
  # authentication
  transit_encryption_enabled = true
  transit_encryption_mode = "preferred"
  at_rest_encryption_enabled = true
  
  auth_token                 = aws_secretsmanager_secret_version.this.secret_string
  security_group_ids         = [aws_security_group.this.id]
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  apply_immediately = true
}