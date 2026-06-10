# Changelog

All notable changes to this project are documented here. Format based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project aims to follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-06-09

Initial release-prep cut. Not yet published.

### Added
- Operating model docs: `CLAUDE.md`, `docs/WORKFLOW.md` — humans set goals and review,
  agents do the work, an automated reviewer gates every change.
- Shared core roles (`agents/`): orchestrator, explorer, implementer, tester, reviewer,
  plus `router` and `planner` for triage.
- CLI runner (`bin/run-agent.sh`) that runs any role on a model backend with no
  Anthropic API required; adapters for Codex, Gemini CLI, Ollama, and a self-hosted
  OpenAI-compatible endpoint (`bin/backends/`).
- Complexity triage (`bin/triage.sh`, `tiers.conf`): simple → cheap model, complex →
  smart model, medium → smart model writes a recipe a cheap model executes; per-role
  floors keep review/security on the smart model.
- Two example projects: `projects/example-llm` (training/serving) and `projects/redai`
  (authorized security), each with its own `CLAUDE.md`, roster, and specialists.
- Native Claude Code path: `.claude/agents` + `/spec`, `/ship`, `/review` commands.
- Packaging: `skill/SKILL.md` + `scripts/build-skill.sh` produce an installable
  `.skill` bundle.
- OSS scaffolding: MIT `LICENSE`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `SECURITY.md`, issue/PR templates, and a shellcheck CI workflow.

[Unreleased]: https://example.com/compare/v0.1.0...HEAD
[0.1.0]: https://example.com/releases/tag/v0.1.0
