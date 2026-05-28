package cmd

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/service/comprehend"
	"github.com/aws/aws-sdk-go-v2/service/comprehend/types"
	"github.com/spf13/cobra"
)

var comprehendText string

var comprehendCmd = &cobra.Command{
	Use:   "comprehend",
	Short: "Para analise de NLP, PII, Sentimentos..",
}

var sentimentCmd = &cobra.Command{
	Use:   "sentiment",
	Short: "Para analise de sentimentos",
	Run: func(cmd *cobra.Command, args []string) {
		comprehendClient := comprehend.NewFromConfig(cfg)
		println("Analisando os sentimentos do texto", comprehendText)
		input := comprehend.DetectSentimentInput{
			LanguageCode: types.LanguageCode("pt"),
			Text:         &comprehendText,
		}
		output, err := comprehendClient.DetectSentiment(context.TODO(), &input)
		if err != nil {
			fmt.Printf("Erro: %v", err)
			return
		}
		fmt.Printf("Sentimento: %v\n  Positive: %.4f\n  Negative: %.4f\n  Neutral:  %.4f\n  Mixed: %.4f\n",
			output.Sentiment,
			*output.SentimentScore.Positive,
			*output.SentimentScore.Negative,
			*output.SentimentScore.Neutral,
			*output.SentimentScore.Mixed,
		)
	},
}

var entitiesCmd = &cobra.Command{
	Use:   "entities",
	Short: "Para analise de Entidades dentro de textos",
	Run: func(cmd *cobra.Command, args []string) {
		client := comprehend.NewFromConfig(cfg)
		output, err := client.DetectEntities(context.TODO(), &comprehend.DetectEntitiesInput{
			LanguageCode: types.LanguageCodePt,
			Text:         &comprehendText,
		})
		if err != nil {
			fmt.Printf("Erro ao gerar entidades: %v", err)
			return
		}
		for _, entity := range output.Entities {
			fmt.Printf("Tipo: %v, Texto: %v, Score %.4f \n", entity.Type, *entity.Text, *entity.Score)
		}

	},
}

var piiCmd = &cobra.Command{
	Use:   "pii",
	Short: "Detecta PII nos textos enviados",
	Run: func(cmd *cobra.Command, args []string) {
		client := comprehend.NewFromConfig(cfg)
		output, err := client.DetectPiiEntities(context.TODO(), &comprehend.DetectPiiEntitiesInput{
			LanguageCode: types.LanguageCodeEn,
			Text:         &comprehendText,
		})
		if err != nil {
			fmt.Printf("Erro ao Avaliar PII: %v", err)
			return
		}

		for _, entity := range output.Entities {
			fmt.Printf("Entidade %v, Score %v \n", entity.Type, *entity.Score)
		}
	},
}

func init() {
	comprehendCmd.PersistentFlags().StringVarP(&comprehendText, "text", "t", "", "Texto a ser analisado")
	comprehendCmd.AddCommand(sentimentCmd)
	comprehendCmd.AddCommand(entitiesCmd)
	comprehendCmd.AddCommand(piiCmd)
	rootCmd.AddCommand(comprehendCmd)
}
