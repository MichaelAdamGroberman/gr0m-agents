# CLAUDE.md — redai

Project-specific memory. Read together with the shared `../../CLAUDE.md` (operating
model) — the runner concatenates both.

## What this project is

redai: authorized, scoped security and red-team work — probing example-llm and related
systems for weaknesses so they get fixed before an adversary finds them.

## Team for this project

Shared core (`orchestrator`, `explorer`, `implementer`, `tester`, `reviewer`,
`router`, `planner`) plus specialists: `redteam` (offense), `security-reviewer`
(security-focused gate).

## Stack (fill in)

- Targets in scope: _TODO_ (exact systems/endpoints, in writing)
- Authorization reference: _TODO_ (who approved, scope doc link)
- Test tooling: _TODO_
- Reporting format / disclosure process: _TODO_
- Hard out-of-scope / never touch: _TODO_ (prod data, third-party systems, etc.)

## Project rules (non-negotiable)

- Only test explicitly authorized targets, in writing, within stated scope.
- Responsible disclosure: document findings, don't weaponize. Prove access with a
  benign marker; never exfiltrate real sensitive data.
- Every finding ships with a severity rating and a remediation, routed to the
  reviewer/implementer loop to actually get fixed.
