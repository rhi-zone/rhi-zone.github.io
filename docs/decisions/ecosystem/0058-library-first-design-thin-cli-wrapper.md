# ADR-0058: Library-first design with thin CLI wrapper

- Status: Accepted
- Date: 2026-05-29

**Context.** Paraphase could be architected as a Rust library with a thin CLI wrapper, or as a CLI-first tool usable as a library. The Rhizome ecosystem (Resin and other tools) wants direct integration.

**Decision.** Library-first: paraphase is a Rust crate exposing the Registry/Plan/Execute API, and the CLI (paraphase-cli) is a thin (~100-line) wrapper. Crates split into paraphase (library), paraphase-cli (binary), paraphase-plugin (authoring).

**Alternatives rejected.**
- *CLI-first (tool that can also be a library)* — CLI requires file I/O or pipes (no zero-copy), forces subprocess overhead on Rust consumers, and a library can always wrap a CLI but a CLI cannot cleanly unwrap into a coherent library API

**Consequences.** Resin and other Rust tools integrate with zero subprocess overhead and in-memory (&[u8]) conversions; the converter graph is programmatically introspectable. Cost: direct usage is Rust-only (others use CLI) and the library API must maintain semver stability. Mined from: /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (155), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (159), /home/me/git/rhizone/paraphase/docs/architecture-decisions.md (163).
