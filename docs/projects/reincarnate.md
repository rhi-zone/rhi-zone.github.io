# Reincarnate

**Legacy software lifting framework in Rust.**

::: info Status: Fleshed Out ◐
~2000 commits, 192 Rust files across a multi-crate workspace (core IR + CLI, three frontends, a TypeScript backend, a TS type-checker, and the GameMaker data.win parser). Active lifting for Flash (AVM2), GameMaker (GMS1/GMS2), and Twine (SugarCube + Harlowe), emitting compiled TypeScript over per-engine replacement runtimes. IR-level transform passes including type inference/narrowing, mem2reg, coroutine lowering, and const folding. Validated against production games (e.g. Dead Estate). Remaining work: additional frontends and format coverage.
:::

Reincarnate extracts application logic from obsolete bytecode/script runtimes and re-emits it as modern web code. It decompiles to an SSA-like intermediate representation, runs transform passes, then emits compiled TypeScript alongside a swappable replacement runtime — not an interpreter bundle. The original runtime is fully replaced.

## Pipeline

**Frontend** (extract + decompile, source-aware) → **IR** (SSA-like, block arguments) → **Transform passes** (declarative requires/invalidates ordering) → **Backend** (emit target code, target-aware). Frontend and backend are strictly isolated: a frontend never knows the target language, a backend never knows the source engine.

## Implemented today

| Stage | Targets | Status |
|-------|---------|--------|
| Frontend | Flash (AVM2 / ABC bytecode) | Active |
| Frontend | GameMaker (GMS1/GMS2, data.win) | Active |
| Frontend | Twine (SugarCube + Harlowe) | Active |
| Backend | TypeScript | Active |
| Runtimes | flash / gamemaker / twine (TS, swappable platform layer) | Active |

## Planned

Director/Shockwave, Visual Basic 6, Silverlight, Java applets, HyperCard/ToolBook, RPG Maker, Ren'Py, WolfRPG, SRPG Studio, Inform 7, Ink, RAGS, QSP, PuzzleScript. (See the repo README's target table for format/status detail.)

## Crates

| Crate | Description |
|-------|-------------|
| `reincarnate-core` | Core IR, transform pipeline, type inference |
| `reincarnate-cli` | CLI binary (extract / emit / print-ir / info) |
| `reincarnate-frontend-flash` | Flash/SWF frontend (ABC bytecode) |
| `reincarnate-frontend-gamemaker` | GameMaker frontend (GMS1/GMS2) |
| `reincarnate-frontend-twine` | Twine frontend (SugarCube + Harlowe) |
| `reincarnate-backend-typescript` | TypeScript code emitter |
| `reincarnate-checker-typescript` | Emitted-TypeScript type checker |
| `datawin` | GameMaker data.win format parser |

## Philosophy

Reincarnate works on **bytecode and script**, not native binaries. The goal is accurate preservation, not improvement—make the old thing work as it was, in a modern runtime.

## Links

- [GitHub](https://github.com/rhi-zone/reincarnate)
- [Documentation](https://rhi.zone/reincarnate/)
