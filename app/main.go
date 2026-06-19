// Minimal, dependency-free HTTP service used to demonstrate the full
// build -> scan -> SBOM -> sign -> GitOps deploy pipeline.
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"sync/atomic"
	"time"
)

var ready atomic.Bool

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	})

	mux.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
		if !ready.Load() {
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ready"))
	})

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string]string{
			"app":      "demo-app",
			"version":  os.Getenv("APP_VERSION"),
			"hostname": hostname(),
		})
	})

	// Simulate warm-up before reporting ready.
	go func() {
		time.Sleep(2 * time.Second)
		ready.Store(true)
	}()

	srv := &http.Server{
		Addr:              ":8080",
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}
	log.Println("demo-app listening on :8080")
	log.Fatal(srv.ListenAndServe())
}

func hostname() string {
	h, _ := os.Hostname()
	return h
}
