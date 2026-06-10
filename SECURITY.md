# Security Policy

## Reporting a vulnerability

If you find a security issue in this project, please report it privately rather than
opening a public issue. Email the maintainer (see the repository owner's profile) or
use GitHub's **private vulnerability reporting** (Security → Report a vulnerability).
We aim to acknowledge reports within a few days.

Please include: what you found, how to reproduce it, and the potential impact.

## Scope and responsible-use note for `projects/redai`

This repository includes an **example** security/red-team project (`projects/redai`).
It exists to show how to structure an authorized, defensive security workflow — not
to enable misuse.

The `redteam` role's brief is explicit and binding:

- Test **only** systems you are **explicitly authorized** to test, in writing.
- Stay within the agreed scope; if a path leads out of scope, stop and report.
- Practice **responsible disclosure**: document findings, don't weaponize. Prove
  access with a benign marker; never exfiltrate real sensitive data.
- Every finding ships with a severity rating and a remediation.

Using these templates to attack systems without authorization is misuse and is not
supported by this project.

## Secrets

This project never stores credentials. Backends read keys from your environment
(`OPENAI_API_KEY`, `GEMINI_API_KEY`, `OWN_LLM_URL`/`OWN_LLM_KEY`, etc.). The
`.gitignore` excludes `.env*`, `*.key`, `*.pem`, and `secrets/`. Do not commit keys.
