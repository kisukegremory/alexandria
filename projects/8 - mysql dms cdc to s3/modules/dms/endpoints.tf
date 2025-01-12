resource "aws_dms_endpoint" "rds_source" {
  endpoint_type = "source"
  endpoint_id   = "ninadb"
  engine_name   = "mysql"
  server_name   = var.db_config["address"]
  database_name = var.db_config["dbname"]
  username      = var.db_config["username"]
  password      = var.db_config["password"]
  port          = 3306

}


