# Moss

**Structural code intelligence for humans and AI agents.**

Moss provides tools for understanding, navigating, and modifying code at a structural level (AST, control flow, dependencies) rather than treating code as text.

## Key Features

- **98 Languages** - Tree-sitter grammars for comprehensive language support
- **Structural Editing** - AST-based code modifications with fuzzy matching
- **Lua Workflows** - Scriptable automation with `auto{}` LLM driver
- **Background Indexing** - Daemon maintains symbol/call graph index
- **Shadow Git** - Hunk-level edit tracking in `.moss/.git`

## Three Primitives

| Command | Purpose | Example |
|---------|---------|---------|
| `view` | See structure | `moss view src/` `moss view MyClass` |
| `edit` | Modify code | `moss edit src/foo.rs/func --delete` |
| `analyze` | Compute metrics | `moss analyze --complexity` |

## Quick Start

```bash
git clone https://github.com/rhizome-lab/moss
cd moss
cargo build --release

# View a file's structure
moss view src/main.rs

# Analyze codebase health
moss analyze --health

# Search for a symbol
moss view SkeletonExtractor
```

## Links

- [GitHub](https://github.com/rhizome-lab/moss)
- [Documentation](https://rhizome-lab.github.io/moss/)
