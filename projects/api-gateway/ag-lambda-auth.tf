resource "aws_api_gateway_resource" "auth_lambda" {
    rest_api_id = aws_api_gateway_rest_api.http_api.id
    parent_id = aws_api_gateway_rest_api.http_api.root_resource_id
    path_part = "auth"
}

resource "aws_api_gateway_method" "auth_lambda" {
    rest_api_id = aws_api_gateway_rest_api.http_api.id
    resource_id = aws_api_gateway_resource.auth_lambda.id
    http_method = "GET"
    authorization = "COGNITO_USER_POOLS"
    authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "auth_lambda" {
    rest_api_id = aws_api_gateway_rest_api.http_api.id
    resource_id = aws_api_gateway_resource.auth_lambda.id
    http_method = aws_api_gateway_method.auth_lambda.http_method
    type = "AWS_PROXY"
    integration_http_method = "POST"
    uri = aws_lambda_function.this.invoke_arn
    passthrough_behavior = "WHEN_NO_TEMPLATES"

}