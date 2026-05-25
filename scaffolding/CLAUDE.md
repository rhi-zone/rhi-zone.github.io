# CLAUDE.md

Behavioral rules for Claude Code in the PROJECT_NAME repository.

## Project Overview

PROJECT_DESCRIPTION

Part of the [rhi ecosystem](https://rhi.zone).

## Origin

<!-- Why does this project exist? What problem does it solve?
     What key decisions were made when it was created?
     What should a new agent know to not be lost on first session?
     Naming rationale, design philosophy, relationship to other projects.
     Also consider a TODO.md with initial directions (can be high-level). -->

## Architecture

<!-- Project-specific architecture notes -->

## Development

```bash
nix develop        # Enter dev shell
cargo test         # Run tests
cargo clippy       # Lint
cd docs && bun dev # Local docs
```


## Commit Convention

Conventional commits: `type(scope): message`

Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`. Scope is optional but recommended for multi-crate repos.
