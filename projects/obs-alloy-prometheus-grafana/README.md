# Entendimentos sobre OpenTelemetry, Tracing e Observabilidade

# Como funciona o OpenTelemetry
Ele é composto de componentes base:
- resource: informações sobre o ambiente, módulo, aplicação, etc
- provider: provê os objetos de tracing, metrics e logs
- processor: ponte entre o provider e o exporter, ex: agrega em batch antes do envio
- exporter: envia os dados para um backend, ex: console(stdout), jaeger, loki, etc



# Observabilidade para FrontEnd
Pensando em observabilidade no frontend sempre me veio a mente o sentry, e gostaria de emular essa experiência com uma stack open source, mas como fazer isso? basicamente usariamos uma combinação de stack com Tempo/Jaeger e OtelCollector/Alloy
- Jaeger coletaria as informações de traces, enriquecidos com eventos bem detalhados, além de informações da stack pile
- Loki receberia logs ou seja informações a nível transacional de forma bem detalhada
- OtelCollector p/uso externo coletaria de uma vez só todas as informações da aplicação, sendo o ponto único de contato com o exterior da Rede em que a aplicação teria contato indireto
- AWS Load Balancer seria a porta de entrada, pois aqui temos todo o TLS handshake, WAF, DDoS protection para mitigar o uso desenfreado e tentativas de abuso do coletor
- CORS habilitado no OtelCollector para garantir acesso apenas a Origins que de fato são corretos
- Adicionamos o OTEL_TOKEN para autenticação com o OtelCollector e garantir que quem está tentando acessar, de tenha permissão para faze-lo 

Todas essas camadas são mitigatórias e ainda são passíveis de injeções de dados falsos, mas honestamente o sentry funciona da mesma forma, mas pelo menos conseguimos emular o mesmo nível de segurança, mas com uma stack bem mais customizável