#!/usr/bin/env bash
# triage.sh — route a task to the right model tier, intelligently.
#
#   simple   -> cheapest model does it directly
#   complex  -> smartest model does it directly
#   medium   -> smartest model writes an explicit recipe, cheapest model executes it
#
# Classification is done by the `router` role on the cheap tier (cheap to decide),
# then the effective tier is raised to the role's floor (ROLE_TIER) so you never
# cheap out the gate (e.g. reviewer/redteam stay COMPLEX even on "simple"-looking work).
#
# Usage:
#   bin/triage.sh <role> [--project P] [--tier auto|simple|medium|complex] [TASK...]
#   bin/triage.sh implementer --project example-llm --file specs/add-eval-harness.md
#   bin/triage.sh explorer "list the training entrypoints"        # likely SIMPLE
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO/team.conf"; source "$REPO/tiers.conf"

role="${1:?usage: triage.sh <role> [--project P] [--tier auto|simple|medium|complex] [TASK...]}"; shift || true
project="${TEAM_PROJECT:-}"; want_tier="auto"; task=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) project="$2"; shift 2 ;;
    --tier)    want_tier="$2"; shift 2 ;;
    --file)    task="$(cat "$2")"; shift 2 ;;
    --) shift; task="$task${task:+ }$*"; break ;;
    *) task="$task${task:+ }$1"; shift ;;
  esac
done
if [[ -z "$task" && ! -t 0 ]]; then task="$(cat)"; fi
[[ -n "$task" ]] || { echo "triage: no task given" >&2; exit 2; }
proj_args=(); [[ -n "$project" ]] && proj_args=(--project "$project")
# load project floors too
[[ -n "$project" && -f "$REPO/projects/$project/team.conf" ]] && source "$REPO/projects/$project/team.conf"

tier_index() { case "$1" in simple) echo 0;; medium) echo 1;; complex) echo 2;; *) echo 0;; esac; }
tier_max() { (( $(tier_index "$1") >= $(tier_index "$2") )) && echo "$1" || echo "$2"; }

# 1) classify (unless forced)
if [[ "$want_tier" == "auto" ]]; then
  echo "triage: classifying with router (simple tier)…" >&2
  verdict="$("$REPO/bin/run-agent.sh" router "${proj_args[@]}" --tier simple "$task" 2>/dev/null || true)"
  tier="$(printf '%s' "$verdict" | grep -oiE 'SIMPLE|MEDIUM|COMPLEX' | head -1 | tr '[:upper:]' '[:lower:]')"
  tier="${tier:-medium}"   # safe default if the classifier is unclear
  echo "triage: classified=$tier  ($(printf '%s' "$verdict" | head -1))" >&2
else
  tier="$want_tier"
fi

# 2) apply the role floor — never drop below ROLE_TIER for this role
floor="${ROLE_TIER[$role]:-simple}"
eff="$(tier_max "$tier" "$floor")"
[[ "$eff" != "$tier" ]] && echo "triage: raised to '$eff' (role floor for $role)" >&2

# 3) dispatch
case "$eff" in
  simple|complex)
    echo "triage: running $role directly on $eff tier" >&2
    exec "$REPO/bin/run-agent.sh" "$role" "${proj_args[@]}" --tier "$eff" "$task"
    ;;
  medium)
    echo "triage: MEDIUM — planner(complex) writes recipe → $role(simple) executes" >&2
    plan="$("$REPO/bin/run-agent.sh" planner "${proj_args[@]}" --tier complex "$task")"
    if printf '%s' "$plan" | grep -qiE '^ESCALATE:'; then
      echo "triage: planner escalated — running $role on COMPLEX instead" >&2
      exec "$REPO/bin/run-agent.sh" "$role" "${proj_args[@]}" --tier complex "$task"
    fi
    echo "----- PLAN (from complex model) -----" >&2
    printf '%s\n' "$plan" >&2
    echo "----- executing on simple model -----" >&2
    exec "$REPO/bin/run-agent.sh" "$role" "${proj_args[@]}" --tier simple \
      "Follow this plan EXACTLY, step by step. Do not deviate or add steps.

$plan

ORIGINAL TASK (for context only): $task"
    ;;
esac
