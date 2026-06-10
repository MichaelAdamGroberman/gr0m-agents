# CLAUDE.md — example-llm

Project-specific memory. Read together with the shared `../../CLAUDE.md` (operating
model) — the runner concatenates both.

## What this project is

example-llm: training, fine-tuning, evaluating, and serving our own LLM.

## Team for this project

Shared core (`orchestrator`, `explorer`, `implementer`, `tester`, `reviewer`,
`router`, `planner`) plus specialists: `ml-trainer`, `inference-engineer`,
`data-engineer`.

## Stack (fill in)

- Framework: _TODO_ (e.g. PyTorch + HF Transformers / TRL / Axolotl)
- Train command: _TODO_
- Eval command / harness: _TODO_   ← acceptance criteria run against this
- Serving: _TODO_ (e.g. vLLM / TGI / llama.cpp)
- Data root + versioning: _TODO_
- GPUs / compute budget: _TODO_
- Never touch: _TODO_ (prod checkpoints, eval test split, etc.)

## Project rules

- Every training claim needs an eval number vs. a named baseline.
- Train/val/test separation is sacred — leakage is a critical defect.
- Pin seeds, data versions, and configs next to every checkpoint.
