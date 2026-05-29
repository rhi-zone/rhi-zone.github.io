# ADR-0207: Defer to ecosystem consensus instead of wrapping solved domains

- Status: Accepted
- Date: 2026-05-29

**Context.** Portals could provide a consistent wrapper over every domain (serialization, CLI parsing, URL parsing, regex), but some domains already have ecosystem-standard crates.

**Decision.** For solved domains where ecosystem consensus exists (serde, clap, url, regex), do not wrap; just recommend using the standard crate directly. Portals only abstracts primitives and contested domains.

**Alternatives rejected.**
- *Create portals wrappers uniformly across all domains for API consistency* — Wrapping solved domains adds friction without benefit since users already know those APIs; consistency is valuable but not free.

**Consequences.** Portals's scope is bounded to primitives and contested domains; certain crates (serde, clap, url, regex) are explicitly out of scope. Future crate proposals must pass the 'is there ecosystem consensus?' test. Mined from: /home/me/git/rhizone/portals/DESIGN.md (95), /home/me/git/rhizone/portals/DESIGN.md (86).
