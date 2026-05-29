# ADR-0016: No path dependencies in Cargo.toml; crates publish independently

- Status: Accepted
- Date: 2026-05-29

**Context.** The ecosystem is a set of separate repos, each with Rust crates. A choice was needed about how crates reference each other during development: convenient local path dependencies, or version-pinned published dependencies.

**Decision.** Forbid path dependencies in Cargo.toml across the ecosystem, because they couple repos and break independent publishing. Each crate must depend on published versions, keeping repos independently buildable and releasable.

**Alternatives rejected.**
- *Use path dependencies (e.g. `path = "../other-crate"`) for cross-crate references* — They couple repos and break independent publishing — a repo could no longer build or publish on its own without sibling checkouts.

**Consequences.** Every crate must be publishable in isolation; cross-crate integration goes through crates.io versions, not local paths. Reinforces the 'independent tools, shared pattern not codebase' ecosystem stance. Mined from: /home/me/git/rhizone/github-io/CLAUDE.md (133).
