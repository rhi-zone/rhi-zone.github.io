# ADR-0139: All graph edges are directed; A→B and B→A are distinct

- Status: Accepted
- Date: 2026-05-29

**Context.** Ptera's spatial portfolio/graph rendering needed a definitive edge model as bidirectional edge support, multi-select, and direction-aware unlinking were being built. The team had to decide whether edges could be undirected.

**Decision.** All edges are directed. A→B and B→A are distinct edges that can coexist. There are no undirected edges; bidirectionality is represented as two distinct directed edges.

**Alternatives rejected.**
- *Undirected edges (a single edge with no direction)* — Rejected in favor of all-directed representation so that direction-aware unlinking and distinct A→B / B→A semantics are possible; an undirected model cannot express the two coexisting directions.

**Consequences.** Edge-consuming code (rendering, unlinking, multi-select) must treat each direction independently. Bidirectional appearance is achieved by creating both directed edges. No undirected primitive exists to fall back on. Mined from: /home/me/git/rhizone/github-io/docs/introspection/log/daily/2026-01-29.md (69).
