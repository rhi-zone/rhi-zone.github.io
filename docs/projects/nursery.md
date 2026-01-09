# Nursery

**Ecosystem orchestrator for Rhizome tools.**

Nursery is the glue that holds the Rhizome ecosystem together. Instead of memorizing arguments for multiple tools, you write one `rhizome.toml` manifest.

## Key Features

- **Manifest-Driven** - One `rhizome.toml` file defines how all tools compose
- **Seeds** - Starter templates for common workflows
- **Lazy Discovery** - Only inspects tools that are referenced
- **Fail Informatively** - Clear errors when tools are missing or misconfigured

## The Manifest

```toml
# rhizome.toml
[project]
name = "my-project"
version = "0.1.0"

[winnow]
source = "./dump/game.exe"
strategy = "gms2"
assets = "./assets/raw"

[lotus]
target = "web-wasm"
port = 8080
```

This file **is** the documentation. It shows exactly how the tools compose for your project.

## Seeds

Pre-configured starter templates:

- **seed-archaeology** - Lifting legacy games (winnow → lotus)
- **seed-creation** - New Lotus projects from scratch
- **seed-lab** - Full ecosystem sandbox

## Links

- [GitHub](https://github.com/rhizome-lab/nursery)
- [Documentation](https://rhizome-lab.github.io/nursery/)
