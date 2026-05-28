package cmd

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "aiws",
	Short: "CLI for easily usage of aws managed AI Services!",
	PersistentPreRunE: func(cmd *cobra.Command, args []string) error {
		var err error
		cfg, err = config.LoadDefaultConfig(context.TODO(), config.WithSharedConfigProfile(profile), config.WithRegion("us-east-1"))
		return err

	},
}

var profile string
var cfg aws.Config

func init() {
	rootCmd.PersistentFlags().StringVarP(&profile, "profile", "p", "nina", "Perfil da aws padrão a ser utilizado")

}

func Execute() {
	rootCmd.Execute()
}
