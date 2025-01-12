
Para o DB (SG2):
1. necessário mudança no parameter group de ativar o binary_log e binlog_format -> row
Depende se já foi criado do 0 com o parameter group ou não, caso não tenha:
2. apontar para esse novo parameter group
3. restartar a instãncia
Caso já tenha, basta já criar a instância com esse parameter group

Para o S3:
1. Criar bucket (bronze e silver)
2. Adicionar versionamento por 2,3 dias de segurança
3. Política que mudança de tier após 90 dias

Para o DMS:
1. Vamos criar a instância dentro do free tier (SG1)
2. Source do MySQL
3. Target S3 (com configurações com parquet + campos adicionais)

Para o Athena:
1. Criar tabela bronze apontando para os dados levantados no CDC
2. Tentar fazer uma query
3. Criar tabela iceberg para a camada prata
4. Query de insert, update e delete para atualização no iceberg


refs: 
- https://www.youtube.com/watch?v=qx2Ij_Bhj4Q&ab_channel=KahanDataSolutions
- https://www.youtube.com/watch?v=tOMQuiogdOE&ab_channel=CloudQuickLabs
- https://www.youtube.com/watch?v=M9hT4SdPtgI&ab_channel=ThomasHass