# Profiles
Para trabalhar com multiplos perfils do aws cli, vamos começar mexendo com o default:
```shell
aws configure # preencha com as credenciais que mais irá utilizar
```

Para outros perfis abra a pasta .aws, copie o default e renomeie para o perfil que quer utilizar no config e no credentials, por exemplo:
[nina]
region = us-east-1
output = json

[default]
region = us-east-1
output = json

e ai na hora de rodar os comandos de outro perfil podemos utilizar a option --profile nina no cli comando ex: `aws --profile nina`, ou para facilitar e definir tudo dentro do mesmo shell, dá um export AWS_PROFILE=nina, e agora o `aws` já utilizará o perfil nina no lugar do default nos comandos do CLI para esse shell