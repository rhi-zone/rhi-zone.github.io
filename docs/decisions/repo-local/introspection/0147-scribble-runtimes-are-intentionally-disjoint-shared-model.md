# ADR-0147: Scribble runtimes are intentionally disjoint, not a shared model

- Status: Accepted
- Date: 2026-05-29

**Context.** Designing Scribble, a sketch-level creative environment (games, art, notes) as a reincarnate-native frontend. The design had to decide whether its multiple rendering targets share one mental model or diverge.

**Decision.** Scribble is a reincarnate-native frontend with disjoint runtime implementations (DOM, Canvas 2D, WebGPU), each carrying its own stdlib primitives. The runtimes are intentionally different because different mediums need different primitives (tile-based games vs DOM note-taking).

**Alternatives rejected.**
- *Share a single mental model across runtimes (the SugarCube/Harlowe-for-Twine approach)* — Tile-based games need different primitives than DOM-based note-taking; forcing a shared model would not fit the divergent mediums, so the runtimes are kept intentionally different with separate stdlibs.

**Consequences.** Each Scribble runtime owns its primitives and stdlib; layer types (tilemaps with z-index/occlusion, sprites, UI, particles, colliders) and per-node-type renderers follow from this. The asset pipeline requires no processing step (lazy baking) and persistence is an append-only log. Constrains all future Scribble runtime work to per-runtime primitive sets rather than a unified abstraction. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-03-04.md (11).
