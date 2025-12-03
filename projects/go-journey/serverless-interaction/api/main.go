package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/go-playground/validator/v10"
)

var queue_url string = os.Getenv("QUEUE_URL")
var sqs_client *sqs.Client
var validate = validator.New()

func main() {
	if queue_url == "" {
		log.Fatal("Missing 'QUEUE_URL' Enviroment Variable")
	}
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	if err != nil {
		log.Fatalf("Error on loading aws enviroment variables config: %v", err)
	}
	sqs_client = sqs.NewFromConfig(cfg)

	api := http.NewServeMux()
	port := ":8080"
	api.HandleFunc("POST /movies", MovieHandler)
	log.Printf("Listen on port %s", port)
	log.Fatal(http.ListenAndServe(port, api))
}

type Movie struct {
	Name string `json:"name" validate:"required"`
	Imdb int16  `json:"imdb" validate:"required"`
}

func MovieHandler(w http.ResponseWriter, r *http.Request) {
	var movie Movie

	if err := json.NewDecoder(r.Body).Decode(&movie); err != nil {
		http.Error(w, fmt.Sprintf("Erro ao ler formato %v", err), http.StatusBadRequest)
		return
	}
	if err := validate.Struct(movie); err != nil {
		http.Error(w, fmt.Sprintf("formato inválido %v", err), http.StatusUnprocessableEntity)
		return
	}
	log.Printf("Movie: %v", movie)

	messageBytes, err := json.Marshal(movie)
	if err != nil {
		http.Error(w, fmt.Sprintf("Erro ao transformar mensagem em bytes: %v", err), http.StatusUnprocessableEntity)
		return
	}

	sqsInput := &sqs.SendMessageInput{
		QueueUrl:    aws.String(queue_url),
		MessageBody: aws.String(string(messageBytes)),
	}

	output, err := sqs_client.SendMessage(context.TODO(), sqsInput)
	if err != nil {
		http.Error(w, fmt.Sprintf("Erro ao enviar mensagem para o SQS: %v", err), http.StatusInternalServerError)
		return
	}

	log.Printf("Mensagem enviada com sucesso: %v", *output.MessageId)

	w.WriteHeader(http.StatusOK)

}
