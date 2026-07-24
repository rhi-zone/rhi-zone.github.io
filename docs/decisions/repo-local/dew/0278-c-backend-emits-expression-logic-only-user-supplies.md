# ADR-0278: C backend emits expression logic only; user supplies type system and ops

- Status: Accepted
- Date: 2026-05-29

**Context.** The C backend had to decide whether to bundle a full C math type/function library (vec2, mat4, complex ops, etc.) or to assume the host project already provides them.

**Decision.** The C backend generates code that assumes external (user-provided) type definitions and function definitions, using only <math.h> for scalar functions. It provides expression logic; the user provides the type system.

**Alternatives rejected.**
- *Generate or bundle a complete C type system and math function library with the emitted code* — Rejected to support embedding into projects with existing math libraries (cglm, HandmadeMath, custom): 'The generated code is designed to be embedded in projects with existing math libraries ... It provides the expression logic while you provide the type system.'

**Consequences.** Generated C references vec2/mat4/complex_t/quat_t and vec2_dot/quat_slerp/etc. that the caller must define; only <math.h> scalar functions (sinf, powf, fmaxf...) are assumed available. Output is not standalone-compilable without user scaffolding. Mined from: /home/me/git/rhizone/wick/docs/backends/c.md (60), /home/me/git/rhizone/wick/docs/introduction.md (124).
