# ADR-0092: No special-cased type kinds: well-known types are Refs to names, not enum variants

- Status: Accepted
- Date: 2026-05-29

**Context.** The IR needs unit/void, bottom/never, top/any, and primitive types (i32, f64). The design had to decide whether these are first-class TypeKind variants or expressed through the generic reference mechanism.

**Decision.** No special-cased type kinds. Well-known types (Unit, Never, Any, i32, f64, etc.) are expressed as Ref to well-known names, which generators map to target-language equivalents.

**Alternatives rejected.**
- *Dedicated TypeKind variants for special types (unit/never/any/primitives)* — Would add special cases to the core enum; using Ref to well-known names keeps the type system uniform and lets each generator decide the target mapping, consistent with the minimize-special-cases principle.

**Consequences.** All primitives and special types flow through the same Ref machinery; generators own the mapping table from well-known names to language types. There is no compile-time guarantee a Ref name is a recognized special type. Mined from: /home/me/git/rhizone/concord/docs/design/ir.md (137), /home/me/git/rhizone/concord/docs/design/ir.md (144).
