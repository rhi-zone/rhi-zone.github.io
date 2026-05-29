# ADR-0233: parse() must not be implemented as events().collect()

- Status: Accepted
- Date: 2026-05-29

**Context.** Given the streaming events() API, the elegant move is to define parse() = events().collect(), deriving the tree builder from the event stream.

**Decision.** parse() and events().collect() must be semantically equivalent but must NOT share a code path; parse() is direct recursive descent constructing owned strings directly.

**Alternatives rejected.**
- *Implement parse() as events().collect()* — It forces materialization through the event-dispatch match, prevents direct struct construction, pays into_owned() on every Cow even when the AST could build owned strings directly, and loses single-pass forward-reference resolution for footnotes/links.

**Consequences.** Each crate maintains two materialisation paths (recursive parse() and event collection) that must stay behaviourally equivalent; round-trip fuzzing guards equivalence. Higher maintenance cost, bought for performance and one-pass reference resolution. Mined from: /home/me/git/rhizone/rescribe/docs/format-library-design.md (91-92).
