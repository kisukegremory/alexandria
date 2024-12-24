# DMS With Terraform


Demonstrar o como realizar uma migração com o DMS baseando a infraestrutura no terraform, para isso precisaremos de:

1. um rds, como nossa fonte de dados
2. um script para popular nossa base de dados
3. criar o serviço de migração para o S3