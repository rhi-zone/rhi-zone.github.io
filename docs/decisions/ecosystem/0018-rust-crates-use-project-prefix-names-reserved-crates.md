# ADR-0018: Rust crates use no project prefix; names reserved on crates.io

- Status: Accepted
- Date: 2026-05-29

**Context.** When naming Rust crates across many ecosystem projects, a convention was needed: namespace them under a common prefix (e.g. `rhi-`) or use bare names. crates.io is a flat global namespace, so prefix-vs-bare affects availability and identity.

**Decision.** Crates use NO prefix; bare names like `normalize-core`, `rescribe`, `wick` are used and reserved on crates.io, and binary names match project names.

**Alternatives rejected.**
- *Namespace crates under an ecosystem prefix (e.g. `rhi-normalize`)* — Bare names are available on crates.io and the projects are positioned as independent tools (not a coupled suite), so a shared prefix is neither needed nor desired.

**Consequences.** New crates must claim bare, prefix-free names and verify crates.io availability; binaries match project names. Identity is per-project, not branded as a suite. Mined from: /home/me/git/rhizone/github-io/CLAUDE.md (58), /home/me/git/rhizone/github-io/CLAUDE.md (61).
