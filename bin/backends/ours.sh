#!/usr/bin/env bash
# "ours" adapter — your own example-llm behind an OpenAI-compatible /chat/completions
# endpoint (vLLM, TGI, llama.cpp server, Ollama's OpenAI shim, etc.). Emits text.
# Arg: $1 = prompt file.
# Env: OWN_LLM_URL  (e.g. http://localhost:8000/v1), MODEL, optional OWN_LLM_KEY.
set -euo pipefail
prompt_file="${1:?prompt file}"
: "${OWN_LLM_URL:?set OWN_LLM_URL to your OpenAI-compatible base, e.g. http://localhost:8000/v1}"
: "${MODEL:?set BACKEND_MODEL[ours] in team.conf to your served model name}"
command -v curl >/dev/null   || { echo "curl required" >&2; exit 127; }
command -v python3 >/dev/null || { echo "python3 required (for JSON encode/decode)" >&2; exit 127; }

# Build the JSON payload safely (python handles escaping), POST, print the message.
python3 - "$prompt_file" "$MODEL" "$OWN_LLM_URL" <<'PY'
import json, os, sys, urllib.request
prompt = open(sys.argv[1]).read()
model, base = sys.argv[2], sys.argv[3].rstrip('/')
payload = json.dumps({"model": model,
                      "messages": [{"role": "user", "content": prompt}],
                      "temperature": 0.2}).encode()
req = urllib.request.Request(base + "/chat/completions", data=payload,
                            headers={"Content-Type": "application/json"})
key = os.environ.get("OWN_LLM_KEY")
if key: req.add_header("Authorization", "Bearer " + key)
with urllib.request.urlopen(req) as r:
    data = json.load(r)
print(data["choices"][0]["message"]["content"])
PY
