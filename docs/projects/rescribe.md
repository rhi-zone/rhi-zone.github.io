# rescribe

**Lossless document conversion library.**

::: info Status: Fleshed Out ◐
~62K lines of Rust across 124 crates: 1 core IR, 54 readers, 64 writers, 2 node type crates, CLI, and transforms. Massive format surface area with solid architecture (open IR, extensible node kinds, fidelity tracking). Currently in quality audit phase—breadth is there, depth/hardening ongoing.
:::

rescribe is a universal document conversion library inspired by Pandoc, but focused on lossless round-trip fidelity through a rich intermediate representation. Preserves document semantics across ~50 formats.

## Key Features

- **Lossless IR** - Rich intermediate representation preserves formatting and structure
- **Round-trip fidelity** - Convert back and forth without information loss
- **Format support** - Office formats (DOCX, XLSX, PPTX), markup (Markdown, HTML), and more
- **Library-first** - Designed for integration into pipelines and tools

## Use Cases

- Document format migration without data loss
- Content extraction from legacy formats
- Pipeline integration for document workflows
- Format normalization for analysis

## Links

- [GitHub](https://github.com/rhi-zone/rescribe)
