package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"miaohui/internal/engine"
	"miaohui/internal/llm"
)

type ReplyRequest struct {
	Message string `json:"message"`
}

type ReplyResponse struct {
	Replies []llm.ReplyResult `json:"replies"`
}

type Handler struct {
	engine *engine.Engine
	llm    *llm.Client
}

func New(e *engine.Engine, llmClient *llm.Client) *Handler {
	return &Handler{engine: e, llm: llmClient}
}

func (h *Handler) Reply(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	var req ReplyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}
	if req.Message == "" {
		http.Error(w, "message is required", http.StatusBadRequest)
		return
	}

	var replies []llm.ReplyResult
	if h.llm != nil {
		llmReplies, err := h.llm.Reply(req.Message)
		if err != nil {
			log.Printf("LLM reply failed, fallback to template: %v", err)
			replies = engineRepliesToLLM(h.engine.Match(req.Message))
		} else {
			replies = llmReplies
		}
	} else {
		replies = engineRepliesToLLM(h.engine.Match(req.Message))
	}

	resp := ReplyResponse{Replies: replies}
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(resp)
}

func engineRepliesToLLM(results []engine.ReplyResult) []llm.ReplyResult {
	converted := make([]llm.ReplyResult, len(results))
	for i, r := range results {
		converted[i] = llm.ReplyResult{Style: r.Style, Text: r.Text}
	}
	return converted
}

func (h *Handler) Health(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func Start(addr string, e *engine.Engine, llmClient *llm.Client) {
	h := New(e, llmClient)
	mux := http.NewServeMux()
	h.Register(mux)
	handler := cors(mux)
	log.Printf("秒回 API service started at http://%s", addr)
	log.Fatal(http.ListenAndServe(addr, handler))
}

func StartWithFrontend(addr string, e *engine.Engine, llmClient *llm.Client, webDir string) {
	h := New(e, llmClient)
	mux := http.NewServeMux()
	h.Register(mux)

	absDir, _ := filepath.Abs(webDir)
	fs := http.FileServer(http.Dir(absDir))
	mux.Handle("GET /", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path := filepath.Join(absDir, r.URL.Path)
		if _, err := os.Stat(path); os.IsNotExist(err) {
			http.ServeFile(w, r, filepath.Join(absDir, "index.html"))
			return
		}
		fs.ServeHTTP(w, r)
	}))

	handler := cors(mux)
	log.Printf("秒回 fullstack service started at http://%s", addr)
	log.Printf("Frontend dir: %s", absDir)
	log.Fatal(http.ListenAndServe(addr, handler))
}

func (h *Handler) Register(mux *http.ServeMux) {
	mux.HandleFunc("POST /api/reply", h.Reply)
	mux.HandleFunc("GET /api/health", h.Health)
}

func cors(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}