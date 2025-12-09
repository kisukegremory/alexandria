package main

import (
	"context"
	"flag"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

func (env EnvVar) formatSSMPattern(project string) string {
	result := fmt.Sprintf("/%s/%s", project, env.Name)
	return result
}

func getSSMParameter(ctx context.Context, client *ssm.Client, name string, decrypt bool) (string, error) {
	// Cria a entrada para a chamada da API GetParameter.
	input := &ssm.GetParameterInput{
		Name:           &name,
		WithDecryption: &decrypt, // Use 'true' para SecureString
	}

	// Chama a API para obter o parâmetro.
	result, err := client.GetParameter(ctx, input)
	if err != nil {
		return "", fmt.Errorf("falha ao buscar o parâmetro '%s': %w", name, err)
	}

	// Retorna o valor do parâmetro.
	return *result.Parameter.Value, nil
}

func main() {
	project := flag.String("project", "", "ssm parameter prefix")
	mode := flag.String("mode", "import", "import or export")
	// env := flag.String("env", ".env", "environment")
	secrets_file := flag.String("secrets", ".secrets", "Secrets File")
	flag.Parse()

	if *mode == "export" {
		return
	}

	envList := envReader(*secrets_file)
	for _, env := range envList {
		fmt.Println(env.formatSSMPattern(*project), env.Value)
	}

}
