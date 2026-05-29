# ADR-0187: Wrap git, not a custom sync protocol

- Status: Accepted
- Date: 2026-05-29

**Context.** Collaborative worldbuilding platforms (SCP, Orion's Arm) put the world on a central platform; when the platform dies the world dies and contributors do not own what they made. noncanon needed a collaboration substrate where divergence between parallel canons is first-class rather than a failure to be reconciled.

**Decision.** Build noncanon as a Rust library that wraps git (probably gitoxide) to expose canon-aware operations, rather than designing a bespoke synchronization protocol. Git is chosen specifically because divergence is already a first-class concept in it.

**Alternatives rejected.**
- *A custom sync protocol designed for worldbuilding* — git already makes divergence a first-class concept (two people can hold genuinely different canons sharing a base and diverging elsewhere, neither wrong); a custom protocol would have to re-earn that property the design depends on.

**Consequences.** noncanon is permanently coupled to git semantics (addressing, referencing, pulling, diverging map onto git). Addressing is handled via standard git remotes. The backend is gitoxide. Conflict-resolution UIs and merge policy are explicitly out of scope. Mined from: /home/me/git/exoplace/noncanon/CLAUDE.md (15), /home/me/git/exoplace/noncanon/CLAUDE.md (22).
