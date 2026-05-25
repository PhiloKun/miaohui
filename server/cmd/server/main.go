package main

import (
	"flag"
	"log"
	"path/filepath"

	"miaohui/internal/engine"
	"miaohui/internal/handler"
	"miaohui/internal/llm"
)

func main() {
	port := flag.String("port", "8099", "service port")
	tplPath := flag.String("templates", "", "template file path")
	frontendDir := flag.String("frontend", "", "frontend static directory")
	model := flag.String("model", "qwen3.5:9b", "Ollama model name (empty = template engine)")
	flag.Parse()

	path := *tplPath
	if path == "" {
		path = filepath.Join("templates", "templates.json")
	}

	e, err := engine.NewEngine(path)
	if err != nil {
		log.Fatalf("Failed to load templates: %v", err)
	}
	log.Printf("Loaded %d templates", len(e.Templates()))

	var llmClient *llm.Client
	if *model != "" {
		llmClient = llm.NewClient(*model)
		log.Printf("Ollama model enabled: %s", *model)
	} else {
		log.Println("No model specified, using template engine")
	}

	addr := "0.0.0.0:" + *port

	if *frontendDir != "" {
		handler.StartWithFrontend(addr, e, llmClient, *frontendDir)
	} else {
		handler.Start(addr, e, llmClient)
	}
}