# miaohui

> AI smart reply assistant - Don't know how to reply? AI helps you!

## Features

- AI-powered replies: Humorous, warm, interactive styles
- Material 3 design with dark mode support
- Cross-platform: Web / Android / iOS / Windows / macOS / Linux
- Privacy-first: Fully offline with template engine
- LLM integration: Supports Ollama local models

## Quick Start

### Web Version

```bash
cd app && flutter build web --release
cd ../server && go build -o server.exe ./cmd/server/
./server.exe -port=8099 -frontend=```../app/build/web```
open http://127.0.0.1:8099
```

### Android APK

Download from [Releases](https://github.com/PhiloKun/miaohui/releases) page.

### Local LLM

```bash
ollama pull qwen2.5:0.5b
./server.exe -port=8099 -model=qwen2.5:0.5b -frontend=../app/build/web
```

## Tech Stack

| Component | Tech |
|-----------|------|
| Frontend | Flutter 3.41 + Material 3 |
| Backend | Go 1.26 |
| LLM | Ollama (qwen3.5:9b / qwen2.5:0.5b) |
| Local Inference | llama.cpp (via dart:ffi) |
| CI/CD | GitHub Actions |

## Project Structure

```
miaohui/
  app/              # Flutter frontend
    lib/            # Dart source code
    android/        # Android platform + llama bridge
  server/           # Go backend
    internal/       # Engine, handler, LLM client
    templates/      # 10 reply categories
  .github/workflows/# CI/CD: APK build
```

## License

MIT
