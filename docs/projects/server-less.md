# Server-Less

**Composable derive macros for Rust.**

::: info Status: Fleshed Out ◐
~17K lines of Rust across 6 crates, 187 tests. Multiple protocol implementations (HTTP, CLI, MCP, WebSocket, JSON-RPC, GraphQL, gRPC schema generation). Comprehensive docs with tutorials. Phase 4 of OpenAPI composition in progress. HTTP/CLI/MCP stable; remaining: middleware, streaming, client generation.
:::

**Repository:** [github.com/rhi-zone/server-less](https://github.com/rhi-zone/server-less)

## Overview

Server-Less is a collection of composable derive macros for common Rust patterns. The name comes from garden server-lesses—lattice structures that support climbing plants, providing structure while remaining flexible.

The primary goal is minimizing barrier to entry: "I just want a server" should be trivially simple.

## Philosophy

### Progressive Disclosure

Complexity only appears when needed:

```rust
// Level 1: Just works
#[derive(Server)]
struct MyServer;

// Level 2: Toggle features
#[derive(Server)]
#[server(openapi = false)]
struct MyServer;

// Level 3: Fine-tune
#[derive(Server)]
#[server(openapi(path = "/docs", hidden = [internal_method]))]
struct MyServer;

// Level 4: Escape hatch - drop to manual code
```

### Two-Tier Design

**Blessed preset** - batteries included:
```rust
#[derive(Server)]  // includes: ServerCore + OpenApi + Metrics + HealthCheck + Serve
struct MyServer;
```

**À la carte** - explicit composition:
```rust
#[derive(ServerCore, OpenApi, Metrics, Serve)]  // explicit, no HealthCheck
struct MyServer;
```

### Third-Party Extensions

Extensions are separate derives that compose with core:
```rust
#[derive(ServerCore, OpenApi, Anubis, Serve)]  // Anubis from server-less-anubis crate
struct MyServer;
```

## Structure

```
server-less/
├── crates/
│   ├── server-less/              # Main crate (re-exports all macros)
│   ├── server-less-derive/       # Proc macro implementations
│   ├── server-less-server/       # Server-related macros
│   └── server-less-*/            # Other macro categories
└── docs/                     # VitePress documentation
```

## Links

- [GitHub](https://github.com/rhi-zone/server-less)
- [Moonlet](/projects/moonlet) - Uses server-less for server setup
