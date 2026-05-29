# ADR-0215: Default zoom is a deliberate landscape view; zoom is not the answer to overcrowding

- Status: Accepted
- Date: 2026-05-29

**Context.** With many nodes, the naive instinct is to let users zoom out until everything fits or zoom in to find things. The team had to decide what is visible at default zoom and how labels surface across zoom levels.

**Decision.** Treat the default (far) view as a deliberately curated landscape: show prominent nodes/regions with full titles and collapse dense clusters to clickable dots, exposing 'enough threads to pull on' rather than everything. Explicitly reject zoom as a fix for overcrowding — labels surface in tiers (far=landscape, mid=short labels on focus, near=full titles), and not every node need be exposed for the structure to be navigable.

**Alternatives rejected.**
- *Zoom out until everything fits* — Seeing everything at once means seeing nothing; it produces semantic inundation.
- *Show everything / rely on zooming in to find things* — Zooming in to find things loses the landscape; the default view must be a design decision, not an emergent consequence of fit.

**Consequences.** Label visibility is tiered by zoom and by focus context (dots get edge-relative names only when a neighbor is focused; expanded/permanent nodes always show full titles). Establishes that 'no screen size fits everything at default zoom' is expected and acceptable, shaping all label and tier logic. Mined from: /home/me/git/pteraworld/LAYOUT.md (21), /home/me/git/pteraworld/LAYOUT.md (15).
