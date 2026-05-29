# ADR-0208: Interfaces/backends split with platform code confined to backends

- Status: Accepted
- Date: 2026-05-29

**Context.** Implementations differ across native, WASM, and embedded targets; the question is where platform-specific code lives relative to the trait definitions.

**Decision.** Separate crates/interfaces (trait definitions, platform-agnostic) from crates/backends (implementations, native and wasm). Keep interfaces platform-agnostic; put platform-specific code in backends only, gated by feature flags.

**Alternatives rejected.**
- *Allow platform-specific code within the interface definitions* — Would couple interfaces to platforms and defeat portability; interfaces must stay platform-agnostic so the same trait works across native, WASM, and embedded.

**Consequences.** A fixed repo layout (interfaces vs backends/native, backends/wasm) and a rule that no platform-specific code may appear in interface crates. Constrains where all future implementation code is placed. Mined from: /home/me/git/rhizone/portals/DESIGN.md (369-371), /home/me/git/rhizone/portals/README.md (26-27).
