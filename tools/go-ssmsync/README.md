# SSMSync

Facilitando a vida de quem quer importar ou exportar variaveis de ambiente do SSMS + gerar código de env para relacionar isso com o terraform

# Geração de enviroment para o terraform (Task Manager)

# Importação de secrets para o SSM
- passe o prefix
- o arquivo de secrets (dev, prod, etc)
- formatação a ser aplicada (raw, standard(-))

# Exportação de secrets para o SSM
- passe o prefix
- o arquivo de secrets a ser exportado (dev, prod, etc)

# Gerar data source para o terraform
- passe o prefix
- use workspace replacer para gerar o data source