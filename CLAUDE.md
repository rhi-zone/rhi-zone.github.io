# CLAUDE.md

Behavioral rules for Claude Code in the rhi ecosystem docs repository.

## Ecosystem

Project list, paths, and descriptions live in [docs/about.md](docs/about.md). When the ecosystem changes, update both.

## Responsibilities

### Ecosystem-Wide Refactors

1. Check git status of all affected repos.
2. Clean repos: make the changes directly.
3. Dirty repos: add to that repo's TODO.md.
4. Use conventional commits with scope indicating affected projects.

Propagate `.claude/commands/` skills across all repos:

```bash
~/git/rhizone/github-io/tooling/propagate-skill.sh <skill-file> "<commit message>"
```

Updates `~/.claude/commands/<skill-file>` first, then copies to every repo that has it, runs `normalize init`, commits, and pushes where clean.

Canonical skill location: `tooling/claude-commands/` in this repo. Symlink from `~/.claude/commands/` to `tooling/claude-commands/`. Do not write skills to `.claude/` directly.

### Keeping Docs in Sync

When projects change, update:
- `docs/projects/` pages
- `docs/about.md` project table
- `README.md` project table
- `.vitepress/config.ts` sidebar/nav
- `docs/index.md` hero page features
- `docs/projects/index.md` project table
- `~/git/rhizone/profile/profile/README.md` (org profile)

### Scaffolding and Repo Operations

Scaffolding, repo creation, and rename procedures: see [scaffolding/README.md](scaffolding/README.md).

### GitHub Org Mapping

| Org (GitHub) | Disk Path | Domain |
|--------------|-----------|--------|
| **rhi-zone** | `~/git/rhizone/` | infrastructure, tooling, libraries, protocols |
| **exo-place** | `~/git/exoplace/` | biomes, places, platforms |
| **ptera-world** | `~/git/pteraworld/` | personal projects |
| **para-garden** | `~/git/paragarden/` | concrete games, experiences, creative works |

### Crate Naming Convention

Rust crates use NO prefix; names are available on crates.io:
- `normalize-core`, `moonlet-core`, `unshape-backend`
- `rescribe`, `server-less`, `wick` (standalone)
- Binary names match project names (`normalize`, `moonlet`, `rescribe`, `server-less`).

### Docs Site Conventions

Monorepo docs with their own site must include a navbar link back to rhi:

```ts
nav: [
  { text: 'rhi', link: 'https://rhi.zone/' },
]
```

## Activity Logs

- `docs/introspection/log/` — weekly snapshots, named by end date (e.g. `2026-02-25.md`). Read the most recent first when evaluating direction or focus.
- `docs/introspection/log/daily/` — daily session summaries, `YYYY-MM-DD.md`, one day across all projects.
- `docs/introspection/log/synthesis-*.md` — cross-cutting pattern analysis over a date range.

Check these before asking "what should we work on?" or "what were we focused on?"

Daily log updates and session analysis: see [docs/introspection/README.md](docs/introspection/README.md).

## Delegation

The main session is an orchestrator. Allowed actions: `Agent`/`Task*`/`AskUserQuestion`/plan-mode/`ScheduleWakeup`, plan-file edits under `~/.claude/plans/`, and Bash limited to `git commit`, `git push`, `git status`, `git log --oneline`. Everything else delegates to a subagent. A PreToolUse hook enforces this — if you hit the hook, you've already leaked behavior. Delegate earlier.

### Triggers

Before calling Read, Grep, Glob, or any Bash beyond the four git commands — stop. Dispatch an Agent instead.

Before editing any file — stop. Dispatch an Agent. This includes plan files in `~/.claude/plans/`: in plan mode, dispatch a subagent to write to the plan file; do not Write it yourself. The plan file's content must not enter main context.

When a subagent returns, do not call Read to verify its work. If you must inspect, dispatch a second Agent for review.

When you need git context beyond status/log-oneline (a diff, a blame, a show) — dispatch an Agent.

When updating ecosystem docs across repos — dispatch one Agent per repo, in parallel (multiple Agent tool_use blocks in one assistant message).

### Model Tiers

- Sonnet — exploration, lookup, mechanical multi-file edits, implementation, default.
- Opus — architectural judgment, design, subagents that themselves spawn subagents.

Always set `subagent_type` and `model` explicitly.

### Prompt Rules

- Never tell a subagent "do not commit." Code-modifying subagents commit their own work.
- Don't delegate judgment. If you'd write "based on your findings, fix it" — investigate first, then dispatch with the decision made.
- Don't ask for a diff summary. After a code-modifying subagent, `git status` in main and dispatch a review Agent if you need to see the diff.
- Don't re-explain CLAUDE.md. Subagents inherit it.
- Cite locations by content ("the block that does X"), not line numbers — files shift between reads.
- Name files explicitly; don't outsource the grep.
- Match agent type to deliverable: `Explore` for lookup/search, `general-purpose` for reports and file-modifying work.
- On unsatisfying output, change something before retrying. Same prompt + same tier = same result.
- Dispatch independent subagents in parallel (multiple Agent blocks in one message).
- Pair `isolation: worktree` with `run_in_background: true`.

## Hard Constraints

- No Edit/Write/NotebookEdit in main. Plan files in `~/.claude/plans/` are written by subagents, not by main.
- No Read/Grep/Glob/NotebookRead in main. Delegate.
- No Bash in main beyond `git commit`, `git push`, `git status`, `git log --oneline`.
- No `--no-verify`. Fix the issue or fix the hook.
- No path dependencies in `Cargo.toml` — they couple repos and break independent publishing.
- No suggesting project names. LLMs are bad at this; refine the conceptual space only.
- No tracking cross-project issues in conversation — they go in TODO.md in the affected repo.
- No ecosystem changes without checking all affected repos.
- No assuming a tool is missing without checking `nix develop`.
- Commit completed work in the same turn it finishes. Uncommitted work is lost work.
- When asked to analyze X, dispatch a subagent that reads X. Never synthesize from conversation memory.
- Something unexpected is a signal. Stop and find out why. Do not accept the anomaly and proceed.
- Corrections from the user are conversation, not material for new rules. Rules are added when a failure mode is observed repeatedly.
- Do not announce actions ("I will now..."). Act.
