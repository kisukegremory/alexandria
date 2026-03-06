package main

import (
	"context"
	"fmt"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

const secretToken = "alexandria-secret"

func handleRequest(ctx context.Context, event events.APIGatewayV2CustomAuthorizerV2Request) (events.APIGatewayV2CustomAuthorizerSimpleResponse, error) {
	fmt.Printf("Event Route: %s, Headers %v\n", event.RouteKey, event.Headers)

	// Extraindo o token do header Authorization identificando o header de forma case-insensitive"
	var token string
	for k, v := range event.Headers {
		if strings.EqualFold(k, "authorization") {
			token = v
			break
		}
	}
	cleanToken := strings.TrimPrefix(token, "Bearer ")
	cleanToken = strings.TrimSpace(cleanToken)
	if cleanToken == secretToken {
		fmt.Println("Token is valid, authorizing user.")
		return events.APIGatewayV2CustomAuthorizerSimpleResponse{
			IsAuthorized: true,
			Context: map[string]interface{}{
				"user":      "authorized-user",
				"role":      "admin",
				"plan_tier": "premium",
			},
		}, nil
	}
	fmt.Printf("Invalid token: %s\n", cleanToken)
	return events.APIGatewayV2CustomAuthorizerSimpleResponse{
		IsAuthorized: false,
	}, nil
}

func main() {
	lambda.Start(handleRequest)
}
