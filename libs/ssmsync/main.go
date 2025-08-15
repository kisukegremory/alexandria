package main

import (
	"flag"
	"fmt"
	"strings"
)

func (env EnvVar) formatSSMPattern(project string) string {
	result := fmt.Sprintf("/%s/%s", project, env.Name)
	result = strings.ReplaceAll(result, "_", "-")
	result = strings.ToLower(result)
	return result
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
