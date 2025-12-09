resource "aws_cognito_user_pool" "this" {
  name = "${local.project_name}-user-pool"
}

resource "aws_cognito_user_pool_client" "this" {
  name = "${local.project_name}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.this.id
  generate_secret     = true
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}

# resource "aws_cognito_user_pool_client" "web" {
#   name = "${local.project_name}-web-user-pool-client"
#   user_pool_id = aws_cognito_user_pool.this.id
#   callback_urls = [ "localhost:8080" ]
#   logout_urls = [ "localhost:8080" ]
#   generate_secret = false
#   supported_identity_providers         = ["COGNITO"]
#   allowed_oauth_flows = ["code", "implicit"]
#   allowed_oauth_scopes = ["email", "openid", "profile"]
#   allowed_oauth_flows_user_pool_client = true
# }


# resource "aws_cognito_user_pool_domain" "this" {
#   user_pool_id = aws_cognito_user_pool.this.id
#   domain = "ag-auth"
# }