import time
import random
from fastapi import FastAPI, HTTPException
from os import linesep

from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import  Resource

resource = Resource(attributes={
    "service.name": "otel-traces-lgtm-docker",
    "service.version": "1.0.0"
})

trace_provider = TracerProvider(resource=resource)
exporter = OTLPSpanExporter(
    endpoint="localhost:4317",
    insecure=True
)
trace_processor = BatchSpanProcessor(exporter)
trace_provider.add_span_processor(trace_processor)
tracer = trace_provider.get_tracer(__name__)

app = FastAPI()


@app.get("/")
async def hello():
    with tracer.start_as_current_span("hello") as span:
        span.set_attribute("user.type", "visitor")
        span.add_event("olá from raiz!")

        return {
            "hello": "world"
        }
    

if __name__ == '__main__':
    import uvicorn
    uvicorn.run("traces:app", host="127.0.0.1", port=5000, workers=2)