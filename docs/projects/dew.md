# Dew

**Minimal expression language for procedural generation.**

::: info Status: Potentially Mature ●
~51K lines of Rust across 8 crates. Production-ready core language with 4 domain crates (scalar, linalg, complex, quaternion) and 10 code generation backends (WGSL, GLSL, OpenCL, CUDA, HIP, Rust, C, TokenStream, Lua, Cranelift). Exhaustive tests, property-based testing, editor support. Web playground is the only incomplete UX piece.
:::

Dew is a domain-specific expression language designed for procedural generation workflows. Small, ephemeral, perfectly formed—like a droplet condensed from logic. Just dew it.

## Key features

- **Multi-backend** - 10 code generation targets from one expression
- **Math-focused** - Scalar, linear algebra, complex, quaternion domains
- **Composable** - Expressions compose into larger expressions
- **Extensible** - Custom functions via FunctionRegistry, generic over numeric types
- **Embeddable** - Library-first design for integration into other tools

## Domain libraries

| Crate | Description |
|-------|-------------|
| `dew-core` | Core AST and parsing |
| `dew-scalar` | Scalar math (sin, cos, lerp, smoothstep, etc.) |
| `dew-linalg` | Linear algebra (Vec2-4, Mat2-4, dot, cross, normalize) |
| `dew-complex` | Complex numbers (exp, log, polar, conjugate) |
| `dew-quaternion` | Quaternions (slerp, axis-angle, rotate) |
| `dew-cond` | Conditional backend helpers |
| `dew-all` | Unified value type for domain composition |

## Backends

| Backend | Use Case |
|---------|----------|
| WGSL | GPU shaders (WebGPU) |
| GLSL | GPU shaders (OpenGL/Vulkan) |
| OpenCL | GPU compute (cross-platform) |
| CUDA | GPU compute (NVIDIA) |
| HIP | GPU compute (AMD ROCm) |
| Cranelift | Native JIT compilation |
| Rust | Rust source code generation |
| C | C source code generation |
| TokenStream | Rust proc-macro codegen |
| Lua | Scripting and hot-reload |

## Related projects

- [Unshape](/projects/unshape) - Procedural media generation using Dew expressions

## Links

- [GitHub](https://github.com/rhi-zone/dew)
- [Documentation](https://rhi.zone/dew/)
