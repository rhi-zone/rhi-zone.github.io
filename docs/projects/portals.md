# Portals

Standard library interfaces.

**Repository:** [github.com/rhi-zone/portals](https://github.com/rhi-zone/portals)

## Overview

Portals provides capability-based, async-first interfaces inspired by WASI, designed to be implementable across runtimes.

## Crates

| Crate | Description | WASI Equivalent |
|-------|-------------|-----------------|
| `portals-clocks` | Wall clock, monotonic clock | `wasi:clocks` |
| `portals-cli` | Args, environment, stdio | `wasi:cli` |
| `portals-filesystem` | Files, directories | `wasi:filesystem` |
| `portals-http` | HTTP client/server | `wasi:http` |
| `portals-io` | Streams, polling | `wasi:io` |
| `portals-random` | Secure and insecure RNG | `wasi:random` |
| `portals-sockets` | TCP, UDP, DNS | `wasi:sockets` |

## Design Principles

- **Capability-based**: Access is granted through capability objects, not ambient authority
- **Async-first**: Operations that may block return futures
- **Minimal**: Define interfaces, not implementations
- **Portable**: Implementable on native, WASM, and embedded targets

## Links

- [GitHub](https://github.com/rhi-zone/portals)
