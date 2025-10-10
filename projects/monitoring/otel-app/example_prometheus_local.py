from fastapi import FastAPI
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader, ConsoleMetricExporter

# --- Nova Configuração do OpenTelemetry (Modo Push) ---

# 1. Configura o "exportador" que vai ENVIAR as métricas
local_exporter = ConsoleMetricExporter() # Para exibir as métricas no terminal

local_reader = PeriodicExportingMetricReader(local_exporter, export_interval_millis=5000)

# 3. Registra o leitor no nosso provedor de métricas.
meter_provider = MeterProvider(metric_readers=[local_reader])
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
    return "Olá, Mundo! As métricas foram enviadas via Console."

if __name__ == '__main__':
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=5000, workers=2)