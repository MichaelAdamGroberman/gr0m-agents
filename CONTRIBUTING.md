# Contributing

Thanks for your interest. This project scaffolds a multi-agent coding team that runs
on whatever model backends you have, with complexity-based task triage.

## Ground rules (we dogfood our own model)

This repo follows the operating model it ships — see `CLAUDE.md` and `docs/WORKFLOW.md`:

- **Spec before non-trivial code.** Open an issue or a spec under `specs/` first.
- **Small, reviewable changes.** One logical change per PR.
- **The reviewer gates everything.** New behavior ships with a way to verify it.
- **Surface judgment calls** rather than guessing on ambiguous direction.

## Dev setup

No build step. The runtime is bash + whatever CLIs you point the backends at.

```bash
git clone <your-fork>
cd agent-team-builder
chmod +x bin/*.sh bin/backends/*.sh
# optional: install shellcheck to match CI
shellcheck bin/*.sh bin/backends/*.sh
```

## What to check before opening a PR

```bash
bash -n bin/*.sh bin/backends/*.sh        # syntax
shellcheck bin/*.sh bin/backends/*.sh     # lint (CI runs this)
# configs source cleanly:
bash -c 'source team.conf; source tiers.conf'
```

These are the same checks CI runs (`.github/workflows/ci.yml`).

## Adding things

- **A role**: add a brief in `agents/<role>.md` (or `projects/<p>/agents/`), then set
  `ROLE_BACKEND[<role>]` and `ROLE_TIER[<role>]` in the relevant `team.conf`.
- **A backend**: add `bin/backends/<name>.sh` (takes a prompt file as `$1`, uses
  `$MODEL`); reference it in `team.conf` / `tiers.conf`.
- **A project**: `projects/<name>/` with its own `CLAUDE.md`, `team.conf`, `specs/`.

## Commit style

Conventional-ish, present tense: `feat: add gemini backend`, `fix: quote MODEL in
codex adapter`, `docs: clarify triage floors`.

## Reporting security issues

Please do **not** open a public issue for vulnerabilities. See `SECURITY.md`.
