# ADR-0270: glam for math types; no bevy dependency in core

- Status: Accepted
- Date: 2026-05-29

**Context.** The engine needs vector/matrix math types (Vec2, Vec3, Quat, Mat4) used pervasively across all domain crates, and wants to interoperate with the bevy game engine without conversion churn.

**Decision.** Use glam for all math types because bevy uses glam internally (zero-conversion interop), it is pure Rust (easy cross-compilation), SIMD-optimized, and minimal. Do not put a bevy dependency in core; bevy conversions live in optional feature flags or adapter crates.

**Alternatives rejected.**
- *nalgebra* — More features but heavier, and a different API than bevy
- *ultraviolet* — Similar to glam but less ecosystem adoption
- *cgmath* — Older and less maintained

**Consequences.** glam types flow through the whole workspace and convert directly to/from bevy with no glue. Core stays free of the bevy dependency; integration is opt-in. Locks the workspace to glam's API surface and version cadence. Mined from: /home/me/git/rhizone/unshape/docs/architecture.md (51), /home/me/git/rhizone/unshape/docs/architecture.md (75).
