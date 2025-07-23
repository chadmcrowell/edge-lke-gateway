package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/api/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("ok"))
	})
	http.ListenAndServe(":8080", nil)
}
