# ADR-0253: Kind is asserted via instance_of, not a per-record schema type

- Status: Accepted
- Date: 2026-05-29

**Context.** Programs, languages, formats, orgs, people, classes and versions all share one record shape. Something must encode an entity's kind without forking the schema per type.

**Decision.** An entity's kind is asserted by an `instance_of` statement, not by a per-record `type` field or per-type schema. Classes (clades) are entities with `instance_of @meta:class`; programs are `instance_of @class:<class>`; everything else is typed by its own instance_of. The cladistic classification is a query over `subclass_of`, not a schema.

**Alternatives rejected.**
- *A per-record schema type field / distinct schemas per entity kind* — Would re-introduce a fixed type taxonomy in the schema; kind-as-statement keeps one record shape and makes classification a query, fitting the cladistics-over-Linnaean-ranks premise
- *A fixed taxonomy hierarchy as the primary artifact (the Phase 0 scaffold)* — Superseded: the graph model is primary and taxonomy is a derived view (transitive closure of subclass_of), because software has no fixed Linnaean ranks

**Consequences.** All entities use one file/record shape. Taxonomy renders via `bun run tree` as a subclass_of closure. Adding a kind means adding a class entity, not a schema. Reinforces the no-blessed-metadata substrate but as a concrete instance_of mechanic. Mined from: /home/me/git/pterror/software-taxonomy/README.md (46), /home/me/git/pterror/software-taxonomy/README.md (5).
