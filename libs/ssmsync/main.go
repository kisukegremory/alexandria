package main

import (
	"flag"
	"fmt"
	"os"
)

func main() {
	project := flag.String("project", "", "ssm parameter prefix")
	flag.Parse()
	fmt.Println("project: ", *project)

	secrets, _ := os.ReadFile(".secrets")

	fmt.Println("secrets: \n", string(secrets))
}
