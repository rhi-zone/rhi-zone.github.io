# rhi

A glue layer for computers. Removing boundaries between you and your computer.

**https://rhi.zone**

## Projects

### Code Intelligence

| Project | Description |
|---------|-------------|
| [Normalize](https://github.com/rhi-zone/normalize) | Structural code intelligence for humans and AI agents |

### Generation

| Project | Description |
|---------|-------------|
| [Unshape](https://github.com/rhi-zone/unshape) | Constructive media generation in Rust |
| [Dew](https://github.com/rhi-zone/dew) | Minimal expression language for procedural generation |

### Games & Worlds

| Project | Description |
|---------|-------------|
| [Playmate](https://github.com/rhi-zone/playmate) | Game design primitives library |
| [Interconnect](https://github.com/rhi-zone/interconnect) | Federation protocol for interconnected persistent worlds |

### Data Transformation

| Project | Description |
|---------|-------------|
| [Paraphase](https://github.com/rhi-zone/paraphase) | Pipeline orchestrator for data conversion |
| [rescribe](https://github.com/rhi-zone/rescribe) | Lossless document conversion library |
| [Concord](https://github.com/rhi-zone/concord) | API bindings IR and code generation |
| [Resurrect](https://github.com/rhi-zone/resurrect) | Legacy software lifting framework |

### Runtime & Interface

| Project | Description |
|---------|-------------|
| [Moonlet](https://github.com/rhi-zone/moonlet) | Lua runtime with plugin system |
| [Dusklight](https://github.com/rhi-zone/dusklight) | Universal UI client with control plane |

### Infrastructure

| Project | Description |
|---------|-------------|
| [Myenv](https://github.com/rhi-zone/myenv) | Ecosystem orchestrator via rhi.toml manifests |
| [Portals](https://github.com/rhi-zone/portals) | Standard library interfaces |
| [Zone](https://github.com/rhi-zone/zone) | Lua-based tools, scaffolds, and orchestration |
| [server-less](https://github.com/rhi-zone/server-less) | Derive macros: one impl → many protocols |

## Development

```bash
cd docs
bun install
bun run dev
```

## Special Thanks

rhi builds on the shoulders of giants. We're grateful to these projects and communities:

### Core Technologies
- [Rust](https://www.rust-lang.org/) - The language that makes safe systems programming practical
- [LuaJIT](https://luajit.org/) - Lightning-fast scripting runtime powering Moonlet
- [tree-sitter](https://tree-sitter.github.io/) - Incremental parsing powering Normalize
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
- [wgpu](https://wgpu.rs/) - Cross-platform GPU API (Unshape)
- [Burn](https://burn.dev/) - Deep learning framework
- [libsql](https://github.com/tursodatabase/libsql) - SQLite fork with async support
- [rig](https://github.com/0xPlaygrounds/rig) - LLM application framework
- [ignore](https://docs.rs/ignore/) - gitignore-aware file walking
- [notify](https://docs.rs/notify/) - Cross-platform filesystem watcher
- [nucleo](https://github.com/helix-editor/nucleo) - Fuzzy matching

### Inspiration
- [Pandoc](https://pandoc.org/) - Universal document converter inspiring rescribe
- [WASI](https://wasi.dev/) - Capability-based interfaces inspiring Portals
- The broader open source community for showing us what's possible
