package llm

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"
)

const PromptTmpl = `你是一个帮人回复消息的助手，非常擅长聊天。

对方发来的消息：%s

请用三种不同风格的回复来回应这条消息，每种风格一条。

风格要求：
1. 幽默（humorous）：风趣幽默，让人会心一笑
2. 暖心（warm）：温暖真诚，让人感到被关心
3. 互动（interactive）：有互动性，引导对方继续聊下去

每条回复不超过30字，直接输出回复内容，每条一行，按风格顺序输出，不要序号和额外说明。`

const defaultOllamaURL = "http://127.0.0.1:11434"

type Client struct {
	baseURL string
	model   string
	http    *http.Client
}

type generateRequest struct {
	Model   string `json:"model"`
	Prompt  string `json:"prompt"`
	Stream  bool   `json:"stream"`
	Options struct {
		NumPredict int     `json:"num_predict"`
		Temp       float64 `json:"temperature"`
	} `json:"options"`
}

type generateResponse struct {
	Response string `json:"response"`
	Done     bool   `json:"done"`
}

func NewClient(model string) *Client {
	if model == "" {
		model = "qwen3.5:9b"
	}
	return &Client{
		baseURL: defaultOllamaURL,
		model:   model,
		http:    &http.Client{Timeout: 120 * time.Second},
	}
}

func (c *Client) Reply(msg string) ([]ReplyResult, error) {
	prompt := fmt.Sprintf(PromptTmpl, msg)
	reqBody := generateRequest{
		Model:  c.model,
		Prompt: prompt,
		Stream: false,
	}
	reqBody.Options.NumPredict = 300
	reqBody.Options.Temp = 0.85

	body, _ := json.Marshal(reqBody)
	resp, err := c.http.Post(c.baseURL+"/api/generate", "application/json", bytes.NewReader(body))
	if err != nil {
		return nil, fmt.Errorf("ollama request failed: %w", err)
	}
	defer resp.Body.Close()

	var result generateResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("ollama response parse failed: %w", err)
	}

	if result.Response == "" {
		return nil, fmt.Errorf("ollama returned empty response")
	}

	return parseReplies(result.Response), nil
}

func parseReplies(text string) []ReplyResult {
	lines := strings.Split(strings.TrimSpace(text), "\\n")
	styles := []string{"humorous", "warm", "interactive"}
	results := make([]ReplyResult, 0, 3)

	for i, line := range lines {
		line = strings.TrimSpace(line)
		line = strings.TrimPrefix(line, "- ")
		for _, p := range []string{"1. ", "2. ", "3. "} {
			line = strings.TrimPrefix(line, p)
		}
		for _, p := range []string{"• "} {
			line = strings.TrimPrefix(line, p)
		}
		for _, p := range []string{"幽默", "暖心", "互动"} {
		for _, sep := range []string{"：", ": "} {
			line = strings.TrimPrefix(line, p+sep)
		}
		}
		if line == "" {
			continue
		}
		if i < len(styles) {
			results = append(results, ReplyResult{
				Style: styles[i],
				Text:  line,
			})
		}
	}

	if len(results) < 3 {
		results = results[:0]
		for _, line := range lines {
			line = strings.TrimSpace(line)
			if line == "" {
				continue
			}
			results = append(results, ReplyResult{
				Style: styles[len(results)%3],
				Text:  line,
			})
		}
	}

	return results
}

type ReplyResult struct {
	Style string `json:"style"`
	Text  string `json:"text"`
}