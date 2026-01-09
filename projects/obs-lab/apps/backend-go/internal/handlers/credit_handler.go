package handlers

import (
	"log/slog"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/kisukegremory/alexandria/obs-lab/backend/internal/models"
)

type CreditHandler struct{}

func NewCreditHandler() *CreditHandler {
	return &CreditHandler{}
}

func (h *CreditHandler) PostSimulation(c *gin.Context) {
	var req models.CreditRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		slog.Error("Erro na validação do Json", "error", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	slog.Info("Processando simulação", "cpf", req.CPF, "amount", req.Amount)

	score := 850

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
