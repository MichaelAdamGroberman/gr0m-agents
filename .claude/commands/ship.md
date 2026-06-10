---
description: Run the full director workflow on a spec — plan, delegate, review, hand back
argument-hint: specs/<spec-file>.md
---

Execute the workflow in `docs/WORKFLOW.md` for this spec: $ARGUMENTS

Use the `orchestrator` subagent to drive it. The orchestrator should:

1. Read the spec, `CLAUDE.md`, and `docs/WORKFLOW.md`.
2. Plan the work into a short, ordered task list.
3. Delegate: `explorer` to map the code → `implementer` to make the change →
   `tester` to cover the acceptance criteria.
4. Run the `reviewer` gate on the result. If the reviewer returns any BLOCKER,
   route it back to the implementer and re-review. Nothing is done until the
   reviewer passes.
5. Hand back to me with: summary, files changed (+ rationale), the reviewer's
   verdict, and any open judgment calls.

Stop and ask me on genuine direction/tradeoff decisions — don't guess on calls that
are mine to make. Do not merge or push; I am the final review gate.
