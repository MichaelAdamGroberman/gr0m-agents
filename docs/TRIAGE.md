# Triage — routing tasks to the right model

The point: spend the expensive model only where it pays off. Three behaviors,
straight from the brief.

| Tier | Who does it | Used for |
|---|---|---|
| **simple** | cheapest efficient model, directly | mechanical, well-specified, low-risk work |
| **complex** | smartest reasoning model, directly | ambiguous, high-risk, design/judgment work |
| **medium** | **smart model writes the recipe → cheap model executes it** | knowable work a junior could do with exact instructions |

The "medium" path is the one you asked for: high intelligence tells a simpler model
*exactly* how to do it, so you get near-complex quality at near-simple cost.

## How a task flows

```
bin/triage.sh <role> --project P "task"
        │
        ▼
  router (cheap)  ──►  SIMPLE | MEDIUM | COMPLEX
        │
        ▼
  raise to the role's floor (ROLE_TIER)   ← reviewer/redteam never drop below COMPLEX
        │
   ┌────┴───────────────┬─────────────────────┐
   ▼                    ▼                     ▼
 SIMPLE              MEDIUM                COMPLEX
 run role on      planner(complex)        run role on
 simple tier      writes recipe ──►       complex tier
                  role(simple) executes
                  (planner can ESCALATE → falls back to complex)
```

## Two dials you control

1. **`tiers.conf`** — what `simple` and `complex` actually map to (backend + model).
   This is where you put your cheapest model and your smartest model.
   ```bash
   TIER_BACKEND=( [simple]=gemini  [complex]=fable )
   TIER_MODEL=(   [simple]=gemini-2.5-flash  [complex]=claude-fable-5 )   # or codex/ours/ollama/etc.
   ```
2. **`ROLE_TIER`** (in `team.conf` + project `team.conf`) — the **floor** per role.
   The router can bump a task *up*, never below the floor. So:
   - `reviewer`, `security-reviewer`, `redteam`, `orchestrator`, `planner` → `complex`
   - `implementer`, `inference-engineer` → `medium`
   - `explorer`, `tester`, `data-engineer`, `router` → `simple`

## Running it

```bash
# let triage decide the tier:
bin/triage.sh explorer    --project example-llm "where's the training loop?"     # → simple
bin/triage.sh implementer --project example-llm --file projects/example-llm/specs/add-eval-harness.md
bin/triage.sh redteam     --project redai    "threat-model the serving API"   # → complex (floor)

# force a tier (skip classification):
bin/triage.sh implementer --project example-llm --tier medium "add a --seed flag to train.py"

# direct run, no triage (uses the role's default backend from team.conf):
bin/run-agent.sh tester --project example-llm "write tests for tokenizer.py"
```

## Cost intuition

- Classification is one cheap call (`router` on the simple tier) — pennies/free.
- SIMPLE tasks never touch the expensive model.
- MEDIUM tasks pay for the expensive model **once** (the recipe), then run cheap.
- COMPLEX tasks (and the review/security gates) get full reasoning, by design.
