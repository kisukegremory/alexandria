package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

const (
	// TargetUrl   = "http://localhost:8080/simulacao"
	Concurrency = 2
	MinSleep    = 10 * time.Millisecond
	MaxSleep    = 1000 * time.Millisecond
)

var TargetUrl string

type SimulationRequest struct {
	CPF    string  `json:"cpf"`
	Amount float64 `json:"amount"`
}

func main() {
	stopChan := make(chan os.Signal, 1)
	signal.Notify(stopChan, os.Interrupt, syscall.SIGTERM)

	fmt.Printf("🔥 Iniciando Load Generator Infinito...\n")
	fmt.Printf("👥 Workers: %d\n", Concurrency)
	fmt.Printf("🎯 Alvo: %s\n", TargetUrl)
	fmt.Printf("🛑 Pressione CTRL+C para parar.\n\n")

	var wg sync.WaitGroup

	TargetUrl = getTargetURL()

	quit := make(chan bool)

	for range Concurrency {
		wg.Add(1)
		go worker(&wg, quit)
	}

	<-stopChan

	fmt.Println("\n\n⚠️  Parando motores... aguarde os workers terminarem. (Graceful Shutdown)")

	// Avisa os workers para pararem (Broadcast)
	close(quit)

	// Espera todos eles terminarem o que estavam fazendo
	wg.Wait()

	fmt.Println("✅ Encerrado com sucesso.")

}

func worker(wg *sync.WaitGroup, quit <-chan bool) {
	defer wg.Done()

	for {
		select {
		case <-quit:
			return
		default:
			payload := generatePayload()
			status := sendRequest(payload)
			switch status {
			case http.StatusOK:
				fmt.Print("✅") // Sucesso
			case http.StatusForbidden:
				fmt.Print("🔥") // Negado (Regra de negócio)
			default:
				fmt.Print("🔴") // Erro (500 ou queda)
			}

			sleepTime := MinSleep + time.Duration(rand.Intn(int(MaxSleep-MinSleep)))
			time.Sleep(sleepTime)
		}
	}
}

func generatePayload() SimulationRequest {
	amount := 1000 + rand.Float64()*9000
	cpf := fmt.Sprintf("%03d.%03d.%03d-%02d", rand.Intn(999), rand.Intn(999), rand.Intn(999), rand.Intn(99))
	return SimulationRequest{CPF: cpf, Amount: amount}
}

func sendRequest(data SimulationRequest) int {
	jsonData, _ := json.Marshal(data) // we create the payload so not required to treat now
	resp, err := http.Post(TargetUrl, "application/json", bytes.NewBuffer(jsonData))

	if err != nil {
		return 0
	}

	defer resp.Body.Close()
	return resp.StatusCode

}

func getTargetURL() string {
	url := os.Getenv("API_ENDPOINT")
	if url == "" {
		url = "http://localhost:8080/simulacao" // fallback
	}
	return url
}
