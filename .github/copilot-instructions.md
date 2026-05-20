# GitHub Copilot Instructions

This repo follows the Crashcart AI-rules system.

Full Copilot rules: https://github.com/crashcart/ai-rules/blob/main/rules/copilot.md

Read that file before working in this repo. The summary below is a quick reference only.

---

## Branching

- Never push directly to `main`
- All work goes to `dev` or a feature branch
- Branch naming: `type/short-description`

---

## Model Selection

| Task | Model |
|------|-------|
| Single-file fix, boilerplate, docs | Haiku |
| Multi-file feature, cross-cutting refactor | Sonnet |
| Architecture decision, security change | Opus |

---

## Non-Negotiables

- Every output must be correct and production-ready — no placeholders, no unverified logic
- Flag real bugs and risks even when the user seems committed to their approach
- No `TODO` comments in committed code — open an issue instead
- Use Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`

---

## Escalate to Human For

- Architectural decisions affecting multiple systems
- Security or authentication changes
- Anything where the requirement is genuinely ambiguous
