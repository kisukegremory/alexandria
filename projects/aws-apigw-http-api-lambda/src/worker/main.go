package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// Estrutura para receber o payload (exemplo)
type IngestRequest struct {
	Message string `json:"message"`
}

// Handler principal
func handleRequest(ctx context.Context, event events.APIGatewayV2HTTPRequest) (events.APIGatewayProxyResponse, error) {
	// 1. Logs Estruturados (Vão aparecer no CloudWatch bonitos)
	fmt.Printf(`{"level":"info", "msg":"request received", "request_id":"%s", "source_ip":"%s"}`+"\n",
		event.RequestContext.RequestID,
		event.RequestContext.HTTP.SourceIP)

	// 2. Parse do Body (se houver)
	var reqBody IngestRequest
	if event.Body != "" {
		// Ignorando erro de unmarshal para simplificar o exemplo, mas num real tratariamos
		json.Unmarshal([]byte(event.Body), &reqBody)
	}

	// 3. Montar Resposta
	responseBody := map[string]interface{}{
		"status":  "success",
		"message": "Worker executado com sucesso em Go (Graviton)",
		"echo":    reqBody.Message,
		"req_id":  event.RequestContext.RequestID,
	}

	jsonBytes, _ := json.Marshal(responseBody)

	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
		Body: string(jsonBytes),
	}, nil
}

func main() {
	lambda.Start(handleRequest)
}
