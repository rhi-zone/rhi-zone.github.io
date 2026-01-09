# Sap

**Expression language for procedural generation.**

Sap is a domain-specific expression language designed for procedural generation workflows. It compiles to multiple backends for flexible evaluation across GPU and CPU.

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
| Lua | Scripting integration with Lotus |

## Links

- [GitHub](https://github.com/rhizome-lab/sap)
- [Documentation](https://rhizome-lab.github.io/sap/)
