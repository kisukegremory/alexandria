package models

type CreditRequest struct {
	CPF    string  `json:"cpf" binding:"required"`
	Amount float64 `json:"amount" binding:"required,gt=0"`
}

type CreditResponse struct {
	Status string  `json:"status"`
	Score  int     `json:"score"`
	Limit  float64 `json:"limit,omitempty"`
	Error  string  `json:"error,omitempty"`
}
