---
description: Turn a goal into a spec under specs/
argument-hint: <goal in plain language>
---

Turn the following goal into a spec, using `specs/TEMPLATE.md` as the structure.

Goal: $ARGUMENTS

Steps:
1. Read `specs/TEMPLATE.md` and `CLAUDE.md`.
2. If the goal is ambiguous in a way that changes the work, ask me 1–3 sharp
   clarifying questions before writing. Otherwise proceed.
3. Draft the spec: goal, non-goals, context, concrete and verifiable acceptance
   criteria, risks/open questions, deferred follow-ups.
4. Save it to `specs/<slug>.md` (derive a short slug from the title).
5. Show me the spec and the path. Do not start implementing — that's `/ship`.

Remember: you're capturing *what* and *why*, not *how*. Keep the unit of work small
enough to review quickly; if it's too big, propose splitting it into multiple specs.
