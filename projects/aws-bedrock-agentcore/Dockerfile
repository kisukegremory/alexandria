FROM python:3.12-slim

WORKDIR /app

COPY pyproject.toml .
RUN pip install --no-cache-dir uv && uv pip install --system strands-agents strands-agents-tools boto3

COPY agents/ agents/
COPY tools/ tools/
COPY data/ data/
COPY main.py .

ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["python", "main.py"]
