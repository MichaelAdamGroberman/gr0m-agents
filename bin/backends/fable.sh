#!/usr/bin/env bash
# fable adapter — Claude (Fable-class) CLI, non-interactive. Agentic: can read/edit
# files in the repo. The strongest reasoning backend — good for the complex tier:
# orchestrator, planner, reviewer, implementer.
# Arg: $1 = prompt file. Env: $MODEL (optional), $REPO (repo root), ANTHROPIC_API_KEY.
set -euo pipefail
prompt_file="${1:?prompt file}"
command -v fable >/dev/null || { echo "fable CLI not installed: see your Claude/Fable CLI setup" >&2; exit 127; }

model_args=(); [[ -n "${MODEL:-}" ]] && model_args=(-m "$MODEL")

# >>> adjust here if your CLI differs <<<
# Single non-interactive turn, scoped to the repo. Add sandbox/auto flags to taste.
exec fable run "${model_args[@]}" --cd "${REPO:-$PWD}" "$(cat "$prompt_file")"
