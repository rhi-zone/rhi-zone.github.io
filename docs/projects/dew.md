# Dew

**Minimal expression language for procedural generation.**

::: info Status: Potentially Mature ●
~51K lines of Rust across 8 crates. Production-ready core language with 4 domain crates (scalar, linalg, complex, quaternion) and 10 code generation backends (WGSL, GLSL, OpenCL, CUDA, HIP, Rust, C, TokenStream, Lua, Cranelift). Exhaustive tests, property-based testing, editor support. Web playground is the only incomplete UX piece.
:::

Dew is a domain-specific expression language designed for procedural generation workflows. Small, ephemeral, perfectly formed—like a droplet condensed from logic. Just dew it.

## Key Features

- **Multi-backend** - WGSL shaders, Cranelift JIT, or Lua interpreter
- **Math-focused** - Linear algebra primitives built-in
- **Composable** - Expressions compose into larger expressions
- **Embeddable** - Library-first design for integration into other tools

## Backends

| Backend | Use Case |
|---------|----------|
| WGSL | GPU shader evaluation for textures, particles |
| Cranelift | CPU JIT for fast evaluation |
| Lua | Scripting integration with habitat |

## Links

- [GitHub](https://github.com/rhi-zone/dew)
- [Documentation](https://rhi.zone/dew/)
