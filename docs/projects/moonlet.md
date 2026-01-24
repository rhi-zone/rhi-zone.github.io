# Moonlet

Lua runtime with plugin system for the rhi ecosystem.

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
| `moonlet-normalize` | Adds [Normalize](/projects/normalize) code analysis to Lua |
| `moonlet-llm` | Adds LLM client APIs to Lua |

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
