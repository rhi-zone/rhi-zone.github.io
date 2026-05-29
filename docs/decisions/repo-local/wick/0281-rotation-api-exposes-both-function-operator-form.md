# ADR-0281: Rotation API exposes both a function and an operator form

- Status: Accepted
- Date: 2026-05-29

**Context.** For rotating a vector by a complex number / quaternion, the design weighed an explicit function (rotate(v, q)) against an operator overload (q * v) — 'clearer intent' vs 'more magical.'

**Decision.** Provide both: a rotate(vec, quat) function AND a quat * vec operator.

**Alternatives rejected.**
- *Pick only one form (function-only for clarity, or operator-only for brevity)* — A single form was rejected: function-only loses ergonomic operator syntax, operator-only is 'more magical' and obscures intent. Offering both satisfies clarity and ergonomics rather than forcing the tradeoff.

**Consequences.** Each backend must emit both the named rotate function and the operator-overload form, and keep their semantics identical across backends. Doubles the surface that parity tests must cover for rotation. Mined from: /home/me/git/rhizone/wick/docs/domain-crates-design.md (246).
