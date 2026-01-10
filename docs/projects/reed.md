# Reed

Language translation layer—source code to IR to source code.

**Repository:** [github.com/rhizome-lab/reed](https://github.com/rhizome-lab/reed)

## Overview

Reed provides bidirectional translation between programming languages through a common intermediate representation. Instead of N×M converters between languages, Reed uses N readers and M writers with a shared IR.

## Crates

### Core

| Crate | Description |
|-------|-------------|
| `rhizome-reed-ir` | Common AST intermediate representation |
| `rhizome-reed-sexpr` | S-expression serialization for the IR |

### Readers

| Crate | Description |
|-------|-------------|
| `rhizome-reed-read-lua` | Lua source → Reed IR |
| `rhizome-reed-read-ts` | TypeScript source → Reed IR |

### Writers

| Crate | Description |
|-------|-------------|
| `rhizome-reed-write-lua` | Reed IR → Lua source |
| `rhizome-reed-write-ts` | Reed IR → TypeScript source |

## Architecture

```
Source A ──→ Reader A ──→ Reed IR ──→ Writer B ──→ Source B
```

The IR captures common programming constructs:
- Expressions (literals, binaries, calls, etc.)
- Statements (assignments, conditionals, loops)
- Functions and modules

This enables:
- **Language migration**: Convert legacy code to modern languages
- **Code generation**: Generate implementations in multiple targets
- **Cross-language tooling**: Build tools that work on the IR

## Usage

```rust
use rhizome_reed_read_lua::parse_lua;
use rhizome_reed_write_ts::write_ts;

// Parse Lua source
let ir = parse_lua("function add(a, b) return a + b end")?;

// Write as TypeScript
let ts_code = write_ts(&ir)?;
// "function add(a: any, b: any): any { return a + b; }"
```

## Integration with Spore

Reed powers verb execution in [Spore's Lotus integration](/projects/spore). Entity behaviors stored as S-expressions are translated to Lua at runtime:

```
S-expr (storage) → Reed IR → Lua (execution)
```

## Links

- [GitHub](https://github.com/rhizome-lab/reed)
- [Documentation](https://rhizome-lab.github.io/reed/)
