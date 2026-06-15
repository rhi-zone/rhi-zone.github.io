# ADR-0286: Scribble is a medium for authored content, not an authoring tool

- Status: Accepted
- Date: 2026-06-15

**Context.** Scribble had repeatedly been described as a "sketch-level creative environment / tool" — language that places it in the slot a *tool* occupies (the thing you make content *with*). That framing kept missing what scribble actually is. The load-bearing distinction, derived in conversation: scribble occupies the slot that **video and HTML occupy — the form content is published and consumed in**, not the slot a tool occupies. It is a *medium for authored content*, not an authoring tool. This distinction was missed every time scribble was called a "creative environment," and getting it wrong mis-positions the entire project against the wrong competitors.

The motivating case (kept verbatim, because it makes "medium" click): *Watching a GothamChess video in a dark room, the chessboard is uncomfortably bright. You can't dim just the board region, because a video is a baked raster — flat pixels, no structure, nothing addressable. The content was authored (someone made that board) but got flattened into the wrong medium to ship it. The board is no longer a "board," just a rectangle of luminance.* That frustration is the whole thesis in miniature: authored content collapsed into a medium that throws away its structure.

**Decision.** Position scribble as **the structured, live, editor=runtime medium — where liveness survives publication — delivered at video-level accessibility.** Two properties are constitutive:

1. **Liveness/structure survives publication.** Scribble's "editor and runtime are the same thing" is not a dev-time convenience; it means the *published* piece stays live, structured, addressable, and openable. The board would still be a board, to the audience — dimmable, inspectable, remixable.
2. **Accessibility is the load-bearing competitive axis.** The "sketch-level, low ceremony, think out loud" language is not vibe or incidental flavor — it *is* the differentiating thesis. Scribble aims to reach content-creator accessibility (video-level barrier-to-entry), not developer accessibility.

Lineage is PICO-8 / Scratch / Bitsy / shadertoy — remixable carts where source travels with the work — **not** Godot.

**Alternatives rejected** (the three real alternatives; accessibility is the discriminating axis throughout).

- *Video.* Video is the only medium available at content-creator barrier level, so creators use it and accept baked / dead / no-structure output. This is *why* the chess board was a recording in the first place — not because video suited it, but because video was the only accessible option. Video wins on accessibility and loses everything structural.
- *HTML.* HTML's "zero barrier" is real for *documents* and a mirage for *structured / interactive* content. The moment you want tilemaps, sprites, colliders, a game loop, or WebGPU-class performance, you fight the DOM or drop to `<canvas>` / wasm — and there you have thrown the authored structure away again (a baked blob inside a page). Structured-interactive HTML therefore carries a real dev barrier *and* re-introduces the baking problem one layer in. (Note: scribble does not reject HTML — its DOM runtime literally *is* HTML; scribble absorbs HTML as its document/UI tier. The rejection is of HTML for the tiers HTML is bad at.)
- *Godot.* Godot already collapses the "native/high-perf vs live-sketch" straddle — its editor *is* the engine, live and immediate. But Godot's liveness stops at the developer's machine: what it *ships* is a sealed export, and the audience gets a baked artifact they cannot open or edit. And Godot is gated behind genuine gamedev literacy (scene trees, GDScript, signals, nodes). The population that can ship a Godot project is tiny next to the population that makes *content*. Godot competes for *developers*, not *content creators*.

So scribble's derived identity sits where none of the three are: structured-liveness that survives publication (unlike Godot's sealed exports, unlike video's flattening), at video-level accessibility (unlike Godot's skill wall, unlike structured-HTML's dev barrier).

**Consequences.** This frames all of scribble's existing design — disjoint DOM / Canvas 2D / WebGPU runtimes (ADR-0147), editor=runtime, lazy-baked assets, append-only persistence — as serving *the published artifact's* liveness, not just the author's iteration loop. The "sketch-level / low ceremony" positioning is now explicitly the accessibility thesis and should be argued as such in docs, not presented as flavor.

**Open bet / named risk.** The accessibility/power frontier is where tools die. Scratch is accessible but cannot do "real" content; PICO-8 keeps power but is still code; most tools that reach content-creator accessibility get there by *sacrificing* structured power. Scribble's bet is to hold **both** — Godot-class structured-liveness at video-level barrier-to-entry. That frontier is the hard part. The open question is therefore **not** "does anyone want this" (clearly yes — the entire population that falls back to video), but: **can scribble actually deliver structured-liveness at content-creator accessibility, or does it slide off the frontier into "accessible but can't do much"?** This risk is unresolved and is the real thing the project is betting on.
