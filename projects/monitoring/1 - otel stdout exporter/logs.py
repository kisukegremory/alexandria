from fastapi import FastAPI
import logging
from opentelemetry._logs import set_logger_provider
from opentelemetry.sdk._logs import LoggingHandler, LoggerProvider
from opentelemetry.sdk._logs.export import ConsoleLogExporter, BatchLogRecordProcessor
from opentelemetry.instrumentation.logging import LoggingInstrumentor


def setup_logs():
    log_provider = LoggerProvider()
    set_logger_provider(log_provider)

    console_exporter = ConsoleLogExporter()
    batch_processor = BatchLogRecordProcessor(console_exporter)
    log_provider.add_log_record_processor(batch_processor)
    logger_handler = LoggingHandler(logger_provider=log_provider)

    # 2. Obtemos o logger que queremos instrumentar (ex: o raiz)
    root_logger = logging.getLogger()
    
    # 3. Definimos o nível de log
    root_logger.setLevel(logging.INFO)
    
    # 4. Anexamos o handler do OTel a ele
    root_logger.addHandler(logger_handler)


setup_logs()
logger = logging.getLogger(__name__)
app = FastAPI()

@app.get("/")
def hello():
    logger.info("Olá, Mundo! As métricas foram enviadas via Console.")
    return 200

if __name__ == '__main__':
    import uvicorn

    uvicorn.run("logs:app", host="127.0.0.1", port=5000, workers=2)