# ADR-0090: Extensible kind:String annotations instead of a fixed set of bounds/constraints/modifiers

- Status: Accepted
- Date: 2026-05-29

**Context.** The IR must carry bounds, constraints, modifiers, HTTP semantics, FFI calling conventions, variance, ownership, etc. The design had to decide whether these are a fixed, hardcoded enumeration or an open extensible mechanism.

**Decision.** Bounds, constraints, and modifiers are unified into a single extensible Annotation concept with kind: String and an optional value. There is no fixed set of primitives, bounds, constraints, or modifiers — everything uses extensible kind: String patterns. Generators handle known kinds and ignore/warn on unknown ones.

**Alternatives rejected.**
- *A fixed/hardcoded set of primitives, bounds, constraints, and modifiers (e.g. enum variants per concept)* — Would require core type changes whenever a new bound/constraint/modifier appears across surfaces; the open kind: String design lets new surfaces add semantics without modifying core types, at the cost of generators needing to tolerate unknown kinds.

**Consequences.** New annotation kinds can be introduced without changing the schema; generators must gracefully ignore/warn on unrecognized kinds. This pushes correctness to runtime — hence the still-open Validation layer question (when/how to validate annotation kinds and values). Mined from: /home/me/git/rhizone/concord/docs/design/ir.md (8), /home/me/git/rhizone/concord/docs/design/ir.md (38), /home/me/git/rhizone/concord/docs/design/ir.md (70).
