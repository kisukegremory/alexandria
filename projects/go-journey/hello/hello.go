package main

import (
	"fmt"

	"example.com/greetings"
)

func main() {
	messsage := greetings.Hello("Nininha")
	fmt.Println(messsage)
}
