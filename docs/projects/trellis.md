# Trellis

Composable derive macros for Rust.

**Repository:** [github.com/rhizome-lab/trellis](https://github.com/rhizome-lab/trellis)

## Overview

Trellis is a collection of composable derive macros for common Rust patterns. The name comes from garden trellises—lattice structures that support climbing plants, providing structure while remaining flexible.

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
#[derive(ServerCore, OpenApi, Anubis, Serve)]  // Anubis from trellis-anubis crate
struct MyServer;
```

## Structure

```
trellis/
├── crates/
│   ├── trellis/              # Main crate (re-exports all macros)
│   ├── trellis-derive/       # Proc macro implementations
│   ├── trellis-server/       # Server-related macros
│   └── trellis-*/            # Other macro categories
└── docs/                     # VitePress documentation
```

## Links

- [GitHub](https://github.com/rhizome-lab/trellis)
- [Spore](/projects/spore) - Uses trellis for server setup
