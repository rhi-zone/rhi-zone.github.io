# CLAUDE.md

Behavioral rules for Claude Code in the rhi ecosystem docs repository.

## Ecosystem

This is the organization-level documentation site for the rhi ecosystem.

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
| **Interconnect** | `~/git/rhizone/interconnect` | Federation protocol for persistent worlds |
| **Scribble** | `~/git/rhizone/scribble` | Sketch-level creative environment |

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
| **Myenv** | `~/git/rhizone/myenv` | Ecosystem orchestrator |
| **Portals** | `~/git/rhizone/portals` | Standard library interfaces |
| **Zone** | `~/git/rhizone/zone` | Lua-based tools, scaffolds, and orchestration |
| **Nanites** | `~/git/rhizone/nanites` | Flexible orchestration |
| **server-less** | `~/git/rhizone/server-less` | Derive macros: one impl → many protocols |

### Org Resources

| Resource | Path | Description |
|----------|------|-------------|
| **.github** | `~/git/rhizone/profile` | Org-wide GitHub config, templates |
| **Docs site** | `~/git/rhizone/github-io` | This repo - org documentation |

### External / Related Repos

| Project | Path | Description |
|---------|------|-------------|
| **sketchpad** | `~/git/rhizone/sketchpad` | Stable Diffusion in pure Rust (burn) |
| **ooxml** | `~/git/ooxml` | Office Open XML library for Rust |
| **claude-code-hub** | `~/git/claude-code-hub` | Orchestration hub for Claude Code agents |
| **hologram** | `~/git/exoplace/hologram` | Discord RP bot with knowledge graph and RAG |
| **aspect** | `~/git/exoplace/aspect` | Card-based identity exploration sandbox |
| **existence** | `~/git/paragarden/existence` | Text-based HTML5 game — power anti-fantasy |
| **legacy** | `~/git/paragarden/legacy` | Worldbuilding project — what humanity left behind |
| **divergence** | `~/git/paragarden/divergence` | Worldbuilding project — what happens when the floor gets built |
| **keybinds** | `~/git/keybinds` | Keybind/command palette library (used in ptera.world, reincarnate) |
| **ascent-interpreter** | `~/git/ascent-interpreter` | Interpreted Ascent (Datalog); used in normalize alongside AOT ascent |

## Responsibilities

### Ecosystem-Wide Refactors

One of your responsibilities is executing ecosystem-wide refactors. When asked to make changes across the ecosystem:

1. Check git status of all affected repos
2. For clean repos: make the changes directly
3. For dirty repos: add to that repo's TODO.md
4. Update this docs site if the change affects documentation
5. Use conventional commits with scope indicating affected projects

### Keeping Docs in Sync

When projects change:
- Update project pages in `docs/projects/`
- Update the project table in `docs/about.md`
- Update `README.md` project table
- Update sidebar/nav in `.vitepress/config.ts`
- Update hero page features in `docs/index.md`
- Update the project table in `docs/projects/index.md`
- Update the org profile README at `~/git/rhizone/profile/profile/README.md`
- Update the ecosystem project list in this file (`CLAUDE.md`)

### Scaffolding New Repos

Template files are in `scaffolding/` directory. Copy and replace placeholders:

```bash
cp -r ~/git/0000000_pterror/.git ~/git/rhizone/new-project/.git
cp -r scaffolding/. ~/git/rhizone/new-project/
sed -i 's/PROJECT_NAME/new-project/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/docs/package.json ~/git/rhizone/new-project/CLAUDE.md
sed -i 's/PROJECT_DESCRIPTION/Description here/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/CLAUDE.md
```

The git repo should be copied from `~/git/0000000_pterror` (template repo with proper git history/config) — do NOT use `git init`.

**Included templates:**
- `.cargo/config.toml` - target bloat reduction + mold hint
- `.envrc` - nix-direnv integration
- `.gitignore` - Rust + Nix + Node ignores
- `.githooks/pre-commit` - fmt → clippy
- `.github/workflows/ci.yml` - CI pipeline
- `.github/workflows/deploy-docs.yml` - VitePress deployment
- `flake.nix` - Nix dev shell
- `docs/package.json` - VitePress + mermaid
- `CLAUDE.md` - standard behavioral rules (Core Rules, Design Principles, Commit Convention, Negative Constraints)
- `README.md` - project readme

