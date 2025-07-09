# Monitoring Tools


# Cloudwatch Metrics
Qualquer métrica que você queira monitorar como utilização de CPU, memória, bucket Size,... 
- são agrupadas por namespace (pode ser custom ou por exemplo EC2, S3)
- dimensões são atributos de uma métrica (ex: enviroment, instance id) dá pra ter até 30 por métrica
- ao juntar várias é possível criar um dashboard
- dá pra fazer customs, por exemplo RAM
- dá pra fazer stream das métricas (near real time) -> firehose e daí pra qualquer lugar
- monitoramento detalhado muda a coleta de 5 -> 1 min

# Logs
- agrupado em log groups
- que contem vários streams (ex: log files, applications, containers)
- tem politica de retenção
- exportável para:
    - s3 em batch (em até 12h)
    - lambda
    - kinesis streams e firehose
    - opensearch
- A coleta é por SDK, log agent (old, só logs) ou o unified agent -> pode coletar métricas tambem alem das padrões (ex: ram, swap..)
- Dá pra fazer log subscription para receber os dados em near real time e claro dá pra aplicar filtros!
    - firehose
    - lambda
    - kinesis streams
é possível criar uma métrica a partir dos logs, definindo um metric filter e pegando um valor da linha do log ou colocando 1 para ser uma contagem
## no EC2
- por default não é criado para EC2
- precisa adicionar o agente dentro da instância e permitir IAM pra ele

# Alarms
Trigga notificações baseado nas métricas
Targets:
 - Stop, start, reboot.. on EC2
 - Triggar autoscalling action
 - Notificação para o SNS e a partir daí lance o lambda
Dá para fazer um compose de alarme com AND ou OR -> ajuda a reduzir alarme noise
Notificações podem ir pro SNS
é possível testar os alarmes via CLI

# Contributors insights
A partir dos logs do cloudwatch é possível identificar por exemplo os top 10 usuários que mais acessaram sua rede, ou no dns quais urls deram mais erro

# CloudTrail
- provê governança, auditoria e compliance para a conta da aws, gera um histórico de todas as chamadas de api da aws e quem o fez
- é possível exportar pro cloudwatch ou S3 (e depois usar athena)
- um trail pode ser aplicado para todas as regiões (ou por região)
- read events -> não alteram recursos
- write events -> modificam
- data events -> não são logados pelo volume (ex: getobject S3)
- retenção de 90 dias, após isso jogue para o S3

## Insights (pago)
Detecta atividades incomuns, ex: rate limits, provisionamento estranho de recursos... 
eventos podem ser enviados para -> s3, console do trail ou event bridge

# AWS Config (não tem free tier)
- compliant or not compliant?
- Tambem para auditoria e compliance, define e verifica politicas para todos os serviços da aws, ex se todos meus security groups tem a porta ssh fechada
- te dá uma timeline das mudanças do recurso avaliado
- é por região
- tem managed rules pela aws (75)
- ou customs por lambda
- regras podem ser avaliadas por x tempo ou por cada mudança de configurações
- pode triggar SNS, eventbridge
- é possível automatizar remediações de recursos non compliant usando ssm documents (ex: desativar access keys)