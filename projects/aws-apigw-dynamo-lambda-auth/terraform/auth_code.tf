data "archive_file" "authorizer_zip" {
  type        = "zip"
  source_file = "${path.module}/../artifacts/bootstrap"
  output_path = "${path.module}/../artifacts/authorizer.zip"
}


# # Apenas um dummy para o mock inicial passar, depois podemos implementar a lógica real do authorizer
# data "archive_file" "dummy_authorizer" {
#   type        = "zip"
#   output_path = "${path.module}/../artifacts/dummy_authorizer.zip"
#   source {
#     content  = "def lambda_handler(event, context):\n   raise Exception('Unauthorized')"
#     filename = "main.py"
#   }
# }

# # Authorizer via python inline code, para evitar ter que subir um arquivo separado para o mock inicial
# data "archive_file" "authorizer_python" {
#   type        = "zip"
#   output_path = "${path.module}/../artifacts/authorizer_python.zip"
#   source {
#     content  = <<-EOF
#       import json

#       def lambda_handler(event, context):
#           token = event['authorizationToken']
#           if token == 'allow':
#               return {
#                   'principalId': 'user',
#                   'policyDocument': {
#                       'Version': '2012-10-17',
#                       'Statement': [{
#                           'Action': 'execute-api:Invoke',
#                           'Effect': 'Allow',
#                           'Resource': event['methodArn']
#                       }]
#                   }
#               }
#           else:
#               raise Exception('Unauthorized')
#     EOF
#     filename = "main.py"
#   }

# }


