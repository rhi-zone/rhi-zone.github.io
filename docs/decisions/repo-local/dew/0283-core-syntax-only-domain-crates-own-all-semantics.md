# ADR-0283: Core is syntax-only; domain crates own all semantics

- Status: Accepted
- Date: 2026-05-29

**Context.** dew-core needs to support multiple value domains (scalar, linalg, complex, quaternion, dual) without becoming a monolith. The question was whether numeric/vector types and their semantics live in core or in separate domain crates.

**Decision.** dew-core provides only AST representation, parsing, and backend trait interfaces. Domain crates provide value types, type checking/inference, evaluation, and backend implementations. Types are never hardcoded in core.

**Alternatives rejected.**
- *Hardcode value types (Vec2/Vec3/Complex/etc.) and their semantics into dew-core* — Loses extensibility: new domains could not be added without changing core. The design explicitly states this split 'allows extensibility without hardcoding types in core.'

**Consequences.** Every new domain (complex, quaternion, dual, future stream/texture) is an independent crate defining its own Value enum and backends. Core stays minimal (syntax + trait interfaces). Domain crates all require the func feature. Mined from: /home/me/git/rhizone/wick/docs/linalg-design.md (3), /home/me/git/rhizone/wick/docs/linalg-design.md (18), /home/me/git/rhizone/wick/docs/linalg-design.md (45).
