package main

import (
	"fmt"
	"os"
	"strings"
)

type EnvVar struct {
	Name  string
	Value string
}

func envReader(filename string) []EnvVar {
	fmt.Println("Reading file: ", filename)
	file, err := os.ReadFile(filename)
	if err != nil {
		fmt.Println("Error reading file: ", err)
	}
	envList := []EnvVar{}
	for _, env_var := range strings.Split(string(file), "\n") {
		env := EnvVar{Name: strings.Split(env_var, "=")[0], Value: strings.Split(env_var, "=")[1]}
		envList = append(envList, env)
	}
	return envList
}
