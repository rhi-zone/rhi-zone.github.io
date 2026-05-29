# ADR-0056: Reimplement unshape's patterns independently — no shared crate, no coupling

- Status: Accepted
- Date: 2026-05-29

**Context.** Unshape is prior art for registry-based type erasure and serializable ops, raising the question of whether nanites should extract or depend on shared code.

**Decision.** Nanites studies unshape's design as prior art and reimplements relevant patterns independently — no shared crate, no dependency in either direction. If shared code is ever warranted it must be a third crate both depend on, not one depending on the other.

**Alternatives rejected.**
- *Extract a shared crate or have one depend on the other* — The primitives are fundamentally incompatible — unshape is synchronous (60fps media loop), nanites is async (seconds per LLM call). Extraction forces one to carry the other's baggage; the right time for shared abstraction is after both discover their real shapes.

**Consequences.** Nanites and unshape stay decoupled at the dependency graph level; design patterns may be copied but code is not shared, preserving independent publishing of both crates. Mined from: /home/me/git/rhizone/nanites/docs/design/decisions.md (109), /home/me/git/rhizone/nanites/docs/design/decisions.md (111), /home/me/git/rhizone/nanites/docs/design/decisions.md (113).
