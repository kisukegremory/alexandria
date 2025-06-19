# Storage Options

Aqui vamos adicionar formas de storage fornecidas pela AWS, como EBS, EFS e seus permenores.

# EBS
Single AZ, se precisar colocar em outro, precisa fazer snapshot e restaurar em outro

## Types
- gp2(3 IOPS/GB)/gp3 (SSD) - General purposes, balanço entre preço, performance e iops, gp3 tem iops(base 3k até 16k) e thoroughput(Base 125 Mib/s até 1k) independente do tamanho, 1 GB até 16 TB de tamanho, base 3k IOPS e 125
- io1/io2 (SSD) - High Performance SSD, baixa latência e alto IOPS aqui é 'quantas viagens de ida e volta o carro pode fazer por segundo' bom para muitas pequenas operações de escrita e leitura 
    - io1: até 64k PIOPS
    - io2: até 256k IOPS
- st1 (HDD) - barato mas com bom thoroughput (não pode ser boot) -> para bigdata, log, streaming, DW e edição de vídeos onde a latência é menos importante, aqui é 'quanta carga o caminhão pode levar' velocidade de transferência de arquivos 
- st2 (HDD) - mais barato de todos (não pode ser boot)

## Multi Attach
- é possível usar o mesmo block storage em várias instâncias na mesma AZ até 16 EC2 (full read and write)
- só Io1/Io2


# Instance Storage
Storage físico para EC2/EBS com altos níveis de IOPS


# Storage Gateway
Precisa ser instalado no data center (se não tiver um servidor virtual para isso, é possível comprar da amazon)
Para utilização do S3, EBS, EFS, FSx on premises, muito usado para disaster recovery e backups, e mantendo os dados on premises com cache e o grosso na nuvem por exemplo aqui temos:
- S3 File Gateway - agente on premises que será acessado com NFS, mas que por dentro ele irá requisitar https para o S3, dados mais recentemente acessados tem cache dentro do gateway
- FSx File Gateway (Descontinuado) - Local cache para dados frequentemente acessos no FSX for windows por exemplo
- Volume Gateway: Block Storage usando o protocolo iSCSI backend by S3 podendo ser transformados em snapshots EBS e aí sim se precisar restaurar volumes on premises podemos usar aqui
- Tape Gateway: tudo que envolver tape é aqui

# Transfer Family
sFTP, FTPS, FTP em cima de um S3 ou EFS, já prove o endpoint e segurança gerenciada pelo cognito ou outras alternativas (caro pra xuxu)

# FSx
- Modo Scratch -> mais barato, mas em caso de queda perde tudo
- Modo persistente -> long-term, replicação na mesma AZ, arquivos com problemas são recuperados em minutos de forma transparente
- For windows: para windows servers
- For Lustre(linux cluster): Alta performance - milhões de IOPS
- For NetApp Ontap: alta compatibilidade entre sistemas operacionais (rola até mac aqui)
- For OpenZFS: quando necessário ZFS


# Data Sync
- Opção de migração de dados da AWS entre cloud/on premises (requer agente snowcone 10Gbps) ou cloud/cloud
- aqui podemos interagir EFS, S3, FSx, aqui os metadados são preservados!
- Só rola com agendamento: horário, diário e semanal
- Não joga para o glacier direto use lifecycle policy


# Snow family
Para transportar grandes volumes de dados a nível de petabytes para a AWS, em uma semana solicita e aí levam o dispositivo e retornam para colocar no S3 por exemplo
- device compute optimized: 104 vCPU, 416GB RAM, 28TB
- device storage optimized: 104 vCPU, 416GB RAM, 210TB

Tambem é possível fazer edge computing com eles em locais que não tem acesso a internet, rodar EC2, lambda at edge para preprocessamento de dados
(Não joga para o glacier direto use lifecycle policy)