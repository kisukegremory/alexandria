# DMS With Terraform


Demonstrar o como realizar uma migração com o DMS baseando a infraestrutura no terraform, para isso precisaremos de:

1. um rds, como nossa fonte de dados
2. um script para popular nossa base de dados
3. criar o serviço de migração para o S3


# Como rodar?
1. Criar toda a infraestrutura ao redor do projeto, vá até a pasta terraform e aplique o comando `terraform init` e `terraform apply`
2. Adicione a variável DB_URI dentro do .env ou nas variáveis de ambientes, com o valor DB_URL=mysql+mysqlconnector://{username}:{password}@{host}:{port}/{database}
3. Popule o DB com os dados fake com o script python `poetry run python migration.py`
4. Abra o console da AWS DMS, crie uma tarefa de migração
    - Adicione o endpoint RDS como source e o S3 como target
    - Utilizando o assistente (wizard), no prepare tables: Do nothing
    - Desative a validação de dados
    - Não é necessário ativar os logs
    - Selecione apenas o schema que quer ler no banco para não pegar os schemas de performance do mysql
5. Agora só esperar e checar o bucket de saída
6. Não esqueça de `terraform destroy` para não gastar mais com recursos
