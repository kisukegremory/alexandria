from fastapi import FastAPI
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader, ConsoleMetricExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter

# --- Nova Configuração do OpenTelemetry (Modo Push) ---

# 1. Configura o "exportador" que vai ENVIAR as métricas via OTLP.
#    O endereço 'http://alloy:4318' aponta para o nosso serviço Alloy no Docker Compose.
#    'insecure=True' é usado porque não estamos configurando SSL/TLS na nossa rede interna.
otlp_exporter = OTLPMetricExporter(endpoint="alloy:4318", insecure=True)
local_exporter = ConsoleMetricExporter() # Para exibir as métricas no terminal

# 2. Configura um "leitor" que periodicamente pega as métricas e as envia usando o exportador.
reader = PeriodicExportingMetricReader(otlp_exporter, export_interval_millis=1000) # Envia a cada 1s (só para fins de feedback rápido)

# 3. Registra o leitor no nosso provedor de métricas.
meter_provider = MeterProvider(metric_readers=[reader])
metrics.set_meter_provider(meter_provider)

# 4. Obtém um medidor para criar nossas métricas (igual a antes).
meter = metrics.get_meter("minha-app")

# Criando nossa métrica: um contador (igual a antes)
http_requests_total = meter.create_counter(
    "http_requests_total",
    description="Total de requisições HTTP recebidas",
    unit="1",
)

# --- Nossa Aplicação Web Simples (sem alterações) ---
app = FastAPI()

@app.get("/")
def hello():
    http_requests_total.add(1)
    return "Olá, Mundo! As métricas foram enviadas via OTLP."

if __name__ == '__main__':
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=5000, workers=2)