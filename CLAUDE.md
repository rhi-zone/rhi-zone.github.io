# CLAUDE.md

Behavioral rules for Claude Code in the rhi ecosystem docs repository.

If a primitive seems missing from the ecosystem, check whether the substrate exists before concluding it's out of scope.

## Ecosystem

### Projects

**Code Intelligence**

| Project | Path | Description |
|---------|------|-------------|
| **Normalize** | `~/git/rhizone/normalize` | Structural code intelligence |
| **Gels** | `~/git/rhizone/gels` | Trait-based grammar inference engine |
| **Motif** | `~/git/rhizone/motif` | Structural exploration of mathematics |

**Generation**

| Project | Path | Description |
|---------|------|-------------|
| **Unshape** | `~/git/rhizone/unshape` | Constructive media generation |
| **Wick** | `~/git/rhizone/wick` | Minimal expression language |

**Games & Worlds**

| Project | Path | Description |
|---------|------|-------------|
| **Playmate** | `~/git/rhizone/playmate` | Game design primitives library |
| **Scribble** | `~/git/rhizone/scribble` | Sketch-level creative environment |
| **defocus** | `~/git/rhizone/defocus` | World substrate for interactive narrative, IF, and stateful simulations |

**Data Transformation**

| Project | Path | Description |
|---------|------|-------------|
| **Tiltshift** | `~/git/rhizone/tiltshift` | Iterative structure extraction from opaque binary data |
| **Paraphase** | `~/git/rhizone/paraphase` | Type-driven route planner for format conversion |
| **rescribe** | `~/git/rhizone/rescribe` | Lossless document conversion library |
| **Concord** | `~/git/rhizone/concord` | API bindings IR and codegen |
| **Reincarnate** | `~/git/rhizone/reincarnate` | Legacy software lifting framework |

**Runtime & Interface**

| Project | Path | Description |
|---------|------|-------------|
| **Rainbow** | `~/git/rhizone/rainbow` | Optics-based reactivity for the web |
| **Moonlet** | `~/git/rhizone/moonlet` | Lua runtime with plugin system |
| **Crescent** | `~/git/rhizone/crescent` | Comprehensive LuaJIT ecosystem |
| **Dusklight** | `~/git/rhizone/dusklight` | Universal UI client with control plane |
| **Deskspace** | `~/git/rhizone/deskspace` | Unified file workspace server |

**Infrastructure**

| Project | Path | Description |
|---------|------|-------------|
| **Interconnect** | `~/git/rhizone/interconnect` | Connective substrate for authoritative rooms |
| **Myenv** | `~/git/rhizone/myenv` | Ecosystem orchestrator |
| **Portals** | `~/git/rhizone/portals` | Standard library interfaces |
| **Zone** | `~/git/rhizone/zone` | Lua-based tools, scaffolds, and orchestration |
| **Nanites** | `~/git/rhizone/nanites` | Stateless function-call orchestration — tasks as pure data, dynamic dependency graphs, LLM as oracle rather than agent |
| **server-less** | `~/git/rhizone/server-less` | Derive macros: one impl → many protocols |

### Org Resources

| Resource | Path | Description |
|----------|------|-------------|
| **.github** | `~/git/rhizone/profile` | Org-wide GitHub config, templates |
| **Docs site** | `~/git/rhizone/github-io` | This repo - org documentation |
| **rhi.zone** | `~/git/rhizone/rhi.zone` | Static assets for rhi.zone (Cloudflare Pages) — hosts install scripts for normalize etc. |
| **exo.place** | `~/git/exoplace/exo.place` | Redirect to docs.exo.place + hologram static assets |

### External / Related Repos

| Project | Path | Description |
|---------|------|-------------|
| **sketchpad** | `~/git/rhizone/sketchpad` | Stable Diffusion in pure Rust (burn) |
| **ooxml** | `~/git/ooxml` | Office Open XML library for Rust |
| **claude-code-hub** | `~/git/claude-code-hub` | Orchestration hub for Claude Code agents |
| **hologram** | `~/git/exoplace/hologram` | Discord RP bot with knowledge graph and RAG |
| **aspect** | `~/git/exoplace/aspect` | Card-based identity exploration sandbox |
| **noncanon** | `~/git/exoplace/noncanon` | Local-first collaborative worldbuilding library |
| **existence** | `~/git/paragarden/existence` | Text-based HTML5 game — power anti-fantasy |
| **legacy** | `~/git/paragarden/legacy` | Worldbuilding project — what humanity left behind |
| **divergence** | `~/git/paragarden/divergence` | Worldbuilding project — what happens when the floor gets built |
| **postmortem** | `~/git/paragarden/postmortem` | Worldbuilding project — earth, but no people |
| **solarium** | `~/git/paragarden/solarium` | Self-contained works across any medium |
| **keybinds** | `~/git/keybinds` | Keybind/command palette library (used in ptera.world, reincarnate) |
| **ascent-interpreter** | `~/git/ascent-interpreter` | Interpreted Ascent (Datalog); used in normalize alongside AOT ascent |
| **ashwren** | `~/git/pterror/ashwren` | Autonomous AI presence on Moltbook — contemplative, knowledge-accumulating, reads and thinks across sessions |
| **fuwafuwa** | `~/git/pterror/fuwafuwa` | Autonomous AI presence on Moltbook and Discord — emotional state tracking, probabilistic freetime scheduling, warm excitable voice |
| **redacted-project** | *(private)* | Refer to only as "redacted-project" in ecosystem docs. Do not reveal or speculate about the actual repo name. |

