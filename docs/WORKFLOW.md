# The Workflow

This is the operating model from *When AI builds itself*, turned into a concrete
way of working. Read it once; the rest is muscle memory.

## Principle

The human role narrows to the two things humans are still best at: **choosing what
to work on** and **judging whether the result is good**. Everything between those
two points — writing code, running it, testing it, fixing it — is delegated to
agents and gated by automated review.

| Stage | Owner | What happens |
|---|---|---|
| 1. Direction | **Human** | Decide what's worth building. This is the highest-leverage human act. |
| 2. Spec | Human + orchestrator | Turn the goal into a spec: goal, non-goals, acceptance criteria. `/spec`. |
| 3. Plan | Orchestrator | Break the spec into tasks; decide which subagents handle what. |
| 4. Explore | Explorer | Map the relevant code before changing it. Read-only. |
| 5. Implement | Implementer | Write the change to satisfy the spec. Small, legible diffs. |
| 6. Test | Tester | Write/run tests against the acceptance criteria. |
| 7. Review gate | **Reviewer** | Automated check for bugs, security, readability. Hard gate. |
| 8. Human review | **Human** | Read diff + reviewer report. Merge or send back. |

## Why a reviewer gate, specifically

Anthropic ran a retrospective: an automated Claude review of every change to their
codebase would have caught **roughly a third of the bugs behind past production
incidents** before they shipped — bugs written by some of the best engineers in the
world. The gate isn't bureaucracy. It's the single highest-ROI step in the loop.

The reviewer checks:
- **Correctness** — does it actually do what the spec says? Edge cases, error paths.
- **Security** — injection, authz, secrets, unsafe deserialization, SSRF, etc.
- **Legibility** — can a human build on this? Naming, structure, dead code.

It returns **BLOCKER / WARNING / NIT** findings. Blockers must be resolved before
human review.

## Protect the bottleneck (Amdahl's law)

Speeding up one stage just moves the jam to the slowest remaining stage. Once agents
generate faster than you can review, **your review becomes the cap on the whole
system.** So:

- Keep diffs small and self-contained.
- Make every change come with a one-paragraph rationale and a pointer to its spec.
- Let the reviewer absorb the mechanical checks so your attention goes to judgment:
  *is this the right thing, built the right way?*

## When agents should stop and ask

Agents are good at execution and increasingly good at next-step choices. They are
**not** your replacement for taste. Stop and ask the human when:

- The direction is ambiguous and the choices diverge materially.
- A tradeoff has no clear winner (perf vs. simplicity, scope cut vs. delay).
- The spec turns out to be wrong or incomplete.
- A change would touch something flagged as off-limits in `CLAUDE.md`.

## Anti-patterns

- ❌ Coding without a spec for non-trivial work.
- ❌ One monolithic agent doing everything in a single context.
- ❌ Merging past a reviewer blocker because "it probably works."
- ❌ Giant diffs that are technically correct but un-reviewable.
- ❌ Asking the human to supply the method instead of the goal.
