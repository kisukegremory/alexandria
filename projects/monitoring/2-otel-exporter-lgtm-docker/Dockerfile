FROM python:3.13.5-slim AS builder
WORKDIR /app
RUN pip install uv
COPY uv.lock pyproject.toml /app/
RUN uv export --format requirements-txt > requirements.txt
FROM python:3.13.5-slim
WORKDIR /app
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . /app
EXPOSE 5000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]