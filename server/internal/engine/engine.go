package engine

import (
	"encoding/json"
	"math/rand"
	"os"
	"strings"
)

type Template struct {
	ID       string            `json:"id"`
	Category string            `json:"category"`
	Keywords []string          `json:"keywords"`
	Replies  map[string]string `json:"replies"`
}

type ReplyResult struct {
	Style string `json:"style"`
	Text  string `json:"text"`
}

type Engine struct {
	templates []Template
}

func NewEngine(path string) (*Engine, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var templates []Template
	if err := json.Unmarshal(data, &templates); err != nil {
		return nil, err
	}
	return &Engine{templates: templates}, nil
}

func (e *Engine) Templates() []Template {
	return e.templates
}

func (e *Engine) Match(msg string) []ReplyResult {
	styles := []string{"humorous", "warm", "interactive"}
	var bestMatch *Template
	maxScore := 0

	for i := range e.templates {
		t := &e.templates[i]
		score := 0
		for _, kw := range t.Keywords {
			if strings.Contains(msg, kw) {
				score++
			}
		}
		if score > maxScore {
			maxScore = score
			bestMatch = t
		}
	}

	if bestMatch == nil || maxScore == 0 {
		return []ReplyResult{
			{Style: "humorous", Text: "这个问题我需要启动超级大脑来思考……好了，想好了！你说得对 👍"},
			{Style: "warm", Text: "嗯嗯，我在听呢 👂 你继续说～"},
			{Style: "interactive", Text: "🎯 话题接收成功！\n请选择后续操作：\n① 展开说说\n② 反问一个有趣的问题\n③ 可爱表情包攻击 😝"},
		}
	}

	var results []ReplyResult
	for _, style := range styles {
		if text, ok := bestMatch.Replies[style]; ok {
			results = append(results, ReplyResult{Style: style, Text: text})
		}
	}
	rand.Shuffle(len(results), func(i, j int) {
		results[i], results[j] = results[j], results[i]
	})
	return results
}
