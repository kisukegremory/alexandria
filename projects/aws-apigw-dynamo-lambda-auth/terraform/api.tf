resource "aws_api_gateway_rest_api" "this" {
  name = "${local.project_name}-api"
}

resource "aws_api_gateway_request_validator" "this" {
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  name                        = "${local.project_name}-request-validator-body"
  validate_request_body       = true
  validate_request_parameters = false

}

resource "aws_api_gateway_model" "this" {
  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = "dumpModel"
  content_type = "application/json"
  schema = jsonencode({
    type     = "object"
    required = ["id", "event_type", "payload"]
    properties = {
      id         = { type = "string" }
      event_type = { type = "string" }
      payload    = { type = "object" }
    }
  })
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_method" "this" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.this.id
  http_method          = "POST"
  authorization        = "CUSTOM"
  authorizer_id        = aws_api_gateway_authorizer.custom_authorizer.id
  request_validator_id = aws_api_gateway_request_validator.this.id
  request_models = {
    "application/json" = aws_api_gateway_model.this.name
  }
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.region}:dynamodb:action/PutItem"
  credentials             = aws_iam_role.apigw_dynamo.arn

  request_templates = {
    "application/json" = <<EOF
    {
        "TableName": "${aws_dynamodb_table.this.name}",
        "Item": {
            "id": {
                "S": "$input.path('$.id')"
            },
            "event_type": {
                "S": "$input.path('$.event_type')"
            },
            "payload": {
                "S": "$util.escapeJavaScript($input.json('$.payload'))"
            },
            "created_at": {
                "S": "$context.requestTimeEpoch"
            }
        }
    }
    EOF
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

  # Esse trigger força um novo deploy sempre que você alterar rotas ou integrações
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this.id,
      aws_api_gateway_method.this.id,
      aws_api_gateway_integration.this.id,
      aws_api_gateway_integration.this.request_templates,
      aws_api_gateway_authorizer.custom_authorizer.id,
      data.archive_file.authorizer_zip.output_base64sha256
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "v1"
}

# Output para te dar a URL pronta no terminal após o apply
output "api_url" {
  value = "${aws_api_gateway_stage.this.invoke_url}/${aws_api_gateway_resource.this.path_part}"
}
