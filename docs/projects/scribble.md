# Scribble

**Sketch-level creative environment for games, art, and interactive pieces.**

::: info Status: Idea ○
No code yet—project just scaffolded.
:::

Scribble is a creative environment where the boundary between making and playing dissolves. Draw a 9-patch inside the running game and see it update live. The editor and the runtime are the same thing.

It targets the sketch level: low ceremony, fast iteration, always in a running state. Not a serious production tool—a place to think out loud.

## What it makes

Scribble doesn't distinguish between a game, a generative artwork, an interactive piece, or a notes app. These are the same kind of thing: small, contained, alive. You pick the right runtime for what you're making:

- **DOM runtime** — notes, UI-heavy apps, text. CSS `border-image` gives you hand-drawn 9-patch for free.
- **Canvas 2D runtime** — mid-tier creative work, simple games.
- **WebGPU runtime** — high-performance scenes, hundreds of entities, VS-like games.

Each runtime has its own primitives optimized for its domain. No unified abstraction tax.

## Architecture

Scribble is built on [reincarnate](/projects/reincarnate)'s platform layer — the same three-tier architecture (engine-agnostic platform interface → per-target implementations) that lifts legacy Flash and GameMaker games. Scribble's runtimes are new creative stdlibs on top, analogous to SugarCube and Harlowe on top of Twine.

Desktop targets reincarnate's native backends (wgpu, cpal, winit) directly — no webview, no embedded JS runtime, no overhead.

## Prior art

- [PICO-8](https://www.lexaloffle.com/pico-8.php) — fantasy console, fully integrated, editor and runtime as one
- [PuzzleScript](https://www.puzzlescript.net/) — radically minimal, browser-native, one domain done completely
- [Sokpop Collective](https://sokpop.itch.io/) — lo-fi, small, weird, fast. Sketch aesthetic as practice
- [RPG in a Box](https://www.rpginabox.com/) — integrated tooling, make everything inside the tool
- [Blockbench](https://www.blockbench.net/) — specialized but complete, browser + native

## Links

- [GitHub](https://github.com/rhi-zone/scribble)
- [Documentation](https://docs.rhi.zone/scribble/)
