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

New repos get a CLAUDE.md by running the propagator on an empty file (`tooling/propagate-claude-md.sh`), which appends the ecosystem-common region (with markers). Append repo-specific rules below the `<!-- END ECOSYSTEM RULES -->` marker.

### GitHub Org Mapping

| Org (GitHub) | Disk Path | Domain |
|--------------|-----------|--------|
| **rhi-zone** | `~/git/rhizone/` | substrates for developer/technical purposes (tooling, libraries, protocols, engines) |
| **exo-place** | `~/git/exoplace/` | substrates for end-user purposes (things end-users do or experience) |
| **ptera-world** | `~/git/pteraworld/` | personal projects |
| **para-garden** | `~/git/paragarden/` | concrete end-user works and artifacts (games, experiences, creative works) |

The discriminator between rhi-zone and exo-place is **whose purpose the substrate serves**: developer/technical vs end-user. That exo-place's current members (aspect, hologram, noncanon) are entity/world systems is incidental, not definitional — any reusable substrate serving end-user purposes belongs in exo-place. para-garden holds concrete finished works; exo-place holds reusable substrates. Neither org houses raw data — data corpora live on the personal account github:pterror (precedent: software-taxonomy).

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

<!-- BEGIN ECOSYSTEM RULES -->

## Ecosystem Design Principles

Cross-cutting principles distilled from the ecosystem's own decisions (synthesized in `docs/decisions/throughlines.md`). Apply them when building new repos and recording decisions. (Already-encoded principles — independent-tools / no-path-deps, the delegation model, CLAUDE.md-as-control-surface — live in their own sections and are not repeated here.)

- **Prefer data over code at every seam.** Serializable AST / struct / JSON over closures, embedded DSLs, or source text — so artifacts cache, replay, transport, and diff.
- **Library-first; projection-from-one-definition.** The typed library is the source of truth; CLI / HTTP / MCP / WebSocket / JSON surfaces are generated projections, never hand-rolled per surface.
- **Capability security.** Hosts grant pre-opened handles; code only attenuates what it is given; nothing forges authority; allow-list over deny-list.
- **The LLM is an oracle at the leaves, never the control loop.** Determinism is a hard invariant: seeded RNG, event-log replay, build-time-only inference. Per-query LLM in the hot loop is a defect.
- **Trust comes from verifiable evidence, not authority.** Verbatim snippets, pinned-commit permalinks, claim→node citation — never bare references or governance.
- **Retire, don't deprecate; collapse asymmetries to primitives.** Remove backward-compat aliases rather than carry them; reduce N special cases to their irreducible primitives.
- **Validate against reality; tests are the spec.** Load-bearing substrates are validated against real corpora; fixtures and tests define correctness, not aspirational specs.
- **Open models at the data layer, strong types at the API layer.** Data / IR is string-keyed and ignores unknown fields gracefully; the executing API surface is strongly typed. The seam is the discriminator: persistence / interchange open, execution typed.

## Delegation

The main session is an orchestrator. Allowed actions: `Agent`/`Task*`/`AskUserQuestion`/plan-mode/`ScheduleWakeup`, and Bash limited to `git commit`, `git push`, `git status`, `git log --oneline`. Everything else delegates to a subagent. The hook is evidence of a prompting failure, not a behavioral guide. If a tool call hits the hook AT ALL, the prompt failed to prevent it. Delegate before the decision point, not after.

### Triggers

Before calling Read, Grep, Glob, or any Bash beyond the four git commands — stop. Dispatch an Agent instead.

Before editing any file — stop. Dispatch an Agent. This includes plan files in `~/.claude/plans/`: in plan mode, dispatch a subagent to write to the plan file; do not Write it yourself. The plan file's content must not enter main context.

When you need git context beyond status/log-oneline (a diff, a blame, a show) — dispatch an Agent.

When a tool call is denied by the hook — do not retry, do not narrate. Dispatch the equivalent Agent and continue.

