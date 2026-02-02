# rhi

A glue layer for computers. Removing boundaries between you and your computer.

**https://rhi.zone**

## Projects

### Code Intelligence

| Project | Description |
|---------|-------------|
| [normalize](https://github.com/rhi-zone/normalize) | Structural code intelligence for humans and AI agents |
| [gels](https://github.com/rhi-zone/gels) | Trait-based grammar inference engine |

### Generation

| Project | Description |
|---------|-------------|
| [unshape](https://github.com/rhi-zone/unshape) | Constructive media generation in Rust |
| [dew](https://github.com/rhi-zone/dew) | Minimal expression language for procedural generation |

### Games & Worlds

| Project | Description |
|---------|-------------|
| [playmate](https://github.com/rhi-zone/playmate) | Game design primitives library |
| [interconnect](https://github.com/rhi-zone/interconnect) | Federation protocol for interconnected persistent worlds |

### Data Transformation

| Project | Description |
|---------|-------------|
| [paraphase](https://github.com/rhi-zone/paraphase) | Pipeline orchestrator for data conversion |
| [rescribe](https://github.com/rhi-zone/rescribe) | Lossless document conversion library |
| [concord](https://github.com/rhi-zone/concord) | API bindings IR and code generation |
| [reincarnate](https://github.com/rhi-zone/reincarnate) | Legacy software lifting framework |

### Runtime & Interface

| Project | Description |
|---------|-------------|
| [moonlet](https://github.com/rhi-zone/moonlet) | Lua runtime with plugin system |
| [dusklight](https://github.com/rhi-zone/dusklight) | Universal UI client with control plane |

### Infrastructure

| Project | Description |
|---------|-------------|
| [myenv](https://github.com/rhi-zone/myenv) | Ecosystem orchestrator via rhi.toml manifests |
| [portals](https://github.com/rhi-zone/portals) | Standard library interfaces |
| [zone](https://github.com/rhi-zone/zone) | Lua-based tools, scaffolds, and orchestration |
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
- [LuaJIT](https://luajit.org/) - Lightning-fast scripting runtime powering moonlet
- [tree-sitter](https://tree-sitter.github.io/) - Incremental parsing powering normalize
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
- [wgpu](https://wgpu.rs/) - Cross-platform GPU API (unshape)
- [Burn](https://burn.dev/) - Deep learning framework
- [libsql](https://github.com/tursodatabase/libsql) - SQLite fork with async support
- [rig](https://github.com/0xPlaygrounds/rig) - LLM application framework
- [ignore](https://docs.rs/ignore/) - gitignore-aware file walking
- [notify](https://docs.rs/notify/) - Cross-platform filesystem watcher
- [nucleo](https://github.com/helix-editor/nucleo) - Fuzzy matching

### Inspiration
- [Pandoc](https://pandoc.org/) - Universal document converter inspiring rescribe
- [WASI](https://wasi.dev/) - Capability-based interfaces inspiring portals
- The broader open source community for showing us what's possible
