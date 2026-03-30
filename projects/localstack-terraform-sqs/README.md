# LocalStack Terraform SQS!

Basicamente um projeto POC para:
- Testar o Localstack até a ultima versão que não precisa de token para de fato, usar.
- Rodar o Terraform apontado para o localstack
- Conseguir rodar o Terraform dentro do compose, para quem quiser utilizar não precisar ter o terraform instalado
- Criar uma fila SQS para comprovar que a conexão entre os 2 containers, funcionam