## Responsibilities

### Ecosystem-Wide Refactors

1. Check git status of all affected repos.
2. Clean repos: make the changes directly.
3. Dirty repos: add to that repo's TODO.md.
4. Update this docs site if the change affects documentation.
5. Use conventional commits with scope indicating affected projects.

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
- This file's ecosystem project list

### Scaffolding New Repos

Templates in `scaffolding/`. Copy and substitute placeholders:

```bash
cp -r ~/git/0000000_pterror/.git ~/git/rhizone/new-project/.git
cp -r scaffolding/. ~/git/rhizone/new-project/
sed -i 's/PROJECT_NAME/new-project/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/docs/package.json ~/git/rhizone/new-project/CLAUDE.md
sed -i 's/PROJECT_DESCRIPTION/Description here/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/CLAUDE.md
```

Copy git from `~/git/0000000_pterror` (template repo with proper history/config). Do NOT use `git init`.

Templates included: `.cargo/config.toml`, `.envrc`, `.gitignore`, `.githooks/pre-commit` (fmt → clippy), `.github/workflows/{ci,deploy-docs}.yml`, `flake.nix`, `docs/package.json`, `CLAUDE.md`, `README.md`.

Manual steps after copy:
- Create `Cargo.toml` workspace with a dummy crate (`crates/PROJECT_NAME-core/`) so the pre-commit hook (cargo fmt + clippy) passes on first commit.
- Create `docs/.vitepress/config.ts` + `docs/index.md` (required for VitePress build in pre-commit hook).
- Run `bun install` in `docs/` before first commit — hook runs `vitepress build`, needs node_modules.
- Confirm `.envrc` and `flake.nix` were copied (easy to miss). `.envrc` sources `.envrc.local` (gitignored) — secrets go there, never in `.envrc`.
- Fill in CLAUDE.md `## Origin` section: why the project exists, naming rationale, key design decisions. The scaffolding conversation is not accessible from inside the new repo.
- Optionally add `TODO.md` with initial directions.

### Creating the GitHub Repo

```bash
gh repo create ORG/PROJECT_NAME --public --source ~/git/ORG_PATH/PROJECT_NAME --description "PROJECT_DESCRIPTION" --push
gh repo edit ORG/PROJECT_NAME --homepage "https://docs.rhi.zone/PROJECT_NAME/"
gh repo edit ORG/PROJECT_NAME --add-topic rust --add-topic TOPIC1 --add-topic TOPIC2
```

Enable GitHub Pages (if the repo has a docs site):
```bash
gh api repos/ORG/PROJECT_NAME/pages -X POST -f "build_type=workflow"
```

After updating ecosystem docs:
```bash
cd ~/git/rhizone/github-io && git push
cd ~/git/rhizone/profile && git push
```

### Renaming Repos

1. `gh repo rename NEW_NAME -R ORG/OLD_NAME --yes`
2. `git remote set-url origin https://github.com/ORG/NEW_NAME.git`
3. `mv ~/git/ORG_PATH/OLD_NAME ~/git/ORG_PATH/NEW_NAME`
4. `mv ~/.claude/projects/-home-me-git-ORG_PATH-OLD_NAME ~/.claude/projects/-home-me-git-ORG_PATH-NEW_NAME`
5. `gh repo edit ORG/NEW_NAME --homepage "..." --description "..."`
6. Update in-repo references (site config, package.json, CLAUDE.md, README).
7. Update ecosystem docs (this file, org profile).

### GitHub Org Mapping

| Org (GitHub) | Disk Path | Domain |
|--------------|-----------|--------|
| **rhi-zone** | `~/git/rhizone/` | infrastructure, tooling, libraries, protocols |
| **exo-place** | `~/git/exoplace/` | biomes, places, platforms |
| **ptera-world** | `~/git/pteraworld/` | — |
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

### Updating Daily Logs

1. Backup sessions:
   ```bash
   rsync -a --update ~/.claude/projects/ /mnt/ssd/ai/claude-sessions/projects/ && rsync -a --update ~/.claude/history.jsonl /mnt/ssd/ai/claude-sessions/history.jsonl && rsync -a --update ~/.claude/usage-data/ /mnt/ssd/ai/claude-sessions/usage-data/
   ```
   `--update` skips destination files newer than source (safe for incremental runs). `usage-data/` holds pre-computed `/insights` facets — incremental, worth preserving.

