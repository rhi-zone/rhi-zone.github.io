# ADR-0172: Project named matrix-gen, not matrix

- Status: Accepted
- Date: 2026-05-29

**Context.** The paper's framework is named MATRIX. Naming the Rust implementation the bare 'matrix' would collide with the Matrix chat protocol (matrix.org), making search, package registries, and conversations ambiguous.

**Decision.** Name the project and its crates 'matrix-gen'. The '-gen' suffix both disambiguates from matrix.org and nods to MATRIX-Gen, the scenario-driven instruction generator layered atop the simulator; both simulator substrate and generator live in this one repo under that name.

**Alternatives rejected.**
- *Use the bare name 'matrix' (matching the paper's framework name)* — Collides with the Matrix chat protocol (matrix.org); search, package registries, and conversations all become ambiguous.

**Consequences.** All crate and binary names are matrix-gen-prefixed (matrix-gen-core, matrix-gen-rig, matrix-gen). The name is durable and on crates.io. Splitting simulator and generator into separate names is foreclosed while they share the repo. Mined from: /home/me/git/pterror/matrix-gen/CLAUDE.md (15).
