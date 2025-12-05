# Single stage:
# FROM golang:1.25.4-alpine AS builder
# COPY . .
# RUN go mod download
# RUN go build -o main .
# EXPOSE 8080
# CMD [ "./main" ]


FROM golang:1.25.4-alpine AS builder
# RUN apk add --no-cache ca-certificates # Seria necessário se o alpine já não precarregasse os ca-certificates, mas felizmente a versão mais atual já possui
WORKDIR /build
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 go build -o main . # CGO seria usado em caso de bibliotecas externas e para o scratch isso não funciona e requer desabilitar

FROM scratch
WORKDIR /app
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ # Necessário para validação TLS, se não tiver, dará erro ao conectar no SQS
COPY --from=builder /build/main /app/main
EXPOSE 8080
CMD [ "/app/main" ]
