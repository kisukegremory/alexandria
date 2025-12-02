package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

func main() {
	api := http.NewServeMux()
	port := ":8080"
	api.HandleFunc("POST /movies", MovieHandler)
	log.Printf("Listen on port %s", port)
	log.Fatal(http.ListenAndServe(port, api))
}

type Movie struct {
	Name string `json:"name" validate:"required"`
	Imdb int16  `json:"imdb" validate:"required"`
}

func MovieHandler(w http.ResponseWriter, r *http.Request) {
	var movie Movie

	if err := json.NewDecoder(r.Body).Decode(&movie); err != nil {
		http.Error(w, fmt.Sprintf("Erro ao ler formato %v", err), http.StatusBadRequest)
		return
	}
	if err := validate.Struct(movie); err != nil {
		http.Error(w, fmt.Sprintf("formato inválido %v", err), http.StatusUnprocessableEntity)
		return
	}
	log.Printf("Movie: %v", movie)

	w.WriteHeader(http.StatusOK)

}
