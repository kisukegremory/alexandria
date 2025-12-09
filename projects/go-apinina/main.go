package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

const uploadDir = "./upload"

func main() {
	if _, err := os.Stat(uploadDir); os.IsNotExist(err) {
		os.Mkdir(uploadDir, os.ModePerm)
	}

	api := http.NewServeMux()
	api.HandleFunc("/health", HealthHandler)
	api.Handle("/", http.FileServer(http.Dir("./web"))) // Serve arquivos index.html removendo o 'index.html' do path Se quisermos mudar esse path / -> /images será necessário usar o stripPrefix em conjunto
	api.HandleFunc("/upload", ImageUploaderHandler)
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

func ImageUploaderHandler(w http.ResponseWriter, r *http.Request) {
	file, handler, err := r.FormFile("filename")
	if err != nil {
		http.Error(w, fmt.Sprintf("Erro ao ler arquivo :/ %v", err), http.StatusBadRequest)
		return
	}
	defer file.Close()

	filePath := filepath.Join(uploadDir, handler.Filename)
	dst, err := os.Create(filePath) // Cria o arquivo de forma vazia no servidor
	if err != nil {
		http.Error(w, fmt.Sprintf("Erro ao criar arquivo no servidor :/ %v", err), http.StatusInternalServerError)
		return
	}
	defer dst.Close()

	if _, err := io.Copy(dst, file); err != nil {
		http.Error(w, fmt.Sprintf("Erro ao salvar arquivo no servidor :/ %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	data := BaseResponse{
		StatusCode: http.StatusOK,
		Data:       fmt.Sprintf("Upload do arquivo '%s' realizado com sucesso, com tamanho %d", handler.Filename, handler.Size),
	}
	json.NewEncoder(w).Encode(data)
}

type BaseResponse struct {
	StatusCode int    `json:"status_code"`
	Data       string `json:"data"`
}
