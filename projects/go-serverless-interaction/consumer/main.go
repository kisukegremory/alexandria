package main

import (
	"context"
	"log"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
)

var QUEUE_URL string = os.Getenv("QUEUE_URL")
var sqs_client *sqs.Client

func main() {
	if QUEUE_URL == "" {
		log.Fatal("Missing 'QUEUE_URL' enviroment variable")
	}

	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("us-east-1"))
	if err != nil {
		log.Fatalf("Error on loading default config: %v", err)
	}

	sqs_client = sqs.NewFromConfig(cfg)

	for {

		result, err := sqs_client.ReceiveMessage(context.TODO(), &sqs.ReceiveMessageInput{
			QueueUrl:            aws.String(QUEUE_URL),
			MaxNumberOfMessages: 10,
			VisibilityTimeout:   5,
			WaitTimeSeconds:     20,
		})
		if err != nil {
			log.Fatalf("Error on receiving messages: %v", err)
		}

		for _, msg := range result.Messages {
			log.Printf("Message body: %v", *msg.Body)
			log.Printf("Message Receipt: %v", *msg.MessageId)

			// Hora de dar um ack nas mensagens

			_, err := sqs_client.DeleteMessage(context.TODO(), &sqs.DeleteMessageInput{
				QueueUrl:      aws.String(QUEUE_URL),
				ReceiptHandle: msg.ReceiptHandle,
			})
			if err != nil {
				log.Fatalf("Error on acking msg id: %v", *msg.MessageId)
			}
			log.Printf("Successfully acking message id: %v", *msg.MessageId)

		}

		if len(result.Messages) == 0 {
			log.Println("No messages received")
		}

	}
	// Instanciar a classe do consumer, fazer o receive-message e printar todas as mensagens na tela
}
