# ADR-0083: Supply-driven library: ship what is architecturally distinct, not what an example demands

- Status: Accepted
- Date: 2026-05-29

**Context.** When deciding whether to add a capability to the library, the natural pull is to add it because an example needs it. This decision rejects demand as the gating frame.

**Decision.** The library ships what is architecturally distinct and earns its keep, in dependency order. The decision rule: architecturally distinct + earns its keep -> primitive; reduces to composition -> pattern; doesn't recur enough to name -> PATTERNS.md recipe. Demand only enters when prioritizing within an already-justified queue.

**Alternatives rejected.**
- *Demand-driven: add a capability because an example needs it / defer until a use case appears* — 'Does an example need it?' is the wrong frame — examples exist to demonstrate primitives, not vice versa; 'deferred until a use case' is not valid library-internal reasoning because a thing that reduces to composition is permanently gone, not waiting.

**Consequences.** A candidate that reduces to existing primitives is permanently excluded as a primitive, not parked. Prioritization-by-demand is allowed only after architectural justification. Mined from: /home/me/git/pterror/chub-stage-factory/CLAUDE.md (19), /home/me/git/pterror/chub-stage-factory/CLAUDE.md (25).
