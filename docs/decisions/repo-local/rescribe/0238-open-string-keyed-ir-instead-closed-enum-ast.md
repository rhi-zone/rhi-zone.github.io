# ADR-0238: Open string-keyed IR instead of a closed enum AST

- Status: Accepted
- Date: 2026-05-29

**Context.** rescribe is a document conversion library inspired by Pandoc. Pandoc's IR is a closed Haskell ADT: every format flattens into a fixed set of Block/Inline variants, so format-specific constructs are approximated or silently dropped and the AST cannot be extended without forking. rescribe had to choose its core IR shape.

**Decision.** Represent documents with an open IR: node kinds are plain strings (NodeKind(String)) and nodes carry arbitrary key-value property bags, so format-specific constructs (html:div, docx:style, latex:env) survive the round-trip and new node kinds require no library change.

**Alternatives rejected.**
- *Closed enum AST (Pandoc's fixed Block/Inline ADT)* — Anything that doesn't fit a fixed variant is approximated or silently dropped; you cannot extend the AST without forking, and there is no programmatic signal of what was lost.

**Consequences.** All downstream format crates and transformers consume an open, string-keyed tree; adding formats/node kinds is non-breaking. Cost: no compile-time exhaustiveness over node kinds; correctness leans on conventions and fidelity tracking rather than the type system. Open question carried in spec.md: whether to distinguish inline/block at the type level. Mined from: /home/me/git/rhizone/rescribe/docs/introduction.md (30-33), /home/me/git/rhizone/rescribe/docs/introduction.md (45-47).
