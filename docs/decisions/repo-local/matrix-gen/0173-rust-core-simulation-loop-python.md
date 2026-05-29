# ADR-0173: Rust core for the simulation loop, not Python

- Status: Accepted
- Date: 2026-05-29

**Context.** The simulation loop is a hot path: K-means clustering over thousands of agent embeddings and modulator gating on every message.

**Decision.** Implement the core simulator in Rust. The MATRIX paper's reference is Python; this is a from-scratch Rust reimplementation chosen for hot-path performance.

**Alternatives rejected.**
- *Python (the paper's language)* — The simulation loop is hot-path (K-means over thousands of embeddings, per-message modulator gating); Rust is chosen over Python here for that workload.

**Consequences.** Core, rig adapter, and CLI are all Rust crates; clippy/cargo-test workflow; performance-sensitive clustering and gating stay in compiled code. Foregoes the Python ML ecosystem's convenience. Mined from: /home/me/git/pterror/matrix-gen/CLAUDE.md (18).
