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
		comprehendClient := *comprehend.NewFromConfig(cfg)
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

func init() {
	comprehendCmd.PersistentFlags().StringVarP(&comprehendText, "text", "t", "", "Texto a ser analisado")
	comprehendCmd.AddCommand(sentimentCmd)
	rootCmd.AddCommand(comprehendCmd)
}
