# Concord

**API bindings IR and code generation.**

::: info Status: Growing ◔
~1.2K lines of Rust across 2 crates (concord-core, concord-codegen). Working MVP with functional OpenAPI → Rust codegen, dogfood tested on petstore. Clear architecture and documented design decisions. Remaining: inline/anonymous enums, integer enums, multi-language codegen.
:::

Concord provides a unified intermediate representation for API definitions, enabling code generation across languages and frameworks.

## Key features

- **Language-agnostic IR** - Core types represent APIs independent of target language
- **Multi-target codegen** - Generate bindings for Rust, TypeScript, Lua, etc.
- **Schema-driven** - Parse OpenAPI, JSON Schema, and other formats

## Architecture

- **concord-core** - IR types and traversal
- **concord-codegen** - Code generation backends

## Links

- [GitHub](https://github.com/rhi-zone/concord)
- [Documentation](https://rhi.zone/concord/)
