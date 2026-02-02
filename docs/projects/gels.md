# Gels

**Trait-based grammar inference engine targeting tree-sitter output.**

::: info Status: Sketch ○
Initial crate structure with type definitions and trait interfaces. No detection or synthesis logic yet.
:::

Gels detects syntactic traits from example source files, identifies known languages, or synthesizes tree-sitter grammars for unknown ones.

## Key ideas

- **Trait-based detection** — Syntactic features (brace-delimited, semicolon-terminated, pattern matching, etc.) are independent detectors
- **Grammar synthesis** — Detected traits contribute grammar fragments that merge into a complete tree-sitter grammar
- **Language identification** — Match trait vectors against known language profiles

## Pipeline

```
examples → tokenize → detect traits → identify or synthesize → tree-sitter grammar
```

## Crates

| Crate | Description |
|-------|-------------|
| `gels` | CLI binary and public library API |
| `gels-core` | Token types, SyntaxTrait trait, grammar IR, language profiles |
| `gels-traits` | Language-agnostic tokenizer, built-in trait detectors, known language registry |
| `gels-synth` | Grammar fragment merging and tree-sitter grammar.js emission |

## CLI

```bash
gels analyze <dir>              # detect traits, identify or synthesize grammar
gels identify <dir>             # identify the language
gels emit <dir> -o grammar.js   # output tree-sitter grammar
```

## Links

- [GitHub](https://github.com/rhi-zone/gels)
