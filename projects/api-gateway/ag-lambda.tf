resource "aws_api_gateway_resource" "lambda" {
    rest_api_id = aws_api_gateway_rest_api.http_api.id
    parent_id = aws_api_gateway_rest_api.http_api.root_resource_id
    path_part = "lambda"
}

resource "aws_api_gateway_method" "lambda" {
    rest_api_id = aws_api_gateway_rest_api.http_api.id
    resource_id = aws_api_gateway_resource.lambda.id
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
    rest_api_id = aws_api_gateway_rest_api.http_api.id
    resource_id = aws_api_gateway_resource.lambda.id
    http_method = aws_api_gateway_method.lambda.http_method
    type = "AWS_PROXY"
    integration_http_method = "POST"
    uri = aws_lambda_function.this.invoke_arn
    passthrough_behavior = "WHEN_NO_TEMPLATES"

}