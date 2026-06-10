#!/usr/bin/env bash
# run-agent.sh — run one team role on a CLI backend (no Anthropic API required).
#
# Usage:
#   bin/run-agent.sh <role> [--project P] [--backend B] [--model M] [--tier T] [TASK...]
#   bin/run-agent.sh <role> --file path/to/task_or_spec.md
#   echo "do X" | bin/run-agent.sh <role>
#
#   --project example-llm|redai   load that project's roster + CLAUDE.md + specialists
#   --tier simple|complex      pick backend+model from tiers.conf (overrides role default)
#   --backend / --model        explicit override (wins over --tier and roster)
#
# Resolution order for a brief: projects/<P>/agents/<role>.md, then agents/<role>.md.
# Prompt = shared CLAUDE.md (+ project CLAUDE.md) + the role brief + your TASK.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/team.conf"
source "$REPO/tiers.conf"

role="${1:?usage: run-agent.sh <role> [--project P] [--backend B] [--model M] [--tier T] [TASK...]}"; shift || true

project="${TEAM_PROJECT:-}"; backend=""; model=""; tier=""; task=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) project="$2"; shift 2 ;;
    --backend) backend="$2"; shift 2 ;;
    --model)   model="$2";   shift 2 ;;
    --tier)    tier="$2";    shift 2 ;;
    --file)    task="$(cat "$2")"; shift 2 ;;
    --) shift; task="$task${task:+ }$*"; break ;;
    *) task="$task${task:+ }$1"; shift ;;
  esac
done
if [[ -z "$task" && ! -t 0 ]]; then task="$(cat)"; fi

# load project roster overrides + locate project dir
proj_dir=""
if [[ -n "$project" ]]; then
  proj_dir="$REPO/projects/$project"
  [[ -d "$proj_dir" ]] || { echo "run-agent: no project '$project' ($proj_dir)" >&2; exit 2; }
  [[ -f "$proj_dir/team.conf" ]] && source "$proj_dir/team.conf"
fi

# locate the brief: project first, then shared
brief=""
[[ -n "$proj_dir" && -f "$proj_dir/agents/${role}.md" ]] && brief="$proj_dir/agents/${role}.md"
[[ -z "$brief" && -f "$REPO/agents/${role}.md" ]] && brief="$REPO/agents/${role}.md"
[[ -n "$brief" ]] || { echo "run-agent: unknown role '$role' (looked in project + shared agents/)" >&2; exit 2; }

# resolve backend + model: explicit flag > tier > role default
if [[ -n "$tier" ]]; then
  [[ -n "${TIER_BACKEND[$tier]:-}" ]] || { echo "run-agent: unknown tier '$tier'" >&2; exit 2; }
  backend="${backend:-${TIER_BACKEND[$tier]}}"
  model="${model:-${TIER_MODEL[$tier]:-}}"
fi
backend="${backend:-${ROLE_BACKEND[$role]:-}}"
[[ -n "$backend" ]] || { echo "run-agent: no backend for role '$role' — pass --backend or --tier" >&2; exit 2; }
adapter="$REPO/bin/backends/${backend}.sh"
[[ -x "$adapter" ]] || { echo "run-agent: no adapter for backend '$backend' ($adapter)" >&2; exit 2; }
model="${model:-${BACKEND_MODEL[$backend]:-}}"

# assemble the prompt
prompt_file="$(mktemp "${TMPDIR:-/tmp}/grom-agent.XXXXXX")"
trap 'rm -f "$prompt_file"' EXIT
{
  echo "# OPERATING MODEL (CLAUDE.md)"
  [[ -f "$REPO/CLAUDE.md" ]] && cat "$REPO/CLAUDE.md"
  if [[ -n "$proj_dir" && -f "$proj_dir/CLAUDE.md" ]]; then
    echo; echo "# PROJECT MEMORY ($project)"; cat "$proj_dir/CLAUDE.md"
  fi
  echo; echo "# YOUR ROLE"; cat "$brief"
  echo; echo "# TASK"; echo "${task:-(no task given — ask for clarification)}"
} > "$prompt_file"

echo "run-agent: role=$role project=${project:-<shared>} backend=$backend model=${model:-<cli default>}${tier:+ tier=$tier}" >&2
MODEL="$model" REPO="$REPO" exec "$adapter" "$prompt_file"
