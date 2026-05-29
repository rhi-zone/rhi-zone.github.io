# ADR-0235: Standalone format crates expose no rescribe IR types

- Status: Accepted
- Date: 2026-05-29

**Context.** Format parsing/emitting could be built directly against rescribe's Document/Node/Properties types, coupling each format to the core library.

**Decision.** Standalone format crates (e.g. commonmark-fmt) must not reference rescribe types at all; Document/Node/Properties appear only in thin rescribe-read-{fmt}/rescribe-write-{fmt} adapter crates, ideally under 300 lines per side, with no rescribe-* dependencies in the format crate's Cargo.toml.

**Alternatives rejected.**
- *Build format crates directly against rescribe's Document/Node/Properties IR* — It would couple every format crate to the core IR, making the format crates non-reusable outside rescribe and entangling their public surface with rescribe's types.

**Consequences.** Format crates are independently usable libraries with their own AST/Event types; integration cost is isolated in capped (~300-line) adapter crates. Two-layer indirection for every format. Mined from: /home/me/git/rhizone/rescribe/docs/format-library-design.md (217-219).
