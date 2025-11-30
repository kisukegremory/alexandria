package main

import (
	"encoding/json"
	"log"
	"net/http"
)

func main() {
	api := http.NewServeMux()
	api.HandleFunc("/health", HealthHandler)
	log.Println("Serving api at port :8080")
	log.Fatal(http.ListenAndServe(":8080", api))
}

func HealthHandler(w http.ResponseWriter, r *http.Request) {
	data := BaseResponse{StatusCode: 200, Data: "Nina Send OK"}
	w.Header().Set("Content-Type", "application/json") // Requer ser setado antes do write header se não é sobrescrito (??)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(data) // Cria um encoder para o io.writer e encoda!
	log.Println(r.Host, r.Method, data)
}

type BaseResponse struct {
	StatusCode int    `json:"status_code"`
	Data       string `json:"data"`
}
