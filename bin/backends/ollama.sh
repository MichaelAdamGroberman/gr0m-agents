#!/usr/bin/env bash
# ollama adapter — runs the prompt on a local Ollama model. Free, offline, no key.
# Emits text; it does NOT edit files. Good for explorer/tester/data/redteam.
# Arg: $1 = prompt file. Env: $MODEL (required for ollama).
set -euo pipefail
prompt_file="${1:?prompt file}"
: "${MODEL:?ollama needs a model — set BACKEND_MODEL[ollama] in team.conf (try: ollama list)}"
command -v ollama >/dev/null || { echo "ollama not installed: https://ollama.com" >&2; exit 127; }

# >>> adjust here if your ollama version differs <<<
exec ollama run "$MODEL" < "$prompt_file"
