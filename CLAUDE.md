# CLAUDE.md

Behavioral rules for Claude Code in the Rhizome ecosystem docs repository.

## Ecosystem

This is the organization-level documentation site for the Rhizome ecosystem.

### Projects

| Project | Path | Description |
|---------|------|-------------|
| **Moss** | `~/git/moss` | Structural code intelligence |
| **Lotus** | `~/git/lotus` | Persistent multiplayer world runtime |
| **Hypha** | `~/git/hypha` | Federation protocol for persistent worlds |
| **Resin** | `~/git/resin` | Constructive media generation |
| **Frond** | `~/git/frond` | Game design primitives library |
| **Dew** | `~/git/dew` | Minimal expression language |
| **Liana** | `~/git/liana` | API bindings IR and codegen |
| **Cambium** | `~/git/cambium` | Pipeline orchestrator for data conversion |
| **Canopy** | `~/git/canopy` | Universal UI client with control plane |
| **Siphon** | `~/git/siphon` | Legacy software lifting framework |
| **Nursery** | `~/git/nursery` | Ecosystem orchestrator |
| **Spore** | `~/git/spore` | Agentic AI framework |
| **Reed** | `~/git/reed` | Language translation layer (source → IR → source) |

### Org Resources

| Resource | Path | Description |
|----------|------|-------------|
| **.github** | `~/git/rhizome-lab-github` | Org-wide GitHub config, templates |
| **Docs site** | `~/git/rhizome-lab-github-io` | This repo - org documentation |

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

### Scaffolding New Repos

Template files are in `scaffolding/` directory. Copy and replace placeholders:

```bash
cp -r scaffolding/. ~/git/new-project/
sed -i 's/PROJECT_NAME/new-project/g' ~/git/new-project/flake.nix ~/git/new-project/docs/package.json
sed -i 's/PROJECT_DESCRIPTION/Description here/g' ~/git/new-project/flake.nix
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

**Still need manually:**
- `Cargo.toml` + `crates/`
- `docs/.vitepress/config.ts` + `docs/index.md`
- `CLAUDE.md`

### Crate Naming Convention

All Rust crates in the ecosystem should be prefixed with `rhizome-`:
- `rhizome-moss-core`, `rhizome-lotus-runtime`, etc.
- Binary names should NOT be prefixed (just `moss`, `lotus`, etc.)

### Docs Site Conventions

**Monorepo docs should link back to the main ecosystem site:**

When a monorepo (moss, lotus, resin, etc.) has its own docs site, include a navbar link back to the main Rhizome docs. In VitePress config:

```ts
nav: [
  // ... other nav items
  { text: 'Rhizome', link: 'https://rhizome-lab.github.io/' },
]
```

This ensures users can navigate between project-specific docs and the ecosystem overview.

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
