# ADR-0240: Server-less is a projection system, not a framework

- Status: Accepted
- Date: 2026-05-29

**Context.** A library that turns Rust impl blocks into HTTP/CLI/MCP/etc. handlers could position itself as a framework (owning user code, dictating handler shapes and types) or as a projection layer over plain user code.

**Decision.** Server-less is defined as a projection system: users write plain Rust methods with plain types and no protocol awareness; attributes are semantic metadata projected onto many protocols at once. Each projection must be competitive with hand-written native-library code, and dropping a single derive must leave everything else composing (progressive disclosure). The explicit prior-art model is Serde's derive-as-projection.

**Alternatives rejected.**
- *Framework model where the library owns your code and you write handlers in its shape using its types* — Frameworks own your code; server-less instead projects your code so it stays plain Rust. The distinction is stated as load-bearing: 'a projection system, not a framework. The distinction matters.'

**Consequences.** Sets the permanent quality bar (each projection competitive with axum/clap/etc. hand-written code) and the progressive-disclosure contract (zero-config works; drop one derive to hand-write that piece; manual Tower is the nuclear option). Attributes must carry semantic meaning shared across protocols rather than protocol-specific framework config. Mined from: /home/me/git/rhizone/server-less/README.md (232), /home/me/git/rhizone/server-less/README.md (234-235), /home/me/git/rhizone/server-less/README.md (27).
