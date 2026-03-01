# Reincarnate

**Legacy software lifting framework in Rust.**

::: info Status: Fleshed Out ◐
1096 commits, 195 Rust files across multi-crate workspace. Active GameMaker and Flash lifting with TypeScript backend. IR-level transforms including type narrowing, const folding, and logical operator normalization. Real-world testing against production games (Dead Estate). Remaining work: additional runtime targets and format coverage.
:::

Reincarnate extracts and transforms applications from obsolete runtimes into modern web-based equivalents.

## Key features

- **Explant** - Bytecode extraction and decompilation for Flash, Director, VB6, and more
- **Hypha** - Game translation with UI overlay replacement
- **Multi-tier approach** - Native patching for hard targets, runtime replacement for scriptable engines

## Supported targets

- **Interactive Media** - Flash, Director/Shockwave, Authorware
- **Enterprise** - Visual Basic 6, Silverlight, Java Applets
- **No-Code Ancestors** - HyperCard, ToolBook
- **Game Engines** - RPG Maker, Ren'Py, GameMaker

## Philosophy

Reincarnate works on **bytecode and script**, not native binaries. The goal is accurate preservation, not improvement—make the old thing work as it was, in a modern runtime.

## Links

- [GitHub](https://github.com/rhi-zone/reincarnate)
- [Documentation](https://rhi.zone/reincarnate/)
