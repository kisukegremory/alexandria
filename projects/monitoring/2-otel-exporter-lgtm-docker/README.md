Não é recomendado enviar nada direto para o prometheus, loki ou tempo, portanto vamos adicionar o otel collector para absorvê-lo, mas antes de começarmos a complicar o trabalho, vamos usar a imagem da grafana lgtm que já empacota todos os serviços de telemetria e já está todo configurado, e aqui serve apenas para demonstrar como seria a interface que um dev teria, ou seja só o envio para o collector.


Vamos fazer com um compose apenas do lgtm stack sem nossa aplicação