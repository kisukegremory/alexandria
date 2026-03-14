resource "aws_dynamodb_table" "this" {
  name         = "${local.project_name}-user-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  attribute {
    name = "user_id"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }

}

output "table_name" {
  value = aws_dynamodb_table.this.name
}
