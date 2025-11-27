package greetings

import (
	"errors"
	"fmt"
)

func Hello(name string) (string, error) {
	if name == "" {
		return "", errors.New("Ta vazio chefe")
	}

	message := fmt.Sprintf("Hi, %v. yokoso!", name)
	return message, nil
}