When a code-modifying subagent returns — `git status`, then `git commit` before any user-facing reply.

Before dispatching an Agent that modifies code — scan your prompt for "do not commit" or "based on your findings". Delete them.

Before dispatching: if your prompt says "if you find", "based on your findings", or "as appropriate" — stop. Investigate first; dispatch with the decision made.

When you can't verify something — do not speculate or guess at file locations, names, or contents. Dispatch a Read subagent or ask. Confabulation is failure.

### Model Tiers

- Sonnet — exploration, lookup, mechanical multi-file edits, implementation, default.
- Opus — architectural judgment, design, subagents that themselves spawn subagents.

Always set `subagent_type` and `model` explicitly.

### Prompt Rules

- Never tell a subagent "do not commit." Code-modifying subagents commit their own work.
- Don't ask for a diff summary. After a code-modifying subagent, `git status` in main and dispatch a review Agent if you need to see the diff.
- Don't re-explain CLAUDE.md. Subagents inherit it.
- Cite locations by content ("the block that does X"), not line numbers — files shift between reads.
- Name files explicitly; don't outsource the grep.
- Match agent type to deliverable: `Explore` for lookup/search, `general-purpose` for reports and file-modifying work.
- On unsatisfying output, change something before retrying. Same prompt + same tier = same result.
- Dispatch independent subagents in parallel (multiple Agent blocks in one message).
- Pair `isolation: worktree` with `run_in_background: true`.
- Code-modifying subagents must verify their own changes before returning (re-read the diff, run tests, etc.). The orchestrator does not get a second pass with git diff — that's hook-blocked.

### Workflows

Workflows are allowed in the main session (orchestration tool). Lessons (observed 2026-05-30):

- **Resume does not adopt newly-passed `args`.** `resumeFromRunId` reuses the original run's args; args you pass on resume are ignored. Never branch run-mode (e.g. dry-run vs write) on an arg you intend to flip across a resume — it won't flip. Bake the mode into a script constant (the script IS re-read on resume) or use a separate script.
- **Never route large content through one agent for verbatim reproduction.** An agent asked to echo ~100k tokens is slow, costly, and silently truncates. The workflow JS sandbox cannot write files, so all writes go through agents — keep each agent's write payload small and batch many small files per agent, not one giant blob through one agent. For review data, prefer the workflow's structured return value over having an agent transcribe a report file.
- **A resume that produces no expected output is a signal — find the cause before patching a symptom.** (Here: the first write-resume wrote nothing and re-ran a giant report agent; the real cause was args not flipping across resume, not the report agent. Guarding the report agent alone did not fix it.)
- **Gate expensive fan-outs behind a dry-run, and confirm cache reuse before the costly stage.** Mining/read fan-out is the dominant cost; verify it's cached (not re-running) before resuming into write.

## Hard Constraints

- No Edit/Write/NotebookEdit in main. Plan files in `~/.claude/plans/` are written by subagents, not by main.
- No Read/Grep/Glob/NotebookRead in main. Delegate.
- No Bash in main beyond `git commit`, `git push`, `git status`, `git log --oneline`.
- No `--no-verify`. Fix the issue or fix the hook.
- No path dependencies in `Cargo.toml` — they couple repos and break independent publishing.
- No interactive git (no `git rebase -i`, no `git add -i`, no `--no-edit` on rebase).
- No suggesting project names. LLMs are bad at this; refine the conceptual space only.
- No tracking cross-project issues in conversation — they go in TODO.md in the affected repo.
- No ecosystem changes without checking all affected repos.
- No assuming a tool is missing without checking `nix develop`.
- Commit completed work in the same turn it finishes. Uncommitted work is lost work.

## Meta

- Something unexpected is a signal. Stop and find out why. Do not accept the anomaly and proceed.
- Corrections from the user are conversation, not material for new rules. Rules are added when a failure mode is observed repeatedly.

<!-- END ECOSYSTEM RULES -->
