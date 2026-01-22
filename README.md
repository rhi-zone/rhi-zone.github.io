# Rhizome

Tools for programmable creativity.

**https://rhizome-lab.github.io**

## Projects

### Code Intelligence

| Project | Description |
|---------|-------------|
| [Moss](https://github.com/rhizome-lab/moss) | Structural code intelligence for humans and AI agents |

### Generation

| Project | Description |
|---------|-------------|
| [Resin](https://github.com/rhizome-lab/resin) | Constructive media generation in Rust |
| [Dew](https://github.com/rhizome-lab/dew) | Minimal expression language for procedural generation |

### Games & Worlds

| Project | Description |
|---------|-------------|
| [Frond](https://github.com/rhizome-lab/frond) | Game design primitives library |
| [Hypha](https://github.com/rhizome-lab/hypha) | Federation protocol for interconnected persistent worlds |

### Data Transformation

| Project | Description |
|---------|-------------|
| [Cambium](https://github.com/rhizome-lab/cambium) | Pipeline orchestrator for data conversion |
| [rescribe](https://github.com/rhizome-lab/rescribe) | Lossless document conversion library |
| [Liana](https://github.com/rhizome-lab/liana) | API bindings IR and code generation |
| [Siphon](https://github.com/rhizome-lab/siphon) | Legacy software lifting framework |

### Runtime & Interface

| Project | Description |
|---------|-------------|
| [Spore](https://github.com/rhizome-lab/spore) | Lua runtime with plugin system |
| [Canopy](https://github.com/rhizome-lab/canopy) | Universal UI client with control plane |

### Infrastructure

| Project | Description |
|---------|-------------|
| [Nursery](https://github.com/rhizome-lab/nursery) | Ecosystem orchestrator via rhizome.toml manifests |
| [Pith](https://github.com/rhizome-lab/pith) | Standard library interfaces |
| [Flora](https://github.com/rhizome-lab/flora) | Lua-based tools, scaffolds, and orchestration |
| [server-less](https://github.com/rhizome-lab/server-less) | Derive macros: one impl → many protocols |

## Development

```bash
cd docs
bun install
bun run dev
```

## Special Thanks

Rhizome builds on the shoulders of giants. We're grateful to these projects and communities:

### Core Technologies
- [Rust](https://www.rust-lang.org/) - The language that makes safe systems programming practical
- [LuaJIT](https://luajit.org/) - Lightning-fast scripting runtime powering Spore
- [tree-sitter](https://tree-sitter.github.io/) - Incremental parsing powering Moss
- [Arborium](https://arborium.bearcove.eu/) - Curated tree-sitter grammars

### Development Tools
- [Nix](https://nixos.org/) - Reproducible development environments
- [direnv](https://direnv.net/) - Environment switcher for the shell
- [VitePress](https://vitepress.dev/) - Modern documentation framework
- [GitHub Actions](https://github.com/features/actions) - CI/CD infrastructure

### Rust Ecosystem Core
- [Tokio](https://tokio.rs/) - Async runtime
- [Axum](https://github.com/tokio-rs/axum) - Ergonomic web framework
- [serde](https://serde.rs/) - Serialization framework
- [clap](https://docs.rs/clap/) - Command-line argument parsing
- [thiserror](https://docs.rs/thiserror/) - Error handling
- [mlua](https://github.com/mlua-rs/mlua) - Lua/LuaJIT bindings

### Domain-Specific
- [wgpu](https://wgpu.rs/) - Cross-platform GPU API (Resin)
- [Burn](https://burn.dev/) - Deep learning framework
- [libsql](https://github.com/tursodatabase/libsql) - SQLite fork with async support
- [rig](https://github.com/0xPlaygrounds/rig) - LLM application framework
- [ignore](https://docs.rs/ignore/) - gitignore-aware file walking
- [notify](https://docs.rs/notify/) - Cross-platform filesystem watcher
- [nucleo](https://github.com/helix-editor/nucleo) - Fuzzy matching

### Inspiration
- [Pandoc](https://pandoc.org/) - Universal document converter inspiring rescribe
- [WASI](https://wasi.dev/) - Capability-based interfaces inspiring Pith
- The broader open source community for showing us what's possible
