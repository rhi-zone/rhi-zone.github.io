# ADR-0088: Don't split generated modules by default; rely on consumer tree-shaking

- Status: Accepted
- Date: 2026-05-29

**Context.** When emitting bindings, the generator could eagerly split output into many modules/files or emit a flatter structure. The design had to decide the default packaging granularity.

**Decision.** Don't split modules by default — rely on consumers to tree-shake. Only split when needed, and then by logical grouping (OpenAPI tags, header files).

**Alternatives rejected.**
- *Split into modules by default* — Default splitting imposes structure the consumer may not want; leaving output unsplit and relying on tree-shaking keeps the default simple, with splitting reserved for cases where logical grouping is actually needed.

**Consequences.** Generated output defaults to a less-fragmented layout; consumers depend on their toolchain's dead-code elimination. A logical-grouping split strategy (by tags/header files) remains available when warranted. Mined from: /home/me/git/rhizone/concord/TODO.md (63), /home/me/git/rhizone/concord/TODO.md (64).
