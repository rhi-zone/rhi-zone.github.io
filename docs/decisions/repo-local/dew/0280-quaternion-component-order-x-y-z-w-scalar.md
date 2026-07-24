# ADR-0280: Quaternion component order is [x, y, z, w] (scalar-last, GLM/glTF convention)

- Status: Accepted
- Date: 2026-05-29

**Context.** Quaternion storage order was genuinely undecided ('Decision needed: Component order convention') between the math-textbook scalar-first [w,x,y,z] and the graphics scalar-last [x,y,z,w].

**Decision.** Quaternions use [x, y, z, w] (scalar last), following the GLM/glTF convention.

**Alternatives rejected.**
- *[w, x, y, z] scalar-first (math-text convention)* — Lost to interoperability with graphics tooling: GLM and glTF use scalar-last [x,y,z,w], and dew's backends target graphics/GPU ecosystems (WGSL, glam, CUDA float4), so matching that convention avoids reordering at the boundary.

**Consequences.** All quaternion value layouts, backend emission (vec4/float4), and the C quat_t struct ({x,y,z,w}) honor scalar-last. conj is (w,-x,-y,-z) over this layout. Cross-backend parity tests must assume this order. Mined from: /home/me/git/rhizone/wick/docs/domain-crates-design.md (244), /home/me/git/rhizone/wick/docs/domain-crates-design.md (90).
