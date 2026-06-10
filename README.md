# Agent Team Builder

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
![status: pre-release](https://img.shields.io/badge/status-pre--release-orange)

A multi-agent coding-team scaffold built around the operating model in Anthropic's
[*When AI builds itself*](https://www.anthropic.com/institute/recursive-self-improvement):

> **Humans set the goal and review the work. Agents supply the method and do the doing.
> Every change passes an automated review gate before it merges.**

This is the publicly reproducible version of that model — not Anthropic's internal
tooling. It uses standard Claude Code mechanics (`CLAUDE.md`, subagents, slash
commands, settings) so it works in any repo you drop it into.

## The model in one picture

```
        you (director)                      "What's worth building?"  ← your job
              │  sets goal / writes spec
              ▼
        orchestrator  ───────────────┐      plans + delegates, long horizon
              │                      │
   ┌──────────┼──────────┐           │
   ▼          ▼          ▼           │
 explorer  implementer  tester       │      the doing — near-zero human time
   │          │          │           │
   └──────────┴────┬─────┘           │
                   ▼                 │
               reviewer  ◄───────────┘      automated gate: bugs/security/quality
                   │                        nothing merges unless this passes
                   ▼
              you review ──────────────────► the real bottleneck. Protect it.
```

## The team

Two projects under `projects/` — **example-llm** (training + serving) and **redai**
(security) — sharing a core team, each with its own specialists. Full roster and
structure in `docs/TEAM.md`.

Because there's no Anthropic API, every role runs on a **CLI backend you control**
(Codex / Gemini / Ollama / your own example-llm endpoint), and a **triage layer** routes
each task to the right model tier:

- **simple** → cheapest model does it directly
- **complex** → smartest model does it directly
- **medium** → smartest model writes an explicit recipe, cheapest model executes it

A per-role *floor* keeps the review/security gates on the smart model even for
"simple"-looking work. Details in `docs/TRIAGE.md`.

## How to use it

**CLI path (what you have now):**
```bash
# triage picks the tier automatically:
bin/triage.sh explorer    --project example-llm "where is the training loop?"
bin/triage.sh implementer --project example-llm --file projects/example-llm/specs/add-eval-harness.md
bin/triage.sh redteam     --project redai    "threat-model the serving API"

# full loop for a project (implement → review gate):
bin/ship.sh example-llm projects/example-llm/specs/add-eval-harness.md
```

**Native path (if you add a Claude Code backend later):** the core roles also exist
as subagents under `.claude/agents/`, driven by `/spec`, `/ship`, `/review`.

The loop is unchanged: **state a goal → `/spec` writes the spec → orchestrator
delegates → reviewer gates → you decide merge / iterate.**

See `docs/TEAM.md` (roster + backends + setup) and `docs/TRIAGE.md` (routing).

## Layout

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Project memory — the rules every agent reads first |
| `docs/WORKFLOW.md` | The operating model, written out in full |
| `specs/TEMPLATE.md` | Goal → spec template (goal, non-goals, acceptance) |
| `.claude/agents/` | Subagent definitions (orchestrator, implementer, reviewer, tester, explorer) |
| `.claude/commands/` | `/spec`, `/ship`, `/review` slash commands |
| `.claude/settings.json` | Shared project settings |

## Why each piece exists (from the article)

- **Spec-first** — "humans supply the goal; they no longer need to supply the method."
- **Subagents + orchestrator** — "agents can now run code themselves and delegate hours of work to other agents."
- **Reviewer gate** — an automated Claude review of every change "would have caught roughly a third of the bugs behind past incidents before they reached production."
- **Protect review capacity** — once generation outpaces review, "human review becomes the bottleneck" (Amdahl's law). Don't scale doing without scaling checking.

## Project meta

- **Author / maintainer:** Michael Groberman — <michael.groberman@icloud.com> (see [`AUTHORS.md`](AUTHORS.md)).
- **License:** MIT — see [`LICENSE`](LICENSE).
- **Contributing:** [`CONTRIBUTING.md`](CONTRIBUTING.md) · [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)
- **Security / responsible use:** [`SECURITY.md`](SECURITY.md) — read before using `projects/redai`.
- **Changes:** [`CHANGELOG.md`](CHANGELOG.md).
- **Packaging:** `scripts/build-skill.sh` builds an installable `.skill` from `skill/SKILL.md` + the scaffold.
- **Status:** pre-release (`v0.1.0`), private. `projects/example-llm` and `projects/redai` are example projects — rename or remove them for your own use.

> This is the publicly reproducible version of the operating model, not Anthropic's internal tooling.

---

<sub>Created by **Michael Groberman** · MIT licensed · © 2026</sub>
