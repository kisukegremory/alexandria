


## Task Placement Strategies
é como as tasks serão alocadas dentro do cluster baseado nos recursos computacionais do EC2?
é possível usar mais de um ao mesmo tempo

### binpack
o mais efetivo em custo, você escolhe entre memória ou cpu e ele tentará lotar a primeira instância com isso até precisar de outra, aqui torna o auto scalling muito efetivo em custo

### Random
aleatório

### Spread
divide baseado em algum valor, tipo AZ ou instance id

## Placement constrains
restrige o comportamento de placement das tasks ex:
- distinctInstance -> cada task rodará em uma instância diferente
- memberOf -> uma linguagem para definir as restrições, por exemplo só pode ser alocado nas instâncias que começamos com t2.*