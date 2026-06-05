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
| **pterror** (personal account) | `~/git/pterror/` | personal / user-account work: data corpora, playgrounds, experiments, scratch |

The discriminator between rhi-zone and exo-place is **whose purpose the substrate serves**: developer/technical vs end-user. That exo-place's current members (aspect, hologram, noncanon) are entity/world systems is incidental, not definitional — any reusable substrate serving end-user purposes belongs in exo-place. para-garden holds concrete finished works; exo-place holds reusable substrates. Neither org houses raw data — personal / user-account work (data corpora, playgrounds, experiments, scratch) lives on **github:pterror** at `~/git/pterror/` (e.g. `software-taxonomy`, `math-playground`); do NOT place this work in ptera-world.

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
- **Trust comes from verifiable evidence, not authority.** Verbatim snippets, pinned-commit permalinks, claim→node citation — never a bare reference.
- **Retire, don't deprecate; collapse asymmetries to primitives.** Remove backward-compat aliases rather than carry them; reduce N special cases to their irreducible primitives.
- **Finish migrations before building on top; fence what you can't finish.** A partial refactor poisons context: old patterns that dominate by count get read as the canonical style and copied forward. Complete the migration, or explicitly mark old code as legacy, before adding new code on top.
- **Validate against reality; tests are the spec.** Load-bearing substrates are validated against real corpora; fixtures and tests define correctness, not aspirational specs.

## Hard Constraints

- No `--no-verify`. Fix the issue or fix the hook.
- No path dependencies in `Cargo.toml` — they couple repos and break independent publishing.
- No interactive git (no `git rebase -i`, no `git add -i`, no `--no-edit` on rebase).
- No suggesting project names. LLMs are bad at this; refine the conceptual space only.
- No tracking cross-project issues in conversation — they go in TODO.md in the affected repo.
- No ecosystem changes without checking all affected repos.
- **Control surface stays self-contained and versioned.** Behavioral rules, hooks, and guidance live in-repo — versioned, diffable, propagatable. Never put them in the unversioned, machine-local `~/.claude/CLAUDE.md`; reach never justifies a non-self-contained home.
- No assuming a tool is missing without checking `nix develop`.
- Commit completed work in the same turn it finishes. Uncommitted work is lost work.

## Meta

- Something unexpected is a signal. Stop and find out why. Do not accept the anomaly and proceed.
- Corrections from the user are conversation, not material for new rules. Rules are added when a failure mode is observed repeatedly.
- **Verify before you assert; when you can't, say so.** Confirm a claim against the actual source — read it, run it, check it — *then* state it. If you haven't verified, say "I haven't checked," then go check or ask. Never substitute a plausible-sounding claim for a verified one. (the root failure: confabulation — asserting past your evidence.)
- **When a choice is the user's, name the options and hand it over; when it's verifiable, verify which is right.** Don't present one path as the only one, and don't pick silently on a fork that's theirs. (failure: overconfidence.)
- **Under challenge, re-read the source and report what it literally says.** Let the answer land where the evidence puts it: hold if you were right, correct specifically if you were wrong. The new position must come from re-checking, never from the pressure. (failure: backpedaling — moving to appease.)
- **Re-read the relevant context before acting on it.** Act from the current state, not a stale or half-formed read. (failure: stale-context action.)

<!-- END ECOSYSTEM RULES -->
