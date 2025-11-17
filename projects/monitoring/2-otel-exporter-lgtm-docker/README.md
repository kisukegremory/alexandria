Não é recomendado enviar nada direto para o prometheus, loki ou tempo, portanto vamos adicionar o otel collector para absorvê-lo, mas antes de começarmos a complicar o trabalho, vamos usar a imagem da grafana lgtm que já empacota todos os serviços de telemetria e já está todo configurado, e aqui serve apenas para demonstrar como seria a interface que um dev teria, ou seja só o envio para o collector.


Vamos fazer com um compose apenas do lgtm stack sem nossa aplicação, e ligar ela via localhost mesmo!

# Como usar?
1. ligue o lgtm stack com docker compose up
2. é possível ligar cada uma das aplicações com 'uv run ...py', acessar o localhost:5000 e fazer algumas requisições (importante esperar por volta de 1 minuto para que tudo que foi coletado pelo otel collector seja exportado para o lgtm)
3. no grafana (localhost:3000) vá em 'explore' e para:
    - metricas -> prometheus (http_requests_total) já vai funcionar o run query!
    - logs -> loki (label filter = unknown_service) já vai funcionar o run query!
    - traces -> tempo (query type -> search) ja vai funcionar o run query!