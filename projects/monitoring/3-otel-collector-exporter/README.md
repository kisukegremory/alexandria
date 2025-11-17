Agora vamos começar a desacoplar os componentes da LGTM Stack, ela funciona com o grafana alloy provavelmente, aqui usaremos o otel collector!

# Como testar?

1. suba o otel-collector (docker compose up)
2. escolha o .py que queira enviar a telemetria
3. olhe os logs do otel-collector, verá que estamos usando o debug exporter e será apresentado no console!