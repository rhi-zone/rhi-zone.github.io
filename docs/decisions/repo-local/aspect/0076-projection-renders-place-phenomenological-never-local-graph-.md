# ADR-0076: Projection renders place (phenomenological), never a local graph view

- Status: Accepted
- Date: 2026-05-29

**Context.** The experiential view could be implemented as a zoomed-in subgraph centered on the current node (a localized version of the graph editor), which is the easy reuse of existing rendering. But inhabiting a world should not feel like reading a diagram.

**Decision.** Projection is phenomenological — it renders place, context, and possibility (exits, things here, actions), not topology. It is explicitly NOT a local graph view: no zoomed-in subgraph, no edges as lines, no cards as boxes. Edge-type-to-panel mapping comes from the world pack, not hardcoded. The graph editor (builder mode) remains the only place raw topology is shown.

**Alternatives rejected.**
- *Render the experiential view as a local/zoomed subgraph (nodes-and-edges diagram centered on current node)* — 'Projection is not a local graph view... That's the graph editor — builder mode, god-mode. Projection is the primary experience mode.' Showing topology in the experience mode defeats the goal of inhabiting rather than editing

**Consequences.** Two distinct view modes coexist as tabs (builder vs experience); experiential view must never show nodes/edges/arrows. Panel structure is derived from world-pack edge-type mappings, so new edge types produce new sections without code changes. Mined from: /home/me/git/exoplace/aspect/docs/design/projection.md (22), /home/me/git/exoplace/aspect/docs/design/architecture.md (89).
