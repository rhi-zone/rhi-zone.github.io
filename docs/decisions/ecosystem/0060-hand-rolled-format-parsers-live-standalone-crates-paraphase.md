# ADR-0060: Hand-rolled format parsers live in standalone crates, paraphase-* is a thin wrapper

- Status: Accepted
- Date: 2026-05-29

**Context.** When paraphase rolls its own parser/writer for a format, the question is whether that code lives inside the paraphase plugin crate or as an independent crate. Other projects (e.g. rescribe) may need the same format support.

**Decision.** Every hand-rolled format implementation lives in a standalone crate with no Paraphase dependency (e.g. amazon-ion, woff, subtitle-formats); the paraphase-* crate is only a thin wrapper registering converters against the registry. Standalone crates prefer non-destructive parsing (preserve structure/formatting on round-trip). When wrapping an existing ecosystem crate, no new standalone crate is created.

**Alternatives rejected.**
- *Implement hand-rolled format support directly inside the paraphase-* plugin crate* — Other projects (e.g. rescribe) would then have to depend on Paraphase to get the format support; a standalone crate lets them depend on the format crate alone

**Consequences.** Format implementations are reusable across the ecosystem independent of paraphase, and the non-destructive-parsing principle is shared deliberately with rescribe. Establishes that an IR is a consequence of N×M combinatorics (N parsers + M serializers), with losslessness an orthogonal property of IR expressiveness. Mined from: /home/me/git/rhizone/paraphase/docs/philosophy.md (226-228), /home/me/git/rhizone/paraphase/docs/philosophy.md (231-232).
