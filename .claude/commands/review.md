---
description: Run the automated review gate on the current changes
argument-hint: [optional: path or "staged" / "branch"]
---

Run the `reviewer` subagent on the current changes: $ARGUMENTS

If no argument is given, review the uncommitted working-tree changes (`git diff`).
If "staged" is given, review staged changes. If a path is given, review that path.
If a branch/range is given, review that diff.

The reviewer must return a VERDICT (PASS | CHANGES REQUIRED) followed by findings
grouped as BLOCKER / WARNING / NIT, each citing `file:line`. Do not fix anything in
this command — just report. I decide what happens next.
