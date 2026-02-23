resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.service_name}-webhook-api-${var.environment}"
  description = "API Gateway para proxy de webhooks do serviço ${var.service_name} no ambiente ${var.environment}"
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.endpoint_path
}

resource "aws_api_gateway_method" "this" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.this.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = var.required_api_key
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = aws_iam_role.apigw_sqs_role.arn
  uri                     = "arn:aws:apigateway:${data.aws_region.current.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.this.name}"
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$util.urlEncode($input.body)"
  }
}

resource "aws_api_gateway_method_response" "status_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "status_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = aws_api_gateway_method_response.status_200.status_code

  depends_on = [aws_api_gateway_integration.this]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.this,
      aws_api_gateway_resource.this,
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
      aws_api_gateway_method_response.status_200,
      aws_api_gateway_integration_response.status_200,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.environment
}
