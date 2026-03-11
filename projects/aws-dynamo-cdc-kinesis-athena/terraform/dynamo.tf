resource "aws_dynamodb_table" "this" {
  name         = "${local.project_name}-user-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  attribute {
    name = "user_id"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES" # envia tanto o dado antigo quanto o novo para o Firehose
}
