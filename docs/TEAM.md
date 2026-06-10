# The Team

Two projects — **example-llm** (LLM training + serving) and **redai** (security) — share
a core team and add their own specialists. No Anthropic API, so each role runs on a
CLI backend you control, and a triage layer routes each task to the right model tier
(see `docs/TRIAGE.md`). Operating model unchanged (`docs/WORKFLOW.md`): humans set
goals and review; agents do the doing; the reviewer gates every change.

## Structure

```
agent-team-builder/
  agents/            shared core briefs: orchestrator, explorer, implementer,
                     tester, reviewer, router, planner
  bin/               run-agent.sh · triage.sh · ship.sh · backends/
  team.conf          shared roster defaults (backends + complexity floors)
  tiers.conf         simple/complex → backend+model (the triage dials)
  projects/
    example-llm/        CLAUDE.md · team.conf · specs/ · agents/{ml-trainer,
                     inference-engineer, data-engineer}
    redai/           CLAUDE.md · team.conf · specs/ · agents/{redteam,
                     security-reviewer}
```

## Roster

| Role | Owns | Floor tier | Project |
|---|---|---|---|
| `orchestrator` | Plans a spec, delegates | complex | shared |
| `explorer` | Maps code (read-only) | simple | shared |
| `implementer` | Writes the change | medium | shared |
| `tester` | Tests vs acceptance criteria | simple | shared |
| `reviewer` | **The gate** — bugs, security, legibility | complex | shared |
| `router` | Classifies task complexity | simple | shared |
| `planner` | Writes recipes for cheap models (medium tier) | complex | shared |
| `ml-trainer` | Training/fine-tuning experiments, evals | complex | example-llm |
| `inference-engineer` | Serving, quantization, latency | medium | example-llm |
| `data-engineer` | Datasets, pipelines, quality gates | simple | example-llm |
| `redteam` | Authorized adversarial testing | complex | redai |
| `security-reviewer` | Security-focused review gate | complex | redai |

"Floor tier" = the lowest model tier triage will use for that role; a hard task can
push it higher, never lower. Backends/floors live in `team.conf` (shared) and each
`projects/<p>/team.conf` (overrides).

## Two ways to run a role

**1. CLI path (no Anthropic API — what you have now)**
```bash
# triage decides the tier (recommended):
bin/triage.sh explorer    --project example-llm "where is the training loop?"
bin/triage.sh implementer --project example-llm --file projects/example-llm/specs/add-eval-harness.md
bin/triage.sh redteam     --project redai    "threat-model the serving API"

# direct run on a role's default backend (no triage):
bin/run-agent.sh tester --project example-llm "write tests for tokenizer.py"
bin/run-agent.sh reviewer --project redai --backend gemini < <(git diff)

# full loop for a project: implement (triaged) → review gate:
bin/ship.sh example-llm projects/example-llm/specs/add-eval-harness.md
```
`run-agent.sh` prepends shared `CLAUDE.md` + the project `CLAUDE.md` + the role brief
(project `agents/` first, then shared `agents/`), then sends it to the backend
adapter in `bin/backends/`. `triage.sh` wraps it with complexity routing.

**2. Native path (if you ever add a Claude Code/Anthropic backend)**
The same roles exist as subagents in `.claude/agents/` and are driven by the
`/spec`, `/ship`, `/review` slash commands. The two paths share the same briefs and
rules, so behavior stays consistent.

## Backends

| Backend | Adapter | Notes |
|---|---|---|
| `ollama` | `bin/backends/ollama.sh` | Local, free, offline. Emits text; does **not** edit files. |
| `fable` | `bin/backends/fable.sh` | Claude (Fable-class) CLI. Agentic — can edit files. Strongest reasoning; drives the complex tier. Needs `ANTHROPIC_API_KEY`. |
| `codex` | `bin/backends/codex.sh` | OpenAI Codex CLI. Agentic — can edit files. Needs `OPENAI_API_KEY`. |
| `gemini` | `bin/backends/gemini.sh` | Google Gemini CLI. Agentic. Generous free tier. |
| `ours` | `bin/backends/ours.sh` | Your example-llm via an OpenAI-compatible endpoint (`OWN_LLM_URL`, `MODEL`). |

Each adapter has a `>>> adjust here <<<` line — CLI flags vary by version, so verify
the exact invocation against your installed tools.

## Which backend for which role (rationale)

- **File-editing work** (implementer, ml-trainer, inference-engineer) needs an
  *agentic* backend — `fable`, `codex`, or `gemini`. `ollama` and `ours` only emit
  text, so you'd apply their suggestions by hand.
- **Read/advisory work** (explorer, tester, data-engineer, redteam) runs fine on
  local `ollama` — cheap and offline, which is also the safer default for security.
- **The reviewer** should be your strongest available model — `fable`, the complex
  tier. It's the highest-ROI step in the loop; don't cheap out on the gate.

## Setup checklist

1. Install the CLIs you'll use (`ollama`, the `fable` CLI, `@openai/codex`,
   `@google/gemini-cli`).
2. Set keys: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY` (or `gemini`
   login); for `ours`, `OWN_LLM_URL` (+ `OWN_LLM_KEY` if needed).
3. Edit `team.conf`: set real model names under `BACKEND_MODEL` and reassign role
   backends to taste.
4. Fill the **Stack** section in `CLAUDE.md` (test command, lint, off-limits paths).
5. `bin/run-agent.sh explorer "smoke test: summarize this repo"` to confirm wiring.
