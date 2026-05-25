import urllib.request, json
prompt = "Say hello in Chinese"
data = json.dumps({"model": "qwen3.5:9b", "prompt": prompt, "stream": False, "options": {"num_predict": 20}}).encode()
req = urllib.request.Request("http://127.0.0.1:11434/api/generate", data=data, headers={"Content-Type": "application/json"})
try:
    r = urllib.request.urlopen(req, timeout=30)
    res = json.loads(r.read())
    print("OK:", res.get("response", "")[:100])
except Exception as e:
    print("Error:", e)
