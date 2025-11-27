package greetings

import (
	"errors"
	"fmt"
	"math/rand"
)

func Hello(name string) (string, error) {
	if name == "" {
		return "", errors.New("Ta vazio chefe")
	}

	message := fmt.Sprintf(randomFormat(), name)
	return message, nil
}

func randomFormat() string {
	formats := []string{
		"Hi, %v. yokoso!",
		"Bom te ver de novo, %v!",
		"Hail king ling ling %v!",
	}

	return formats[rand.Intn(len(formats))]

}
