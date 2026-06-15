# Scribble

**A medium for authored content — structured, live, editor=runtime — at video-level accessibility.**

::: info Status: Idea ○
No code yet—project just scaffolded.
:::

Scribble is not an authoring *tool*. It is a *medium* — it occupies the slot that video and HTML occupy: the form content is published and consumed in, not the thing you make content with.

The thesis, in one frustration: watching a GothamChess video in a dark room, the chessboard is uncomfortably bright. You can't dim just the board, because a video is a baked raster — flat pixels, no structure, nothing addressable. Someone *authored* that board, then flattened it into the wrong medium to ship it. It's no longer a "board," just a rectangle of luminance. That is what every medium at content-creator reach does today: it throws away the structure of the thing being published.

Scribble's wager is that the structure survives publication. Its editor and runtime are the same thing — not as a dev-time convenience, but because the *published* piece stays live, structured, addressable, openable. In a scribble piece, the board would still be a board, to the audience: dimmable, inspectable, remixable.

## Why a new medium (the accessibility thesis)

The three media that already exist each fail on one axis. Accessibility — how low the barrier is to *ship* something — is the load-bearing one.

- **Video** is the only medium available at content-creator barrier level. So creators use it and accept baked, dead, structureless output. (That's *why* the chess board was a recording in the first place — not because video suited it, but because video was the only accessible option.)
- **HTML**'s "zero barrier" is real for documents and a mirage for structured/interactive content. The moment you want tilemaps, sprites, colliders, a game loop, or WebGPU-class performance, you fight the DOM or drop to `<canvas>`/wasm — and there you've thrown the authored structure away again, a baked blob inside a page. (Scribble doesn't reject HTML; its DOM runtime literally *is* HTML. Scribble absorbs HTML as its document/UI tier — the point is the tiers HTML is bad at.)
- **Godot** already collapses native-perf-vs-live-sketch — its editor *is* the engine. But its liveness stops at the developer's machine: it ships a sealed export the audience can't open. And it's gated behind real gamedev literacy (scene trees, GDScript, signals, nodes). Godot competes for *developers*, not content creators.

Scribble sits where none of them do: structured-liveness that survives publication (unlike Godot's sealed exports, unlike video's flattening), delivered at video-level accessibility (unlike Godot's skill wall, unlike structured-HTML's dev barrier). Its lineage is PICO-8, Scratch, Bitsy, shadertoy — remixable carts where the source travels with the work — not Godot.

This is why "sketch-level, low ceremony, think out loud" is not flavor. Low ceremony *is* the differentiating thesis: scribble targets content-creator accessibility, and that bet is the whole project. (See [ADR-0286](/decisions/repo-local/introspection/0286-scribble-is-a-medium-for-authored-content-not-a-tool).)

## What it makes

Scribble doesn't distinguish between a game, a generative artwork, an interactive piece, or a notes app. These are the same kind of thing: small, contained, alive. You pick the right runtime for what you're making:

- **DOM runtime** — notes, UI-heavy apps, text. CSS `border-image` gives you hand-drawn 9-patch for free.
- **Canvas 2D runtime** — mid-tier creative work, simple games.
- **WebGPU runtime** — high-performance scenes, hundreds of entities, VS-like games.

Each runtime has its own primitives optimized for its domain. No unified abstraction tax. ([ADR-0147](/decisions/repo-local/introspection/0147-scribble-runtimes-are-intentionally-disjoint-shared-model) — the runtimes are intentionally disjoint.)

## Architecture

Scribble is built on [reincarnate](/projects/reincarnate)'s platform layer — the same three-tier architecture (engine-agnostic platform interface → per-target implementations) that lifts legacy Flash and GameMaker games. Scribble's runtimes are new creative stdlibs on top, analogous to SugarCube and Harlowe on top of Twine.

Desktop targets reincarnate's native backends (wgpu, cpal, winit) directly — no webview, no embedded JS runtime, no overhead.

## The open bet

The accessibility/power frontier is where tools die. Scratch is accessible but can't do "real" content; PICO-8 keeps power but is still code; most tools that reach content-creator accessibility get there by *sacrificing* structured power. Scribble's bet is to hold both — Godot-class structured-liveness at video-level barrier-to-entry. The open question is not "does anyone want this" (clearly yes — the entire population that falls back to video) but **whether scribble can actually deliver structured-liveness at content-creator accessibility, or slides off the frontier into "accessible but can't do much."** That's the hard part, and it's unresolved.

## Prior art

- [PICO-8](https://www.lexaloffle.com/pico-8.php) — fantasy console, fully integrated, editor and runtime as one
- [PuzzleScript](https://www.puzzlescript.net/) — radically minimal, browser-native, one domain done completely
- [Sokpop Collective](https://sokpop.itch.io/) — lo-fi, small, weird, fast. Sketch aesthetic as practice
- [RPG in a Box](https://www.rpginabox.com/) — integrated tooling, make everything inside the tool
- [Blockbench](https://www.blockbench.net/) — specialized but complete, browser + native

## Links

- [GitHub](https://github.com/rhi-zone/scribble)
- [Documentation](https://docs.rhi.zone/scribble/)
