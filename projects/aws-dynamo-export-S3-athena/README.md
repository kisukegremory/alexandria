# Dynamo Export to S3 and Read With Athena

A ideia desse projeto é simplesmente conectarmos em um dynamoDB, escolhermos o agendamento e voilá, ele gerará os dados no S3, e colocamos um schema no catalogo Glue e a view a ser executada para consultas no Athena com tratamento, embora não substitua o trabalho de um ETL completo feito por um data engineer a parte, isso certamente gerá uma bela camada raw que dependendo do volume de dados possa ser gerenciado por um lambda ou Glue

Por que não usar o streams? ele só emite eventos após estar habilitado, se eu pegar uma tabela em que ele não está, terei que fazer algum tipo de ingestão inicial da mesma forma, e nesse momento ainda existirá a necessidade de fazer alguma view hibrida entre a exportação e o stream, o que não é tão interessante para o meu momento atual, além disso, o stream tem um limite de 24 horas para os eventos, ou seja, se por algum motivo o lambda ficar inativo por mais de 24 horas, ele perderá os eventos, e isso não é algo que queremos, claro há formas de lidar com isso, mas ainda não são plug and play como desejo

E por fim, há o export incremental, como não preciso de near real time, é mais que suficiente para o meu caso de negócio alem de ter um custo infimo, dado que é $ 0.10 por GB exportado, e o custo de armazenamento no S3 é muito baixo, então mesmo que eu exporte uma tabela grande, o custo não será tão alto, e ainda posso configurar para exportar apenas os dados novos ou modificados, o que reduz ainda mais o custo.

## Possíveis Custos
- Exportação do DynamoDB para o S3: $0.10 por GB exportado (a ser otimizado com exportação incremental, onde só os dados novos ou modificados são exportados)
- PITR do DynamoDB: $0.20 por GB por mês (varia de acordo com a região)
- Armazenamento no S3: $0.023 por GB por mês (varia de acordo com a região e o tipo de armazenamento)
- Consultas no Athena: $5 por TB de dados consultados (varia de acordo com a região)
- Eventbridge Scheduler: Literalmente $0 (O Free Tier da AWS te dá 14 milhões de agendamentos por mês)
- Step Functions: $0.025 por 1.000 transições de estado (varia de acordo com a região)


## Requisitos
- AWS CLI configurado
- Terraform CLI instalado
- Acesso a uma conta AWS com permissões para criar recursos (DynamoDB, S3, Glue, Athena, Lambda), no caso usarei meu profile nina como sempre para não usar o default e evitar problemas de permissão
- uv instalado para rodar o ambiente sem conflitos (mas fique a vontade para pegar o script e rodar com pip ou outro gerenciador de pacotes)


## Como faremos o desenvolvimento?
1. Iniciaremos criando a tabela no dynamoDB com o terraform
1. Usaremos o script para popular a tabela com dados de exemplo
1. Criamos o bucket no S3 para armazenar os dados exportados
1. Criamos a permissão para que o step functions possa acessar o dynamoDB e o S3
1. Configuraremos o Step Functions State Machine para fazer a exportação dos dados
1. Criamos a policy para eventbridge acionar a state machine
1. Configuramos o EventBridge para acionar a state machine a cada x tempo
1. Criamos o database no Glue Catalog para os dados exportados
1. Criamos o schema no Glue Catalog para os dados exportados
1. Criamos o Workgroup no Athena para as consultas (opcional, mas ajuda a isolar o projeto em si mesmo)
1. Criamos a view no Athena para consultar os dados exportados com tratamento (ex: converter timestamp, lidar com dados nulos, etc)


## Abordagens

### Daily Snapshot Export
Nesta abordagem, realizamos um Full Load todos os dias, exportando a tabela completa do DynamoDB para o S3 independentemente do que mudou.
Prós:
- Simplicidade Analítica: É trivial de consultar. Não precisamos lidar com lógicas complexas de CDC (Change Data Capture) ou deduplicação para saber o estado atual dos usuários.
- Viagem no Tempo (Time Travel): Análises históricas são muito fáceis. "Como era a tabela no dia 15 do mês passado?" Basta apontar a query para a partição daquele dia específico.
- Menos dependências: O Glue Crawler mapeia os arquivos por data naturalmente, reduzindo a complexidade de engenharia.

Contras:

- Custo Escalonável (O Maior Ofensor): Embora o custo de armazenamento no S3 possa ser mitigado com políticas de Lifecycle (Ex: deletar snapshots com mais de 30 dias), o custo de Exportação do DynamoDB ($0.10 por GB) não tem mitigação. Exportar 100GB todos os dias custará $300 dólares no mês apenas na taxa de exportação.
- Tempo de Processamento: Exportar tabelas massivas leva muito mais tempo, o que pode atrasar a disponibilidade dos dados para o negócio
- Armazenamento Redundante: A maioria dos dados provavelmente não mudou, então estamos pagando para exportar e armazenar dados idênticos repetidamente

### Incremental Export
Nesta abordagem, realizamos um único Full Load Inicial (Marco Zero) e, a partir de então, exportamos diariamente apenas os dados que sofreram mutação (INSERT, MODIFY, REMOVE) no período de 24 horas.
Prós:

- Eficiência Financeira Absoluta: É incrivelmente barato a longo prazo. Mesmo que a tabela tenha 1 TB, se apenas 100 MB de dados mudaram no dia, você pagará apenas a exportação desses 100 MB (frações de centavos)
- Rapidez: O job de exportação do DynamoDB finaliza muito mais rápido, pois processa apenas o "Delta" dos logs do PITR

**Contras**:
- Complexidade na Reconciliação: O formato do arquivo Incremental é diferente do Full Load (ele traz o evento, com OldImage e NewImage)
    - *Mitigação*: Consolidamos isso em camadas lógicas no Athena sem gastar com ETL
        - Camada Bronze (Raw): Tabelas brutas separadas mapeando o Full Inicial e os Incrementais
        - Camada Prata: Uma View híbrida (Window Function) que une a Bronze, ordena os eventos por data e deduplica, garantindo que as ferramentas de BI enxerguem apenas a versão mais recente e atualizada de cada registro