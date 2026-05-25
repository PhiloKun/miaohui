import urllib.request, json
prompt = """你是一个帮人回复消息的助手。对方发来"今天好累啊"，请用3种风格回复（幽默/暖心/互动），每条不超过30字，只输出回复内容。"""
data = json.dumps({"model": "qwen3.5:9b", "prompt": prompt, "stream": False, "options": {"num_predict": 200, "temperature": 0.8}}).encode()
req = urllib.request.Request("http://127.0.0.1:11434/api/generate", data=data, headers={"Content-Type": "application/json"})
r = urllib.request.urlopen(req, timeout=120)
res = json.loads(r.read())
with open(r"D:\Code\projects\miaohui\_ollama_test.txt", "w", encoding="utf-8") as f:
    f.write(res["response"])
print("OK - saved", len(res["response"]), "chars")
