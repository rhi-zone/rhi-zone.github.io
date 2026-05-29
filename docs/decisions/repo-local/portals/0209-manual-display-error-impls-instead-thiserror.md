# ADR-0209: Manual Display/Error impls instead of thiserror

- Status: Accepted
- Date: 2026-05-29

**Context.** Error types need Display and std::error::Error impls; thiserror is the common derive-macro approach, but adds a dependency.

**Decision.** Use manual Display and Error implementations rather than thiserror, to keep dependencies minimal.

**Alternatives rejected.**
- *Use the thiserror derive macro for error types* — Adds a dependency; the project prioritizes minimal dependencies.

**Consequences.** Every interface crate hand-writes Display/Error impls and per-interface error enums with an Other(String) catch-all. Constrains how all future error types are written and keeps the dependency tree lean. Mined from: /home/me/git/rhizone/portals/DESIGN.md (108).
