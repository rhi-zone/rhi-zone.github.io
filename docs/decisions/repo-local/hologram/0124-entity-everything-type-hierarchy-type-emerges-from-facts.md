# ADR-0124: Entity-everything: no type hierarchy, type emerges from facts

- Status: Accepted
- Date: 2026-05-29

**Context.** A worldbuilding system must represent characters, locations, items, and concepts. A schema-based type hierarchy was the obvious design, but it requires predicting in advance which distinctions will matter and struggles with hybrids (a sentient sword) or mutable types (a ship as a movable location).

**Decision.** There is no distinct character/location/item type. Everything is an entity with attached freeform facts; the 'type' emerges from its facts rather than from a schema.

**Alternatives rejected.**
- *Rigid type/schema hierarchy (distinct character/location/item types)* — requires predicting what distinctions will matter; creates friction and fails on hybrid or mutable cases; freeform facts with emergent conventions scale better for collaborative worldbuilding

**Consequences.** All features (including help) are built on entities; no schema migrations for new kinds of things; conventions emerge per-community. Edge cases like sentient-sword or moving-location are handled by adding facts. Mined from: /home/me/git/exoplace/hologram/docs/design/decisions.md (33), /home/me/git/exoplace/hologram/docs/philosophy.md (7).
