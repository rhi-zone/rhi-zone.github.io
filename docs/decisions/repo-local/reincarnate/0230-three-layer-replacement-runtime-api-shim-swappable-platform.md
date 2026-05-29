# ADR-0230: Three-layer replacement runtime: API shim over a swappable platform interface

- Status: Accepted
- Date: 2026-05-29

**Context.** The replacement runtime must make translated calls like `MovieClip.gotoAndStop(3)` actually work, across multiple deployment targets (browser, native desktop, testing) and at progressively higher fidelity, while remaining unit-testable. The naive approach has each engine's API shim call browser APIs directly.

**Decision.** Split the replacement runtime into three layers: (1) an engine-specific, platform-agnostic API Shim implementing original engine semantics; (2) an engine-agnostic Platform Interface of low-level I/O primitives (2D draw, audio, input, persistence) that is the swap boundary; (3) per-target Platform Implementations selected at build time (Browser Canvas2D/WebAudio, desktop wgpu/cpal/winit, null for testing). The interface is zero-cost: monomorphized traits in Rust, tree-shaken module re-exports in TypeScript.

**Alternatives rejected.**
- *Naive: API shim calls browser APIs directly (what the current runtime does)* — Breaks for multiple deployment targets (would need a separate shim per target, duplicating engine logic), makes the display-list/event logic untestable without a browser, and prevents progressive optimization by swapping a single layer.

**Consequences.** Each engine shim runs on any target by swapping only the platform implementation. Each platform package can have multiple fidelity tiers (stub/full/optimized) swapped independently. The runtime becomes a third concern, neither frontend nor backend, usable standalone. Forces all I/O through the platform interface contract. Mined from: /home/me/git/rhizone/reincarnate/docs/architecture.md (227-228), /home/me/git/rhizone/reincarnate/docs/architecture.md (164).
