


# AWS Organizations
Maneira de organizar multiplas contas em um só lugar, alem de centralizar o billing delas, como todo o valor é somado em uma organização, é aproveitável os descontos em escala, e tambem é possível compartilhar instâncias reservadas e saving plans
- a conta de gerenciamento se aplica o SCP, portanto sempre terá full acess a tudo
- SCP é service control policies, regras de gerenciamento das sub contas

# Permissions boundaries
são policies que registrem as policies que o usuário quer assumir são boundaries, então mesmo com full access, se o boundary só permitir só s3, será só S3, só pra user ou role, não pra grupos

# Control tower
- preventive guard rails: usando SCP, com restrigir o uso de outras regiões na aws
- detective guard rails: usando o config verifica organization wise se algo está non compliant