**Still need manually:**
- `Cargo.toml` + `crates/` — create a workspace with a single dummy crate (`crates/PROJECT_NAME-core/`) so the pre-commit hook (cargo fmt + clippy) passes on first commit
- `docs/.vitepress/config.ts` + `docs/index.md`
- **Copy `.envrc`** from `scaffolding/` — committed, includes `source_env_if_exists .envrc.local`. Put secrets in `.envrc.local` (gitignored), never in `.envrc`
- **Copy `flake.nix`** from `scaffolding/` — also easy to forget
- **Fill in the `## Origin` section** — why the project exists, naming rationale, key design decisions from the scaffolding conversation. An agent spun up in the new repo has no access to that conversation; if it's not in CLAUDE.md, it's gone.
- **Optionally add a `TODO.md`** with initial directions from the scaffolding conversation — can be as high-level ("explore X, decide on Y") or as detailed as warranted.

### Creating the GitHub Repo

After scaffolding, create the GitHub repo and configure it:

```bash
gh repo create ORG/PROJECT_NAME --public --source ~/git/ORG_PATH/PROJECT_NAME --description "PROJECT_DESCRIPTION" --push
gh repo edit ORG/PROJECT_NAME --homepage "https://docs.rhi.zone/PROJECT_NAME/"
gh repo edit ORG/PROJECT_NAME --add-topic rust --add-topic TOPIC1 --add-topic TOPIC2
```

Enable GitHub Pages (if the repo has a docs site):
```bash
gh api repos/ORG/PROJECT_NAME/pages -X POST -f "build_type=workflow"
```

After updating ecosystem docs, push the docs site and org profile:
```bash
cd ~/git/rhizone/github-io && git push
cd ~/git/rhizone/profile && git push
```

### Renaming Repos

When renaming a repo:

1. Rename on GitHub: `gh repo rename NEW_NAME -R ORG/OLD_NAME --yes`
2. Update git remote: `git remote set-url origin https://github.com/ORG/NEW_NAME.git`
3. Move local directory: `mv ~/git/ORG_PATH/OLD_NAME ~/git/ORG_PATH/NEW_NAME`
4. Move Claude project dir: `mv ~/.claude/projects/-home-me-git-ORG_PATH-OLD_NAME ~/.claude/projects/-home-me-git-ORG_PATH-NEW_NAME`
5. Update repo settings: `gh repo edit ORG/NEW_NAME --homepage "..." --description "..."`
6. Update all in-repo references (site config, package.json, CLAUDE.md, README, etc.)
7. Update ecosystem docs (this file, org profile)

### GitHub Org Mapping

| Org (GitHub) | Disk Path | Domain |
|--------------|-----------|--------|
| **rhi-zone** | `~/git/rhizone/` | infrastructure, tooling, libraries, protocols |
| **exo-place** | `~/git/exoplace/` | biomes, places, platforms |
| **ptera-world** | `~/git/pteraworld/` | — |
| **para-garden** | `~/git/paragarden/` | concrete games, experiences, creative works |

When scaffolding repos for any of these orgs, use the appropriate GitHub org name and disk path.

### Crate Naming Convention

Rust crates use NO prefix (names are available on crates.io):
- `normalize-core`, `moonlet-core`, `unshape-backend`, etc.
- `rescribe`, `server-less`, `wick` (standalone names)
- Binary names match project names (just `normalize`, `moonlet`, `rescribe`, `server-less`, etc.)

All project names were carefully selected to avoid conflicts on crates.io.

### Docs Site Conventions

**Monorepo docs should link back to the main ecosystem site:**

When a monorepo (normalize, moonlet, unshape, etc.) has its own docs site, include a navbar link back to the main rhi docs. In VitePress config:

```ts
nav: [
  // ... other nav items
  { text: 'rhi', link: 'https://rhi.zone/' },
]
```

This ensures users can navigate between project-specific docs and the ecosystem overview.

## Activity Logs

**`docs/introspection/log/`** — weekly snapshots of ecosystem activity. **Read the most recent entry first when evaluating direction, focus, or what's been active.** Each file is named by end date (e.g. `2026-02-25.md`) and contains commit volume, cost breakdown, focus pattern, and observations.

**`docs/introspection/log/daily/`** — daily session summaries auto-generated from raw Claude Code session messages. Named `YYYY-MM-DD.md`. Each covers one day's sessions across all projects.

**`docs/introspection/log/synthesis-*.md`** — cross-cutting pattern analysis synthesized from daily logs over a date range.

These logs are the canonical record of what was being worked on and why. Check them before asking "what should we work on?" or "what were we focused on?"

### Updating Daily Logs

Run this checklist to bring daily logs up to date:

1. **Backup sessions first:**
   ```bash
   rsync -a --update ~/.claude/projects/ /mnt/ssd/ai/claude-sessions/projects/ && rsync -a --update ~/.claude/history.jsonl /mnt/ssd/ai/claude-sessions/history.jsonl && rsync -a --update ~/.claude/usage-data/ /mnt/ssd/ai/claude-sessions/usage-data/
   ```
   (`--update` skips destination files newer than source, safe for incremental runs)
   (`usage-data/` contains pre-computed `/insights` facets — incremental, worth preserving)

