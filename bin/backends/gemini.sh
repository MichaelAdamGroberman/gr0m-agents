#!/usr/bin/env bash
# gemini adapter — Google Gemini CLI, non-interactive prompt. Can use tools/edit
# files when run in a repo. Good for orchestrator/reviewer.
# Arg: $1 = prompt file. Env: $MODEL (optional), GEMINI_API_KEY (or logged-in).
set -euo pipefail
prompt_file="${1:?prompt file}"
command -v gemini >/dev/null || { echo "gemini not installed: npm i -g @google/gemini-cli" >&2; exit 127; }

model_args=(); [[ -n "${MODEL:-}" ]] && model_args=(-m "$MODEL")

# >>> adjust here if your Gemini CLI version differs <<<
# -p runs a single non-interactive prompt. Prompt is piped on stdin.
exec gemini "${model_args[@]}" -p "$(cat "$prompt_file")"
