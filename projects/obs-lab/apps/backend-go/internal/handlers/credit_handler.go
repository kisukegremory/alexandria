package handlers

import (
	"context"
	"log/slog"
	"math/rand"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/kisukegremory/alexandria/obs-lab/backend/internal/models"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/metric"
	"go.opentelemetry.io/otel/trace"
)

type CreditHandler struct {
	simulationCounter metric.Int64Counter
}

func NewCreditHandler() *CreditHandler {
	meter := otel.Meter("credit-service-go")
	counter, err := meter.Int64Counter(
		"credit.simulations.count",
		metric.WithDescription("Total number os credit simulations"),
		metric.WithUnit("{simulation}"),
	)
	if err != nil {
		slog.Error("Problemas ao criar counter")
		panic(err)
	}
	return &CreditHandler{
		simulationCounter: counter,
	}
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
		h.simulationCounter.Add(ctx, 1, metric.WithAttributes(attribute.String("status", "approved")))
		c.JSON(http.StatusOK, resp)
		return
	}

	h.simulationCounter.Add(ctx, 1, metric.WithAttributes(attribute.String("status", "denied")))
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

	score := rand.Intn(351) + 600

	maskedCPF := "INVALID"
	if len(cpf) > 2 {
		maskedCPF = "****-" + cpf[len(cpf)-2:]
	}

	span.SetAttributes(
		attribute.String("app.cpf_masked", maskedCPF),
		attribute.Int("app.generated_score", score),
	)

	delay := time.Duration((rand.Intn(100) + 100) * int(time.Millisecond))
	time.Sleep(delay)
	return score
}
