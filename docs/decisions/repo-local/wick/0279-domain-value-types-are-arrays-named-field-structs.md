# ADR-0279: Domain value types are arrays, not named-field structs

- Status: Accepted
- Date: 2026-05-29

**Context.** Complex/quaternion/dual values could be modeled as named-field structs (e.g. struct Complex { re, im }) or as fixed-size arrays ([T; N]). The doc showed both options explicitly.

**Decision.** Use the array form ([T; 2], [T; 4], etc.) for value types, for consistency with linalg's array-based value representation.

**Alternatives rejected.**
- *Named-field structs (e.g. pub struct Complex<T> { pub re: T, pub im: T })* — Lost to consistency with the existing linalg value model, which already uses fixed-size arrays; uniform array representation keeps the cross-domain value handling and backend flattening uniform.

**Consequences.** Complex is [re,im], quaternion is [x,y,z,w], dual is [val,deriv]. Backends flatten/index by position; field access (re/im, val/deriv) is by convention on array slots rather than named fields. Mined from: /home/me/git/rhizone/wick/docs/domain-crates-design.md (245).
