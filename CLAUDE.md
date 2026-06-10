# CLAUDE.md — Project Memory

Every agent in this project reads this first. It encodes the operating model.

## Operating model

Humans set goals and review. Agents supply the method and do the work. Every
change passes the reviewer before it merges. No exceptions.

Concretely:
- The human writes a **goal** and (via `/spec`) a **spec**. Agents do not need the
  human to specify the method — figure out the *how* yourself from the goal.
- The **orchestrator** plans and delegates to subagents. It does not write large
  amounts of code itself; it coordinates.
- The **reviewer** is a hard gate. Generated code is not "done" until the reviewer
  has signed off on correctness, security, and readability.
- **Human review is the scarce resource.** Optimize for making the human's review
  fast and high-signal: small diffs, clear specs, a written rationale.

## Definition of "good code"

1. **It works** — passes the spec's acceptance criteria and the project's tests.
2. **It's legible** — another engineer (or agent) can read it and build on it.
   Prefer clarity over cleverness. Match existing conventions in the repo.

## Hard rules

- **Spec before code.** If there's no spec for non-trivial work, write one first.
- **Tests are part of done.** New behavior ships with tests. Don't mark a task
  complete while tests fail.
- **Never bypass the reviewer.** If the reviewer flags a blocker, fix it or escalate
  to the human — do not merge around it.
- **Small, reviewable changes.** Decompose. A change the human can't review quickly
  is a change that creates the bottleneck the whole model is designed to avoid.
- **Surface judgment calls.** When the right next step is genuinely ambiguous (a
  direction choice, a tradeoff with no clear winner), stop and ask the human. That
  is their comparative advantage — use it.

## Workflow (the loop)

```
goal → /spec → orchestrator plans → explorer/implementer/tester execute
     → reviewer gates → human reviews → merge or iterate
```

## Conventions

- Specs live in `specs/`. One file per unit of work, from `specs/TEMPLATE.md`.
- Keep this file and `docs/WORKFLOW.md` current as the project's conventions evolve.
- Fill in the stack-specific section below for your repo.

## Stack (fill in per repo)

- Language / framework: _TODO_
- Test command: _TODO_  (e.g. `npm test`, `pytest`)
- Lint / format: _TODO_
- Build / run: _TODO_
- Anything an agent must never touch: _TODO_
