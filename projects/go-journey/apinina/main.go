package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	api := http.NewServeMux()
	api.HandleFunc("/", BasicHandler)
	log.Fatal(http.ListenAndServe(":8080", api))
}

func BasicHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Servido, bem servido tal qual nininha")

}

// type User struct {
// 	ID    int    `json:"id"`
// 	Name  string `json:"name"`
// 	Email string `json:"email"`
// }

// var users []User = []User{
// 	{ID: 1, Name: "Nina", Email: "Nina@cobol.com"},
// 	{ID: 2, Name: "julio", Email: "rato@cobol.com"},
// 	{ID: 3, Name: "cocoricó", Email: "ximira@cobol.com"},
// }
