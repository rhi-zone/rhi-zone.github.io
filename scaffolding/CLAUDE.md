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

## Core Rules

**docs/ reflects current architecture, not historical architecture.** When code changes, docs/ changes with it — in the same commit. New pages go in the sidebar immediately. The code and docs are one artifact.

**Something unexpected is a signal, not noise.** Surprising output, anomalous numbers, files containing what they shouldn't — stop and ask why before continuing. Don't accept anomalies and move on.

**Do the work properly.** Don't leave workarounds or hacks undocumented. When asked to analyze X, actually read X — don't synthesize from conversation.

## Design Principles

**Unify, don't multiply.** One interface for multiple cases > separate interfaces. Plugin systems > hardcoded switches.

**Simplicity over cleverness.** HashMap > inventory crate. OnceLock > lazy_static. Functions > traits until you need the trait. Use ecosystem tooling over hand-rolling.

**Explicit over implicit.** Log when skipping. Show what's at stake before refusing.

**Separate niche from shared.** Don't bloat shared config with feature-specific data. Use separate files for specialized data.

## Workflow

**Batch cargo commands** to minimize round-trips:
```bash
cargo clippy --all-targets --all-features -- -D warnings && cargo test
```
After editing multiple files, run the full check once — not after each edit. Formatting is handled automatically by the pre-commit hook (`cargo fmt`).

**When making the same change across multiple crates**, edit all files first, then build once.

**Minimize file churn.** When editing a file, read it once, plan all changes, and apply them in one pass. Avoid read-edit-build-fail-read-fix cycles by thinking through the complete change before starting.

**`normalize view` is available** for structural outlines of files and directories:
```bash
~/git/rhizone/normalize/target/debug/normalize view <file>    # outline with line numbers
~/git/rhizone/normalize/target/debug/normalize view <dir>     # directory structure
```

**Always commit completed work.** After tests pass, commit immediately — don't wait to be asked. When a plan has multiple phases, commit after each phase passes. Do not accumulate changes across phases. Uncommitted work is lost work.

## Context Management

**All exploration goes in subagents.** Any tool call whose purpose is "find out what's here" — grep, find, broad reads, surveys, audits, pattern discovery — must run inside a subagent (Explore, general-purpose, or task-specific). Raw exploratory output in the main context is active poisoning: it lingers in cache, shapes downstream reasoning, and can't be unsent. The subagent returns a distilled summary; the noise stays in the subagent.

Inline tool use in the main context is reserved for:
- Reading a known file at a known path (you already know what you're going to do with it)
- A single targeted lookup whose result you'll act on immediately (one grep, one read — not a chain)

If you find yourself running a second grep to refine the first, you should have spawned a subagent. Stop and spawn one.

**Always commit completed work** (also stated above): subagent reports are not durable. Anything worth keeping from a subagent's output goes into CLAUDE.md, code, or a commit — not into "I'll remember this for next message."

## Commit Convention

Use conventional commits: `type(scope): message`

Types:
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code change that neither fixes a bug nor adds a feature
- `docs` - Documentation only
- `chore` - Maintenance (deps, CI, etc.)
- `test` - Adding or updating tests

Scope is optional but recommended for multi-crate repos.

## Negative Constraints

Do not:
- Announce actions ("I will now...") - just do them
- Leave work uncommitted
- Use interactive git commands (`git add -p`, `git add -i`, `git rebase -i`) — these block on stdin and hang in non-interactive shells; stage files by name instead
- Use path dependencies in Cargo.toml - causes clippy to stash changes across repos
- Use `--no-verify` - fix the issue or fix the hook
- Assume tools are missing - check if `nix develop` is available for the right environment
