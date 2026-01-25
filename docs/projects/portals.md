# Portals

**Standard library interfaces.**

::: info Status: Fleshed Out ◐
~8.2K lines of Rust across 50 crates: 23 interface crates, 20 native backends, 3 mock backends, 5 WASM backends, 2 portable backends. Capability audit completed. Roadmap fully completed (8/8 checkpoints). Maturity limited primarily by ecosystem adoption rather than design/implementation gaps.
:::

**Repository:** [github.com/rhi-zone/portals](https://github.com/rhi-zone/portals)

## Overview

Portals provides capability-based, async-first interfaces inspired by WASI, designed to be implementable across runtimes.

## Interface Crates (23)

| Category | Interfaces |
|----------|------------|
| **WASI-aligned** | clocks, filesystem, http, io, random, sockets |
| **Storage** | blobstore, cache, keyvalue, sql |
| **Network** | dns, websocket, messaging |
| **Security** | crypto (SHA2, HMAC, AES-GCM, Ed25519, Argon2) |
| **Utilities** | config, cron, encoding, logging, markdown, nanoid, observe, snowflake, timezone |

## Backends

Each interface has multiple backend implementations:

| Type | Count | Examples |
|------|-------|----------|
| **Native** | 19 | tokio-based sockets, reqwest HTTP, libsql |
| **WASM** | 5 | gloo-net HTTP, web-sys console logging |
| **Mock** | 3 | Testing implementations for clocks, HTTP, random |
| **Portable** | 2 | cron, encoding (work on native + WASM) |

## Design Principles

- **Capability-based**: Access is granted through capability objects, not ambient authority
- **Async-first**: Operations that may block return futures
- **Minimal**: Define interfaces, not implementations
- **Portable**: Implementable on native, WASM, and embedded targets

## Links

- [GitHub](https://github.com/rhi-zone/portals)
