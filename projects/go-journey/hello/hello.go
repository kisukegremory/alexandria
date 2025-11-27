package main

import (
	"fmt"
	"log"

	"example.com/greetings"
)

func main() {

	log.SetPrefix("greetings: ")
	log.SetFlags(0)

	messsage, err := greetings.Hello("Hello nina!")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(messsage)
	log.Default().Println(messsage)
}
