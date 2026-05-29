# ADR-0284: Expressions are type-homogeneous; convert at boundaries only

- Status: Accepted
- Date: 2026-05-29

**Context.** Value<T> is generic over T: Float (f32, f64). The design had to decide whether a single expression could mix numeric types or must be uniform.

**Decision.** An expression is homogeneous in T. Literals (parsed as f32) are converted to T via T::from(f32); no mixed types are allowed within an expression. The caller handles input/output conversion at the boundary.

**Alternatives rejected.**
- *Allow mixed numeric types within a single expression (per-node type coercion)* — Rejected in favor of 'convert at boundaries' simplicity: the expression stays homogeneous and the caller handles conversion, avoiding per-node coercion rules. The doc states 'No mixed types within an expression.'

**Consequences.** Eval and codegen treat the whole expression as one numeric type T; conversion logic lives only at variable input and result output. Simplifies dispatch but forbids intra-expression precision mixing. Mined from: /home/me/git/rhizone/wick/docs/linalg-design.md (85), /home/me/git/rhizone/wick/docs/linalg-design.md (86).
