package main

import (
	"context"
	"log/slog"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/kisukegremory/alexandria/obs-lab/backend/internal/handlers"
	"github.com/kisukegremory/alexandria/obs-lab/backend/internal/telemetry"
	"go.opentelemetry.io/contrib/instrumentation/github.com/gin-gonic/gin/otelgin"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	shutdown := telemetry.InitTracer()
	defer shutdown(context.Background())

	r := gin.Default()
	r.Use(otelgin.Middleware("credit-api-server")) // Middleware "auto instrumentalizado"

	creditHandler := handlers.NewCreditHandler()

	r.GET("/ping", func(ctx *gin.Context) { ctx.JSON(200, gin.H{"status": "ok"}) })

	r.POST("/simulacao", creditHandler.PostSimulation)

	slog.Info("Iniciando Servidor da porta :8080")
	if err := r.Run(":8080"); err != nil {
		slog.Error("Falha ao iniciar servidor", "error", err)
		os.Exit(1)
	}
}
