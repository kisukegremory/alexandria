# 2. Define um recurso (o caminho '/external')
resource "aws_api_gateway_resource" "external_resource" {
  rest_api_id = aws_api_gateway_rest_api.http_api.id
  parent_id   = aws_api_gateway_rest_api.http_api.root_resource_id # Raiz da API
  path_part   = "external" # O caminho será /external
}

# 3. Define um método HTTP (GET) para o recurso
resource "aws_api_gateway_method" "external_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.http_api.id
  resource_id   = aws_api_gateway_resource.external_resource.id
  http_method   = "GET"
  authorization = "NONE" # Nenhuma autorização
}

# 4. Define a integração (backend) para o método usando HTTP_PROXY
resource "aws_api_gateway_integration" "http_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.http_api.id
  resource_id             = aws_api_gateway_resource.external_resource.id
  http_method             = aws_api_gateway_method.external_get_method.http_method
  
  type                    = "HTTP_PROXY"                 # <<-- Tipo de integração HTTP Proxy
  integration_http_method = "GET"                        # O método a ser usado no backend
  uri                     = "https://ip-ranges.amazonaws.com/ip-ranges.json" # <<-- O URL de destino
}
