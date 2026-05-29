# ADR-0216: Hybrid layout: hand-placed structural anchors plus globally-aware algorithmic placement

- Status: Accepted
- Date: 2026-05-29

**Context.** The original ring layout did not scale: a ring of N nodes has radius proportional to N, so at ~46 essays the ring either overlapped neighboring clusters or grew so large it dominated the layout. Content keeps growing, and the layout itself is treated as an argument about how things relate, so placement could not be left fully to an algorithm.

**Decision.** Use hybrid placement: hand-place anchors for things that matter structurally (ecosystem regions, key nodes that define the graph's shape) because those positions carry meaning, and use algorithmic layout for everything else to handle density, collision, and growth. The algorithm must be globally space-aware (know the total space budget before placing anything), not compute cluster radii independently and then place them.

**Alternatives rejected.**
- *Pure ring layout* — A ring is a 1D structure forced into 2D space; radius grows with N, so it either overlaps neighbors or dominates the layout as content grows — a fundamental mismatch that doesn't scale.
- *Fully algorithmic / force-directed layout for all nodes* — Placement is the argument about how things relate; structurally meaningful positions (regions, anchors) must be deliberate, so they cannot be surrendered to the algorithm.
- *Compute each cluster's radius independently then place clusters* — Not globally space-aware — it produces overlaps and territory violations; the algorithm needs the total space budget before placing anything.

**Consequences.** The layout engine is split into hand-placed structural anchors and a content-driven, globally-space-aware algorithmic pass. Remaining hardcoded values (essay cluster center, orphan positions, region hues, meta-vs-idea classification) are accepted as stepping stones toward fully content-derived placement. Open: viewport-size assumptions and dynamic runtime adaptation remain unresolved. Mined from: /home/me/git/pteraworld/LAYOUT.md (33), /home/me/git/pteraworld/LAYOUT.md (41), /home/me/git/pteraworld/LAYOUT.md (45).
