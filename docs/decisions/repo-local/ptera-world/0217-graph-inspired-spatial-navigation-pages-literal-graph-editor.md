# ADR-0217: Graph-inspired spatial navigation, not pages and not a literal graph editor

- Status: Accepted
- Date: 2026-05-29

**Context.** A personal website needed a navigation model. Traditional portfolio sites are lists of pages; graph editors are powerful but expensive to onboard. The site had to express projects/ideas/ecosystems with relationships as first-class, while keeping interaction trivial.

**Decision.** Adopt a graph-inspired spatial canvas positioned between a page list and a graph editor: nodes have presence and tiered detail (far=regions, mid=projects, near=detail), proximity implies relationship, and interaction is restricted to point-and-zoom. The site is explicitly 'not pages, not a literal graph editor.'

**Alternatives rejected.**
- *Traditional portfolio site (lists of pages)* — Lists of pages make connections footnotes rather than first-class; you cannot enter from anywhere and follow your own path, and the spatial sense of the whole is lost.
- *Full graph editor* — Graph editors are powerful but have high onboarding cost; the site wanted nodes with presence and hierarchy without that interaction burden.

**Consequences.** Navigation is point-and-zoom over a spatial field; layout is dynamic and projection-based (a node's neighbors change with the approach axis). This forecloses static page layout and constrains all downstream interaction design (WASD pan, arrow-key traversal, command palette, minimap) to operate over a zoomable spatial canvas. Mined from: /home/me/git/pteraworld/README.md (3), /home/me/git/pteraworld/README.md (14).
