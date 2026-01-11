#!/bin/bash

echo "Iniciando bombardeio na api!!"
echo "Pressione ctrl+c para encerrar!"

while true; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/simulacao \
           -H "Content-Type: application/json" \
           -d "{\"cpf\": \"123.456.789-00\", \"amount\": 5000}")
    echo "[$(date +%T)] Request enviada. Status: $STATUS"
    sleep 0.$((1 + RANDOM % 5))
done
