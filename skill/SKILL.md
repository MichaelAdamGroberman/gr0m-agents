---
name: agent-team-builder
description: >-
  Scaffold a multi-agent coding team with complexity-based task triage and CLI
  model backends, following Anthropic's "humans set goals and review, agents do
  the work, an automated reviewer gates every change" operating model. Use when
  the user wants to set up, scaffold, or restructure an agent team/workflow for a
  codebase — triggers include "set up my agents", "agent team", "agent workflow",
  "orchestrator and subagents", "spec then review pipeline", "route tasks to
  cheap vs smart models", "triage tasks by complexity", or when they have no
  Anthropic API and need CLI/local-model agents (Codex, Gemini CLI, Ollama, or a
  self-hosted OpenAI-compatible endpoint). Produces a spec → implement → review
  loop with per-project specialists and a cost-aware model router.
---

# Agent Team Builder

Scaffolds a working multi-agent software team into a target folder. The team
follows the operating model in Anthropic's *When AI builds itself*: **humans set
goals and review; agents supply the method and do the work; an automated reviewer
gates every change.** It runs without an Anthropic API by dispatching each role to
whatever CLI/model backend the user has, and it triages each task to the right
model tier (cheap for simple, smart for complex, smart-plans-cheap-executes for
medium).

## When to use

Use this when the user wants a structured agent team for coding work — not a
one-off task. Signals: "set up my agents", "build me an agent team/workflow",
"orchestrator + subagents", "route tasks to cheap/smart models", "triage by
complexity", or "we have no Anthropic API, agents must be CLI-based".

Do NOT use it to run a single coding task — just do that task.

## What it produces

```
<target>/
  CLAUDE.md              shared operating model (every agent reads it first)
  README.md              orientation
  docs/WORKFLOW.md       the human-as-director loop
  docs/TEAM.md           roster, backends, setup checklist
  docs/TRIAGE.md         how complexity routing works
  agents/                shared role briefs: orchestrator, explorer,
                         implementer, tester, reviewer, router, planner
  bin/run-agent.sh       run one role on a CLI backend (prepends CLAUDE.md + brief)
  bin/triage.sh          classify a task, route to the right model tier
  bin/ship.sh            implement (triaged) → review-gate loop
  bin/backends/          adapters: fable.sh, codex.sh, gemini.sh, ollama.sh, ours.sh
  team.conf              shared roster: role→backend + complexity floors
  tiers.conf             simple/complex → backend+model (the cost dials)
  .claude/               native Claude Code mirror (agents + /spec /ship /review)
  specs/TEMPLATE.md      goal → spec template
  projects/<name>/       per-project CLAUDE.md, team.conf, specs/, specialist agents
```

## How to instantiate

1. **Confirm the target folder** and ask two things if unknown: (a) which CLI/model
   backends they have (Ollama, Codex, Gemini, a self-hosted model), and (b) the
   project name(s) and domain so you can tailor specialists.
2. **Copy `templates/` into the target folder** (everything under this skill's
   `templates/` directory). Then `chmod +x bin/*.sh bin/backends/*.sh`.
3. **Set the cost dials in `tiers.conf`**: map `simple` to their cheapest model and
   `complex` to their smartest. CLI flags in `bin/backends/*.sh` have a
   `>>> adjust <<<` line — verify against the installed CLI versions.
4. **Fill the Stack section** in each `projects/<name>/CLAUDE.md` (test command,
   build, off-limits paths) — agents read it first.
5. **Smoke test**: `bin/run-agent.sh explorer --project <name> "summarize this repo"`.

## How the triage works (the cost-saver)

`bin/triage.sh <role> --project <p> "task"` →
- a cheap `router` call classifies the task SIMPLE / MEDIUM / COMPLEX;
- the tier is raised to the role's **floor** (`ROLE_TIER` in `team.conf`) so review
  and security roles never run on the cheap model even for easy-looking tasks;
- **SIMPLE** runs the role directly on the cheap tier; **COMPLEX** runs it on the
  smart tier; **MEDIUM** has the smart model (`planner`) write an explicit recipe,
  then the cheap model executes it. The planner can `ESCALATE`, falling back to the
  smart model.

Tune behavior with two dials only: `tiers.conf` (what simple/complex map to) and the
`ROLE_TIER` floors in `team.conf` and each `projects/<p>/team.conf`.

## Extending

- **Add a role**: drop a brief in `agents/<role>.md` (or `projects/<p>/agents/`),
  then set `ROLE_BACKEND[<role>]` and `ROLE_TIER[<role>]` in the relevant `team.conf`.
- **Add a project**: `mkdir projects/<new>/{agents,specs}`, add `CLAUDE.md` and a
  `team.conf` that appends its specialists' backends/floors.
- **Add a backend**: add `bin/backends/<name>.sh` (takes a prompt file as `$1`, uses
  `$MODEL`), then reference it in `team.conf`/`tiers.conf`.

## Notes

- This is the publicly reproducible version of the operating model, not Anthropic's
  internal tooling.
- The native `.claude/` path (subagents + `/spec`, `/ship`, `/review`) only runs if
  the user has a Claude Code/Anthropic backend; the `bin/` CLI path needs none.
- Keep changes small and let the reviewer gate everything — protecting human review
  capacity is the whole point of the model (Amdahl's law).
