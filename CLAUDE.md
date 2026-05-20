# Claude Code Instructions — Ollama-intelgpu

## What This Repo Is

Configuration scripts and optimization settings for running Ollama local language models on Intel GPU hardware (Arc, Iris Xe, integrated).

## AI-Rules

This repo follows the Crashcart AI-rules system.

- Rules source: `https://github.com/crashcart/ai-rules` (set in `.claude/settings.json` as `rulesRepo`)
- Governing files: `rules/claude.md` + `rules/universal.md`
- Current version in force: check `rulesVersion` in `.claude/settings.json`

The PreToolUse hook in `.claude/settings.json` calls `scripts/check-rules-updates.sh` on every
Bash tool call (rate-limited to once per hour). If it prints "Rules updated to vX.Y.Z", stop
and re-read your rules before continuing.

## Session Start Checklist

1. Check hook output — if it says "Rules updated", re-read `rules/` before anything else
2. Check for a `TODO.md` — if it exists, review open items from the last session
3. Confirm the active branch is `dev` (or a feature branch) — never `main`
4. Check for any resolved tickets that were opened by this repo's AI

## Branching Policy

- All work goes to `dev` or a feature branch off `dev`
- `dev` → `beta` → `main` via PR only — never push directly to `main`
- Branch naming: `type/short-description` (e.g., `feat/arc-a770-config`, `fix/vram-leak`)

[NON-NEGOTIABLE]

## Rule-Edit Suggestions

If you want to suggest a change to any rule in ai-rules, do not modify the file directly.
Open a ticket in the ai-rules repo using `tickets/template.md`:
- Set **Scope** to `rule-edit`
- Set **Requesting AI** to your ai-id
- Claude (CEO) will discuss the change with you before implementing anything

## Shell / Docker Standards

- `#!/usr/bin/env bash` shebang on every script
- `set -euo pipefail` at the top of every script
- Quote all variable expansions: `"${var}"` not `$var`
- No `ls | grep` — use `find` with predicates
- Dockerfile: pin base image versions (`image:1.2.3`, not `image:latest`)
- `.env.example` must exist and list every required env var with a comment explaining it
- Never commit real `.env` files — only `.env.example`

## Ollama / Intel GPU Conventions

- Always set `KEEP_ALIVE=-1` for persistent model loading
- Enable `FLASH_ATTENTION=1` when hardware supports it
- Use `KV_CACHE_TYPE=q8_0` for Intel GPU memory efficiency
- Document minimum VRAM requirements per model config
- Test configs on Arc A770, Arc A380, and integrated Xe before marking stable

## Repo Structure

```
Ollama-intelgpu/
├── configs/
│   ├── *.env           ← model-specific environment configs
│   └── Modelfile.*     ← Ollama Modelfile templates
├── scripts/
│   ├── check-rules-updates.sh
│   ├── install.sh      ← setup and driver install
│   └── benchmark.sh    ← performance testing
├── docker/
│   └── Dockerfile
├── .claude/            ← Claude Code settings
├── .github/            ← Copilot instructions
├── .env.example
└── CLAUDE.md           ← you are here
```

## How to Commit

Use Conventional Commits:
- `feat:` — new feature
- `fix:` — bug fix
- `docs:` — documentation only
- `refactor:` — code change that isn't a fix or feature
- `chore:` — tooling, deps, config

## Key Contacts / Context

Hardware-specific repo — always test on actual Intel GPU hardware or document that a config is untested. Driver versions matter: note the Intel GPU driver version any change was tested with. This is a Crashcart project governed by the AI-rules CEO (Claude in ai-rules repo).