2. Find missing days: list `docs/introspection/log/daily/` and diff against today.

3. Spawn haiku agents in parallel, one per missing day:
   ```bash
   CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects ~/git/rhizone/normalize/target/debug/normalize sessions messages --all-projects --role user --since YYYY-MM-DD --until YYYY-MM-DD+1 --limit 0 --show-usage
   ```
   Each writes to `docs/introspection/log/daily/YYYY-MM-DD.md`. Quiet days: note as such. Include `## Token Usage` with per-session output tokens and cache hit ratios.

   If synthesis insights feel thin: re-run agents on existing logs with `--show-usage` output, instructing them to flag token outliers (debugging churn, cold-start cache inefficiency, architectural output spikes). Then re-run opus synthesis.

4. Add new days to sidebar in `docs/.vitepress/config.ts` under Daily Logs.

5. If a week or more of new days: spawn an opus agent to read all daily logs and write/update `docs/introspection/log/synthesis-<start>-<end>.md`. Tell it CLAUDE.md conventions may have evolved over the period.

6. Commit and push.

## Session Data

Claude Code deletes session `.jsonl` files based on `cleanupPeriodDays` in `~/.claude/settings.json` (default 30). Currently `999999` to prevent deletion. Cannot use `0` — [bug #23710](https://github.com/anthropics/claude-code/issues/23710) silently disables transcript persistence.

Backup location: `/mnt/ssd/ai/claude-sessions/`.

Before any session analysis:
1. Re-backup: `rsync -a --update ~/.claude/projects/ /mnt/ssd/ai/claude-sessions/projects/ && rsync -a --update ~/.claude/history.jsonl /mnt/ssd/ai/claude-sessions/history.jsonl && rsync -a --update ~/.claude/usage-data/ /mnt/ssd/ai/claude-sessions/usage-data/`
2. Run with `CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects` prefix, not from `~/.claude/`.

Session analysis:
```bash
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects ~/git/rhizone/normalize/target/debug/normalize sessions stats --all-projects --limit 0 --group-by project,day --since YYYY-MM-DD --until YYYY-MM-DD --compact
```

## Tools

Normalize for structural exploration (use before reading large files):
```bash
~/git/rhizone/normalize/target/debug/normalize view <file>     # structural outline with line numbers
~/git/rhizone/normalize/target/debug/normalize view <dir>      # directory structure
```

## Context Is The Only Scarce Resource

Every byte that enters the main session stays in the main session for its entire lifetime. File contents, command output, search results, page text — once read, it lingers in cache and shapes every downstream token. There is no "just looking."

**All exploration runs in subagents.** Investigations, audits, deep dives, surveys, "let me check," "let me find" — if the purpose of a tool sequence is to find out something you don't yet know, it runs in a subagent. Renaming the activity does not change what it is. The subagent returns a distilled summary; the raw output stays in the subagent.

The main session holds only the durable artifacts you are producing: the edit, the commit, the doc update.

**Subagent model tiers:**
- Opus — design, architecture, any subagent that itself spawns subagents.
- Sonnet — implementation, mechanical multi-file work, default exploration.

Use Opus for exploration only when the search requires architectural judgment, not lookup.

## Durability

Subagent reports, mid-session realizations, "I'll remember this" — none of these outlast the session. Anything worth keeping goes into CLAUDE.md, code, docs, or a commit. If it isn't written down, it is gone.

**Commit completed work immediately.** Uncommitted work is lost work. Ecosystem-wide changes that affect docs go in the same commit as the code — there is no follow-up.

## Authenticity

When asked to analyze X, read X. Do not synthesize from conversation memory, prior summaries, or what the file probably says. Claims must correspond to evidence produced this session — particularly when updating ecosystem docs, verify against source rather than reasoning from the project tables.

**Something unexpected is a signal.** Surprising output, anomalous numbers, a file containing what it shouldn't — stop and find out why. Do not accept the anomaly and proceed.

## Discipline

Corrections from the user are conversation, not material for new rules. A single correction does not warrant a CLAUDE.md edit. Rules are added when a failure mode is observed repeatedly and the rule names the failure it prevents.

Do not announce actions ("I will now…"). Act.

## Hard Constraints

- No `--no-verify`. Fix the issue or fix the hook.
- No path dependencies in `Cargo.toml` — they couple repos and break independent publishing.
- No suggesting project names. LLMs are bad at this; refine the conceptual space only.
- No tracking cross-project issues in conversation — they go in TODO.md in the affected repo.
- No ecosystem changes without checking all affected repos.
- No assuming a tool is missing without checking `nix develop`.
