# Normalize

**Structural code intelligence for humans and AI agents.**

::: info Status: Fleshed Out ◐
~128K lines of Rust across 14 crates. Core functionality is solid with extensive language support (98 languages via tree-sitter), comprehensive CLI, and rich documentation. Remaining work is capability expansion (typegen input parsers, surface-syntax) rather than foundation building.
:::

Normalize provides tools for understanding, navigating, and modifying code at a structural level (AST, control flow, dependencies) rather than treating code as text.

## Key Features

- **98 Languages** - Tree-sitter grammars for comprehensive language support
- **Structural Editing** - AST-based code modifications with fuzzy matching
- **Background Indexing** - Daemon maintains symbol/call graph index
- **Shadow Git** - Hunk-level edit tracking in `.normalize/.git`
- **Session Analysis** - Parse and analyze AI agent logs (Claude Code, Gemini CLI, etc.)

## Three Primitives

| Command | Purpose | Example |
|---------|---------|---------|
| `view` | See structure | `normalize view src/` `normalize view MyClass` |
| `edit` | Modify code | `normalize edit src/foo.rs/func --delete` |
| `analyze` | Compute metrics | `normalize analyze --complexity` |

## Crates

### Core

| Crate | Description |
|-------|-------------|
| `normalize` | CLI binary and main library |
| `normalize-core` | Foundational traits (`Merge`, etc.) |
| `normalize-derive` | Procedural macros |

### Language Support

| Crate | Description |
|-------|-------------|
| `normalize-languages` | 98 languages via tree-sitter grammars |
| `normalize-surface-syntax` | Syntax translation between languages (TS ↔ Lua ↔ Python) |

### Code Analysis

| Crate | Description |
|-------|-------------|
| `normalize-rules` | Syntax-based linting with tree-sitter queries |
| `normalize-tools` | Unified interface for external tools (oxlint, ruff, prettier, etc.) |

### Type Generation

| Crate | Description |
|-------|-------------|
| `normalize-typegen` | Polyglot type/validator generation from schemas |
| `normalize-jsonschema` | JSON Schema codegen |
| `normalize-openapi` | OpenAPI client codegen |

### Package Management

| Crate | Description |
|-------|-------------|
| `normalize-packages` | Package registry queries for 12+ ecosystems |

### Agent Support

| Crate | Description |
|-------|-------------|
| `normalize-sessions` | Session log parsing (Claude Code, Gemini CLI, etc.) |
| `normalize-cli-parser` | Parse CLI `--help` output |

## Quick Start

```bash
git clone https://github.com/rhi-zone/normalize
cd normalize
cargo build --release

# View a file's structure
normalize view src/main.rs

# Analyze codebase health
normalize analyze --health

# Search for a symbol
normalize view SkeletonExtractor
```

## Relationship to Moonlet

Normalize focuses on **intelligence** (code analysis, session parsing, understanding) while [Moonlet](/projects/moonlet) handles **agency/execution** (LLM calls, memory, running agents). The projects are intentionally not hard-linked. Normalize can optionally extend Moonlet via a plugin architecture.

## Links

- [GitHub](https://github.com/rhi-zone/normalize)
- [Documentation](https://rhi.zone/normalize/)
