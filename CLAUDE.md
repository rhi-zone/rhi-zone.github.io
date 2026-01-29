# CLAUDE.md

Behavioral rules for Claude Code in the rhi ecosystem docs repository.

## Ecosystem

This is the organization-level documentation site for the rhi ecosystem.

### Projects

**Code Intelligence**

| Project | Path | Description |
|---------|------|-------------|
| **Normalize** | `~/git/rhizone/normalize` | Structural code intelligence |

**Generation**

| Project | Path | Description |
|---------|------|-------------|
| **Unshape** | `~/git/rhizone/unshape` | Constructive media generation |
| **Dew** | `~/git/rhizone/dew` | Minimal expression language |

**Games & Worlds**

| Project | Path | Description |
|---------|------|-------------|
| **Playmate** | `~/git/rhizone/playmate` | Game design primitives library |
| **Interconnect** | `~/git/rhizone/interconnect` | Federation protocol for persistent worlds |

**Data Transformation**

| Project | Path | Description |
|---------|------|-------------|
| **Paraphase** | `~/git/rhizone/paraphase` | Pipeline orchestrator for data conversion |
| **rescribe** | `~/git/rhizone/rescribe` | Lossless document conversion library |
| **Concord** | `~/git/rhizone/concord` | API bindings IR and codegen |
| **Reincarnate** | `~/git/rhizone/reincarnate` | Legacy software lifting framework |

**Runtime & Interface**

| Project | Path | Description |
|---------|------|-------------|
| **Moonlet** | `~/git/rhizone/moonlet` | Lua runtime with plugin system |
| **Dusklight** | `~/git/rhizone/dusklight` | Universal UI client with control plane |

**Infrastructure**

| Project | Path | Description |
|---------|------|-------------|
| **Myenv** | `~/git/rhizone/myenv` | Ecosystem orchestrator |
| **Portals** | `~/git/rhizone/portals` | Standard library interfaces |
| **Zone** | `~/git/rhizone/zone` | Lua-based tools, scaffolds, and orchestration |
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
| **hologram** | `~/git/exo-place/hologram` | Discord RP bot with knowledge graph and RAG |

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

### Scaffolding New Repos

Template files are in `scaffolding/` directory. Copy and replace placeholders:

```bash
cp -r scaffolding/. ~/git/rhizone/new-project/
sed -i 's/PROJECT_NAME/new-project/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/docs/package.json ~/git/rhizone/new-project/CLAUDE.md
sed -i 's/PROJECT_DESCRIPTION/Description here/g' ~/git/rhizone/new-project/flake.nix ~/git/rhizone/new-project/CLAUDE.md
```

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
- `Cargo.toml` + `crates/`
- `docs/.vitepress/config.ts` + `docs/index.md`

### Crate Naming Convention

Rust crates use NO prefix (names are available on crates.io):
- `normalize-core`, `moonlet-core`, `unshape-backend`, etc.
- `rescribe`, `server-less`, `dew` (standalone names)
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

## Tools

**Normalize** for structural code/doc exploration:
```bash
~/git/rhizone/normalize/target/debug/normalize view <file>     # structural outline with line numbers
~/git/rhizone/normalize/target/debug/normalize view <dir>      # directory structure
```

Especially useful for large files - get the structure first, then read specific sections.

## Core Rules

**Note things down immediately:**
- Ecosystem changes → this file or relevant project's docs
- Cross-project issues → TODO.md in affected repos
- Documentation updates → do them, don't defer

**Do the work properly.** When updating ecosystem docs, actually check the source repos for accuracy.

## Negative Constraints

Do not:
- Announce actions ("I will now...") - just do them
- Leave work uncommitted
- Make ecosystem changes without checking all affected repos
- Update docs without verifying against source
- Use path dependencies in Cargo.toml - causes clippy to stash changes across repos
- Use `--no-verify` - fix the issue or fix the hook
- Assume tools are missing - check if `nix develop` is available for the right environment
