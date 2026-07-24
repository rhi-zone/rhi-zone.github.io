# ADR-0282: Aggregate value types instead of decomposing vectors into scalar exprs

- Status: Accepted
- Date: 2026-05-29

**Context.** A vector/matrix expression could be represented either as a single typed value (Vec3) or decomposed into N independent scalar sub-expressions. The codegen and eval model depends on this choice.

**Decision.** Domain values are kept as aggregate typed values (Vec2/Vec3/Vec4/Mat2/Mat3/Mat4), not decomposed into per-component scalar Exprs.

**Alternatives rejected.**
- *Component-wise decomposition (Vec3 = 3 scalar Exprs)* — Loses semantic information (can't emit dot(a,b) in WGSL), loses hardware acceleration (SIMD/GPU vector ops), produces insane function signatures (mat4*vec4 = 20 scalar args), and breaks operator overloading where * means different things per type.

**Consequences.** Backends can emit native vector ops and intrinsics; type inference operates on aggregate types. The value enum carries fixed-size arrays per type. Function dispatch must resolve typed operations rather than scalar arithmetic. Mined from: /home/me/git/rhizone/wick/docs/linalg-design.md (22), /home/me/git/rhizone/wick/docs/linalg-design.md (24).
