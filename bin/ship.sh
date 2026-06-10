#!/usr/bin/env bash
# ship.sh — CLI analog of the /ship loop, now project- and tier-aware:
#   triage(implementer) → review gate. Implement needs an AGENTIC backend (codex/gemini).
#   The reviewer reads `git diff` and emits a verdict; nothing is auto-merged.
#
# Usage: bin/ship.sh <project> specs/<spec>.md [--reviewer reviewer|security-reviewer]
#   bin/ship.sh example-llm projects/example-llm/specs/add-eval-harness.md
#   bin/ship.sh redai    projects/redai/specs/api-authz-audit.md --reviewer security-reviewer
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

project="${1:?usage: ship.sh <project> specs/<spec>.md [--reviewer ROLE]}"; shift
spec="${1:?need a spec path}"; shift || true
[[ -d "$REPO/projects/$project" ]] || { echo "ship: no project '$project'" >&2; exit 2; }
[[ -f "$spec" ]] || { echo "ship: spec not found: $spec" >&2; exit 2; }

reviewer_role="reviewer"
# redai defaults to the security reviewer
[[ "$project" == "redai" ]] && reviewer_role="security-reviewer"
while [[ $# -gt 0 ]]; do
  case "$1" in --reviewer) reviewer_role="$2"; shift 2 ;; *) echo "ship: bad arg $1" >&2; exit 2 ;; esac
done

echo "== IMPLEMENT (triage) =="
"$REPO/bin/triage.sh" implementer --project "$project" --file "$spec"

echo; echo "== REVIEW GATE ($reviewer_role, project=$project) =="
diff="$(git -C "$REPO" diff)"
[[ -n "$diff" ]] || { echo "ship: no diff to review (did the implementer edit files?)" >&2; exit 0; }
printf '%s\n' "$diff" | "$REPO/bin/triage.sh" "$reviewer_role" --project "$project" \
  "Review this diff against the spec at $spec. Return VERDICT then findings."

echo; echo "ship: review complete. You are the final gate — read the verdict, then merge or iterate."
