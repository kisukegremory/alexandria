package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/bedrockruntime"
	"github.com/aws/aws-sdk-go-v2/service/bedrockruntime/types"
)

func main() {
	ctx := context.Background()

	cfg, err := config.LoadDefaultConfig(
		ctx,
		config.WithSharedConfigProfile("nina"),
		config.WithRegion("us-east-1"),
	)

	if err != nil {
		fmt.Fprintf(os.Stderr, "Erro ao carregar as configs AWS: %v\n", err)
		os.Exit(1)
	}

	client := bedrockruntime.NewFromConfig(cfg)
	var history []types.Message

	scanner := bufio.NewScanner(os.Stdin)

	fmt.Println("Chat NininhaGPT. digite sair com a patinha para sair")

	for {
		fmt.Print("\nVocê: ")

		if !scanner.Scan() {
			break
		}

		input := strings.TrimSpace(scanner.Text())

		if input == "" {
			continue
		}

		if input == "sair" {
			break
		}

		history = append(history, types.Message{
			Role: types.ConversationRoleUser,
			Content: []types.ContentBlock{
				&types.ContentBlockMemberText{Value: input},
			},
		})

		answer, err := chat(ctx, client, history)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Erro ao gerar resposta %v\n", err)
		}

		history = append(history, types.Message{
			Role: types.ConversationRoleAssistant,
			Content: []types.ContentBlock{
				&types.ContentBlockMemberText{Value: answer},
			},
		})

	}

	fmt.Println("Hasta luego!")

}

func chat(ctx context.Context, client *bedrockruntime.Client, history []types.Message) (string, error) {
	out, err := client.ConverseStream(ctx, &bedrockruntime.ConverseStreamInput{
		ModelId:  aws.String("amazon.nova-pro-v1:0"),
		Messages: history,
		System: []types.SystemContentBlock{
			&types.SystemContentBlockMemberText{
				Value: "Você é um assistente prestativo. Responda de forma concisa e em português",
			},
		},
	})
	if err != nil {
		return "", fmt.Errorf("ConverseStream: %w", err)
	}

	fmt.Print("\nAssistente: ")
	var sb strings.Builder
	stream := out.GetStream()
	defer stream.Close()

	for event := range stream.Events() {
		switch v := event.(type) {
		case *types.ConverseStreamOutputMemberContentBlockDelta:
			if delta, ok := v.Value.Delta.(*types.ContentBlockDeltaMemberText); ok {
				fmt.Print(delta.Value)
				sb.WriteString(delta.Value)
			}
		}
	}

	if err := stream.Err(); err != nil {
		return sb.String(), fmt.Errorf("stream: %w", err)
	}

	return sb.String(), nil

}
