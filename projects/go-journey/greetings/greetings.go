package greetings

import "fmt"

func Hello(name string) string {
	message := fmt.Sprintf("Hi, %v. yokoso!", name)
	return message
}
