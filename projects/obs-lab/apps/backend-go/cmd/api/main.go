package main

import (
	"log/slog"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/kisukegremory/alexandria/obs-lab/backend/internal/handlers"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)
	r := gin.Default()

	creditHandler := handlers.NewCreditHandler()

	r.GET("/ping", func(ctx *gin.Context) { ctx.JSON(200, gin.H{"status": "ok"}) })

	r.POST("/simulacao", creditHandler.PostSimulation)

	slog.Info("Iniciando Servidor da porta :8080")
	if err := r.Run(":8080"); err != nil {
		slog.Error("Falha ao iniciar servidor", "error", err)
		os.Exit(1)
	}
}