2. **Find missing days:** List files in `docs/introspection/log/daily/` and compare against today's date to find gaps.

3. **Spawn haiku agents in parallel** — one per missing day:
   ```bash
   CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects ~/git/rhizone/normalize/target/debug/normalize sessions messages --all-projects --role user --since YYYY-MM-DD --until YYYY-MM-DD+1 --limit 0 --show-usage
   ```
   Each agent: observe what's interesting, write to `docs/introspection/log/daily/YYYY-MM-DD.md`. If no messages, note it as a quiet day. Include a `## Token Usage` section with per-session output tokens and cache hit ratios.

   **If synthesis insights feel thin:** re-run agents on existing logs passing `--show-usage` output and the existing log as reference, instructing them to flag token outliers (e.g. high churn from debugging, poor cache efficiency on cold-start sessions, output spikes from architectural sprints). Then re-run the opus synthesis.

4. **Add new days to sidebar** in `docs/.vitepress/config.ts` under the Daily Logs section.

5. **Update synthesis if significant new material** (a week or more of new days): spawn an opus agent to read all daily logs and write/update `docs/introspection/log/synthesis-<start>-<end>.md`. Tell it patterns and CLAUDE.md conventions may have evolved over the period.

6. **Commit and push.**

## Session Data

Claude Code deletes session `.jsonl` files based on `cleanupPeriodDays` in `~/.claude/settings.json` (default: 30 days). Currently set to `999999` to prevent deletion. Cannot use `0` (intended to mean "never clean up") due to [bug #23710](https://github.com/anthropics/claude-code/issues/23710) — `0` silently disables all transcript persistence.

**Backup location:** `/mnt/ssd/ai/claude-sessions/`

**Before running any session analysis:**
1. Re-backup: `rsync -a --update ~/.claude/projects/ /mnt/ssd/ai/claude-sessions/projects/ && rsync -a --update ~/.claude/history.jsonl /mnt/ssd/ai/claude-sessions/history.jsonl && rsync -a --update ~/.claude/usage-data/ /mnt/ssd/ai/claude-sessions/usage-data/`
2. Run analyses with `CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects` prefix, not from `~/.claude/`

**Session analysis with normalize:**
```bash
CLAUDE_SESSIONS_DIR=/mnt/ssd/ai/claude-sessions/projects ~/git/rhizone/normalize/target/debug/normalize sessions stats --all-projects --limit 0 --group-by project,day --since YYYY-MM-DD --until YYYY-MM-DD --compact
```

## Tools

**Normalize** for structural code/doc exploration:
```bash
~/git/rhizone/normalize/target/debug/normalize view <file>     # structural outline with line numbers
~/git/rhizone/normalize/target/debug/normalize view <dir>      # directory structure
```

Especially useful for large files - get the structure first, then read specific sections.

### Session Handoff

Use plan mode as a handoff mechanism when:
- A task is fully complete (committed, pushed, docs updated)
- The session has drifted from its original purpose
- Context has accumulated enough that a fresh start would help

**For handoffs:** flush TODO.md, then enter plan mode and write a plan containing only: next tasks, blocked/pending items, and what was done this session (only if it directly affects what comes next). Nothing else — no commands, no build steps, no context summaries. Those belong in CLAUDE.md or TODO.md. The next session reads both fresh.

ExitPlanMode hands control back to the user to approve, redirect, or stop.

## Core Rules

**Note things down immediately:**
- Ecosystem changes → this file or relevant project's docs
- Cross-project issues → TODO.md in affected repos
- Documentation updates → do them, don't defer

**Do the work properly.** When updating ecosystem docs, actually check the source repos for accuracy.

## Negative Constraints

Do not:
- Use Claude Code's auto-memory system (`~/.claude/projects/.*./memory/`) — it is unversioned, invisible to the user, and can't be diffed or backed up. Write behavioral changes directly to CLAUDE.md instead
- Suggest project names — LLMs are historically bad at this; let the user come up with names. If the user asks for naming directions, help refine the conceptual space only — never suggest actual names
- Announce actions ("I will now...") - just do them
- Leave work uncommitted
- Make ecosystem changes without checking all affected repos
- Update docs without verifying against source
- Use path dependencies in Cargo.toml - causes clippy to stash changes across repos
- Use `--no-verify` - fix the issue or fix the hook
- Assume tools are missing - check if `nix develop` is available for the right environment
