# Moonlet

**Lua runtime with plugin system for the rhi ecosystem.**

::: info Status: Fleshed Out ◐
~138K lines of Rust across 11 crates. Modular plugin architecture with 8 working integrations (fs, libm, normalize, packages, sessions, tools, llm, embed). Feature-complete for core mission (multi-provider LLM client + Lua runtime). One architectural task remaining: abstract LLM APIs to reduce rig coupling.
:::

**Repository:** [github.com/rhi-zone/moonlet](https://github.com/rhi-zone/moonlet)

## Overview

Moonlet provides a Lua execution environment with integrations for other rhi projects:

- **Lua runtime** - mlua-based execution environment with plugin architecture
- **Integrations** - Domain-specific Lua APIs via the Integration trait

## Crates

| Crate | Description |
|-------|-------------|
| `moonlet-core` | Core runtime infrastructure |
| `moonlet-lua` | Lua runtime with Integration trait |

### Integrations

| Crate | Description |
|-------|-------------|
| `moonlet-embed` | Embedding generation |
| `moonlet-fs` | Filesystem with capability-based security |
| `moonlet-libsql` | LibSQL/SQLite with vector support |
| `moonlet-llm` | LLM client APIs |
| `moonlet-normalize` | [Normalize](/projects/normalize) code analysis |
| `moonlet-packages` | Package management |
| `moonlet-sessions` | Session log parsing |
| `moonlet-tools` | External tools integration |

## Usage

```rust
use moonlet_lua::Runtime;
use moonlet_normalize::NormalizeIntegration;

let runtime = Runtime::new()?;
runtime.register(&NormalizeIntegration::new("."))?;
runtime.run_file(Path::new("scripts/analyze.lua"))?;
```

## Links

- [GitHub](https://github.com/rhi-zone/moonlet)
