package handlers

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/kisukegremory/alexandria/obs-lab/backend/internal/models"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

type CreditHandler struct{}

func NewCreditHandler() *CreditHandler {
	return &CreditHandler{}
}

func (h *CreditHandler) PostSimulation(c *gin.Context) {
	ctx := c.Request.Context() // Contexto com span pai já

	span := trace.SpanFromContext(ctx)
	traceID := span.SpanContext().TraceID().String()

	var req models.CreditRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		slog.Error("Erro na validação do Json", "error", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	slog.InfoContext(
		ctx,
		"Iniciando simulação",
		"cpf", req.CPF,
		"amount", req.Amount,
		"trace_id", traceID,
	)

	score := h.calculateScore(ctx, req.CPF)

	if score > 800 {
		resp := models.CreditResponse{
			Status: "aprovado",
			Score:  score,
			Limit:  req.Amount * 1.5,
		}
		c.JSON(http.StatusOK, resp)
		return
	}

	c.JSON(http.StatusForbidden, models.CreditResponse{
		Status: "reprovado",
		Score:  score,
		Error:  "Score insuficiente",
	})

}

func (h *CreditHandler) calculateScore(ctx context.Context, cpf string) int {
	tracer := otel.Tracer("business-logic")
	_, span := tracer.Start(ctx, "check-serasa-score")
	defer span.End()

	maskedCPF := "INVALID"
	if len(cpf) > 2 {
		maskedCPF = "****-" + cpf[len(cpf)-2:]
	}

	span.SetAttributes(attribute.String("app.cpf_masked", maskedCPF))

	time.Sleep(150 * time.Millisecond)
	return 850
}
