# ADR-0285: No separate type-inference pass; types propagate during eval/emit in a single pass

- Status: Accepted
- Date: 2026-05-29

**Context.** Domain crates need types both at evaluation and at codegen. The design had to decide whether to run a standalone type-inference/checking pass over the AST or fold typing into the eval/emit walk.

**Decision.** There is no separate type inference pass. Types propagate during eval/emit. For evaluation, operators dispatch on runtime value types; for backends, a single pass walks the AST propagating types bottom-up and returns a (code, type) tuple.

**Alternatives rejected.**
- *A separate standalone type-checking/inference pass over the AST before eval/emit* — Rejected as unnecessary: variable types are supplied by the caller (HashMap<String,Value> or HashMap<String,Type>) and types can propagate bottom-up in the same walk, so a dedicated pass would be redundant. The doc states 'No separate type inference pass. Types propagate during eval/emit.'

**Consequences.** Backend emit functions return (String, Type) tuples and infer result types inline (e.g. mat3*vec3 -> Vec3). Type errors surface during eval/emit rather than a prior validation stage. Open question remains whether type checking should later be factored into a shared wick-types crate. Mined from: /home/me/git/rhizone/wick/docs/linalg-design.md (53), /home/me/git/rhizone/wick/docs/linalg-design.md (66).
