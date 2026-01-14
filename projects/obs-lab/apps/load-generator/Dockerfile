FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o load-generator ./main.go

FROM alpine:latest

WORKDIR /root/

COPY --from=builder /app/load-generator .

CMD [ "./load-generator" ]
