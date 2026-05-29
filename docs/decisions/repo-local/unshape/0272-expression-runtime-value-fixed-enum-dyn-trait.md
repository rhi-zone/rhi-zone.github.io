# ADR-0272: Expression runtime Value is a fixed enum, not dyn Trait

- Status: Accepted
- Date: 2026-05-29

**Context.** Expression evaluation needs a runtime value representation. The set of expression primitives (floats, ints, bool, vectors, matrices) is fixed and finite, unlike graph Value which wraps open-ended domain types like Mesh and Image.

**Decision.** Represent expression runtime values as a fixed enum (F32/F64/I32/Bool, plus feature-gated vector/matrix variants) rather than dyn Trait, because the primitive set is closed.

**Alternatives rejected.**
- *dyn Trait values* — Requires a Box (heap allocation) per value, needs runtime checks instead of compiler-enforced exhaustiveness, and serialization is complex with virtual-dispatch performance cost; the open extensibility it offers is unneeded for a fixed primitive set

**Consequences.** Values are stack-allocated, copy-able, trivially serializable, and matched exhaustively at compile time. The primitive set is closed (extending it means editing the enum). Vector/matrix support is feature-gated (default = vectors; matrices implies vectors). Mined from: /home/me/git/rhizone/unshape/docs/design/expression-language.md (391), /home/me/git/rhizone/unshape/docs/design/expression-language.md (444).
