#!/usr/bin/env bash
# codex adapter — OpenAI Codex CLI, non-interactive. Agentic: can read/edit files
# in the repo. Good for implementer/reviewer/ml-trainer/inference-engineer.
# Arg: $1 = prompt file. Env: $MODEL (optional), $REPO (repo root), OPENAI_API_KEY.
set -euo pipefail
prompt_file="${1:?prompt file}"
command -v codex >/dev/null || { echo "codex not installed: npm i -g @openai/codex" >&2; exit 127; }

model_args=(); [[ -n "${MODEL:-}" ]] && model_args=(-m "$MODEL")

# >>> adjust here if your Codex CLI version differs <<<
# `codex exec` runs a single non-interactive turn. --cd scopes it to the repo.
# Add `--full-auto` / sandbox flags per your trust level; left off for safety.
exec codex exec "${model_args[@]}" --cd "${REPO:-$PWD}" "$(cat "$prompt_file")"
